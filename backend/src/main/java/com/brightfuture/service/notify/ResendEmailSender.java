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

import java.util.Map;

/**
 * Email through Resend, which the website already uses, so there is one
 * provider and one sending domain rather than two.
 */
@Component
public class ResendEmailSender implements EmailSender {

    private static final Logger log = LoggerFactory.getLogger(ResendEmailSender.class);

    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${email.resend.base-url:https://api.resend.com/emails}")
    private String baseUrl;

    @Value("${email.resend.api-key:}")
    private String apiKey;

    @Value("${email.resend.from:Bright Future <onboarding@resend.dev>}")
    private String from;

    @Override
    public boolean isConfigured() {
        return apiKey != null && !apiKey.isBlank();
    }

    @Override
    public boolean send(String to, String subject, String html) {
        if (!isConfigured()) {
            return false;
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(apiKey);

        Map<String, Object> payload = Map.of(
                "from", from,
                "to", new String[]{to},
                "subject", subject,
                "html", html
        );

        try {
            ResponseEntity<String> response = restTemplate.postForEntity(
                    baseUrl, new HttpEntity<>(payload, headers), String.class);
            boolean ok = response.getStatusCode().is2xxSuccessful();
            if (!ok) {
                log.error("Resend rejected an email: {}", response.getStatusCode());
            }
            return ok;
        } catch (RestClientException e) {
            log.error("Resend request failed", e);
            return false;
        }
    }
}
