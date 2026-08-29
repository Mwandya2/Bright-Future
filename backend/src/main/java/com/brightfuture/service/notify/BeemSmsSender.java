package com.brightfuture.service.notify;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.List;
import java.util.Map;

/**
 * SMS through Beem Africa, which is the cheaper route to Tanzanian numbers.
 *
 * <p>Beem authenticates with HTTP Basic using the API key as the username and
 * the secret as the password.
 *
 * <p>The source address must be a sender ID registered with Beem and approved
 * by the TCRA. An unregistered one is rejected, or silently not delivered, so
 * this is worth checking in the Beem dashboard before blaming the code.
 */
@Component
public class BeemSmsSender implements SmsSender {

    private static final Logger log = LoggerFactory.getLogger(BeemSmsSender.class);

    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${sms.beem.base-url:https://apisms.beem.africa/v1/send}")
    private String baseUrl;

    @Value("${sms.beem.api-key:}")
    private String apiKey;

    @Value("${sms.beem.secret-key:}")
    private String secretKey;

    @Value("${sms.beem.sender-id:INFO}")
    private String senderId;

    @Override
    public boolean isConfigured() {
        return apiKey != null && !apiKey.isBlank()
                && secretKey != null && !secretKey.isBlank();
    }

    @Override
    public boolean send(String destination, String message) {
        if (!isConfigured()) {
            return false;
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        String basic = Base64.getEncoder().encodeToString(
                (apiKey + ":" + secretKey).getBytes(StandardCharsets.UTF_8));
        headers.set(HttpHeaders.AUTHORIZATION, "Basic " + basic);

        Map<String, Object> payload = Map.of(
                "source_addr", senderId,
                "schedule_time", "",
                "encoding", 0,
                "message", message,
                "recipients", List.of(Map.of(
                        "recipient_id", 1,
                        "dest_addr", destination))
        );

        try {
            ResponseEntity<String> response = restTemplate.postForEntity(
                    baseUrl, new HttpEntity<>(payload, headers), String.class);
            boolean ok = response.getStatusCode().is2xxSuccessful();
            if (!ok) {
                log.error("Beem rejected an SMS: {} {}", response.getStatusCode(), response.getBody());
            }
            return ok;
        } catch (RestClientException e) {
            // Never log the message body - it contains the one-time code.
            log.error("Beem SMS request failed", e);
            return false;
        }
    }
}
