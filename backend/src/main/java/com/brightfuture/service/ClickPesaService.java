package com.brightfuture.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * ClickPesa mobile money integration (Tanzania).
 *
 * <p>Three calls make up the whole flow:
 * <ol>
 *   <li>{@code POST /generate-token} - exchanges the client id and api key for
 *       a short-lived bearer token.</li>
 *   <li>{@code POST /payments/initiate-ussd-push-request} - sends a PIN prompt
 *       to the customer's phone. Returns immediately; the customer has not paid
 *       yet.</li>
 *   <li>{@code GET /payments/{orderReference}} - the authoritative status.
 *       Never treat an order as paid without this call.</li>
 * </ol>
 *
 * <p>The client id and api key are read from the environment and never leave
 * the server. The mobile app only ever sees an order reference and a status.
 */
@Service
public class ClickPesaService {

    private static final Logger log = LoggerFactory.getLogger(ClickPesaService.class);

    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${clickpesa.base-url:https://api.clickpesa.com/third-parties}")
    private String baseUrl;

    @Value("${clickpesa.client-id:}")
    private String clientId;

    @Value("${clickpesa.api-key:}")
    private String apiKey;

    /** False when no credentials are configured, so the API can say so cleanly. */
    public boolean isConfigured() {
        return clientId != null && !clientId.isBlank()
                && apiKey != null && !apiKey.isBlank();
    }

    /**
     * Exchanges the client id and api key for a bearer token. ClickPesa returns
     * the value already prefixed with "Bearer ", so it is passed through to the
     * Authorization header unchanged.
     */
    public String generateToken() {
        HttpHeaders headers = new HttpHeaders();
        headers.set("client-id", clientId);
        headers.set("api-key", apiKey);
        headers.setContentType(MediaType.APPLICATION_JSON);

        try {
            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                    baseUrl + "/generate-token",
                    HttpMethod.POST,
                    new HttpEntity<>(headers),
                    mapType()
            );

            Map<String, Object> body = response.getBody();
            Object token = body != null ? body.get("token") : null;
            if (token instanceof String s && !s.isBlank()) {
                return s;
            }
            throw new ClickPesaException("ClickPesa did not return a token.");
        } catch (RestClientResponseException e) {
            log.error("ClickPesa token request failed: {} {}", e.getStatusCode(), e.getResponseBodyAsString());
            throw new ClickPesaException("Could not authenticate with ClickPesa.");
        }
    }

    /**
     * Sends the USSD PIN prompt to the customer's phone.
     *
     * @param phoneNumber must already be normalised to 255XXXXXXXXX
     * @return ClickPesa's acknowledgement - typically status PROCESSING
     */
    public Map<String, Object> initiateUssdPush(String token,
                                                String amount,
                                                String currency,
                                                String orderReference,
                                                String phoneNumber) {
        HttpHeaders headers = new HttpHeaders();
        headers.set(HttpHeaders.AUTHORIZATION, token);
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> payload = new HashMap<>();
        payload.put("amount", amount);
        payload.put("currency", currency);
        payload.put("orderReference", orderReference);
        payload.put("phoneNumber", phoneNumber);

        try {
            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                    baseUrl + "/payments/initiate-ussd-push-request",
                    HttpMethod.POST,
                    new HttpEntity<>(payload, headers),
                    mapType()
            );
            Map<String, Object> body = response.getBody();
            return body != null ? body : Map.of();
        } catch (RestClientResponseException e) {
            log.error("ClickPesa USSD push failed for {}: {} {}",
                    orderReference, e.getStatusCode(), e.getResponseBodyAsString());
            throw new ClickPesaException(readMessage(e, "The payment could not be started."));
        }
    }

    /**
     * The authoritative payment status. Returns null when ClickPesa has no
     * record of the reference yet, which is normal in the seconds right after
     * the push is sent.
     */
    @SuppressWarnings("unchecked")
    public Map<String, Object> queryPayment(String token, String orderReference) {
        HttpHeaders headers = new HttpHeaders();
        headers.set(HttpHeaders.AUTHORIZATION, token);
        headers.setContentType(MediaType.APPLICATION_JSON);

        try {
            ResponseEntity<Object> response = restTemplate.exchange(
                    baseUrl + "/payments/" + orderReference,
                    HttpMethod.GET,
                    new HttpEntity<>(headers),
                    Object.class
            );

            Object body = response.getBody();
            // The endpoint answers with either a single object or a one-element
            // list depending on the account, so both shapes are handled.
            if (body instanceof List<?> list) {
                return list.isEmpty() ? null : (Map<String, Object>) list.get(0);
            }
            if (body instanceof Map<?, ?> map) {
                return (Map<String, Object>) map;
            }
            return null;
        } catch (RestClientResponseException e) {
            log.warn("ClickPesa status query for {} returned {}", orderReference, e.getStatusCode());
            return null;
        }
    }

    /**
     * Tanzanian numbers reach ClickPesa as 255XXXXXXXXX. Accepts the forms
     * people actually type: 0712..., +255712..., 255712... and 712...
     *
     * @return the normalised number, or null when it cannot be a TZ mobile
     */
    public static String normalizeTzPhone(String input) {
        if (input == null) {
            return null;
        }
        String digits = input.replaceAll("\\D", "");
        // Tanzanian mobile numbers are nine digits starting 6 or 7 (06x / 07x).
        // A landline or a typo is rejected here rather than by ClickPesa.
        if (digits.startsWith("255") && digits.length() == 12) {
            String body = digits.substring(3);
            return isMobileBody(body) ? digits : null;
        }
        if (digits.startsWith("0") && digits.length() == 10) {
            String body = digits.substring(1);
            return isMobileBody(body) ? "255" + body : null;
        }
        if (digits.length() == 9) {
            return isMobileBody(digits) ? "255" + digits : null;
        }
        return null;
    }

    private static boolean isMobileBody(String body) {
        return body.length() == 9 && (body.startsWith("6") || body.startsWith("7"));
    }

    private static String readMessage(RestClientResponseException e, String fallback) {
        String body = e.getResponseBodyAsString();
        if (body == null || body.isBlank()) {
            return fallback;
        }
        // Good enough for surfacing ClickPesa's own wording without pulling in
        // a parser for a single field.
        int i = body.indexOf("\"message\"");
        if (i < 0) {
            return fallback;
        }
        int start = body.indexOf('"', body.indexOf(':', i) + 1);
        int end = start > 0 ? body.indexOf('"', start + 1) : -1;
        return (start > 0 && end > start) ? body.substring(start + 1, end) : fallback;
    }

    private static org.springframework.core.ParameterizedTypeReference<Map<String, Object>> mapType() {
        return new org.springframework.core.ParameterizedTypeReference<>() {};
    }

    /** Thrown when ClickPesa rejects a request; mapped to a 502 by the controller. */
    public static class ClickPesaException extends RuntimeException {
        public ClickPesaException(String message) {
            super(message);
        }
    }
}
