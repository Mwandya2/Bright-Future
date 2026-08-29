package com.brightfuture.controller;

import com.brightfuture.config.SecurityUtils;
import com.brightfuture.dto.common.ApiResponse;
import com.brightfuture.entity.Course;
import com.brightfuture.repository.CourseRepository;
import com.brightfuture.service.ClickPesaService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.security.SecureRandom;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * Mobile money payments for paid courses, via ClickPesa USSD push.
 *
 * <p>The flow the app follows:
 * <ol>
 *   <li>{@code POST /api/payments/ussd} with the course and the payer's phone
 *       number. The customer gets a PIN prompt on their handset.</li>
 *   <li>The app polls {@code GET /api/payments/{orderReference}} until the
 *       status settles.</li>
 *   <li>On SUCCESS the app enrols the student through the existing
 *       {@code /api/enrollments} endpoint.</li>
 * </ol>
 *
 * <p>Both endpoints require a signed-in user - the security config's
 * {@code anyRequest().authenticated()} rule covers them.
 */
@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final String ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

    private final ClickPesaService clickPesa;
    private final CourseRepository courseRepository;
    private final SecurityUtils securityUtils;

    public PaymentController(ClickPesaService clickPesa,
                             CourseRepository courseRepository,
                             SecurityUtils securityUtils) {
        this.clickPesa = clickPesa;
        this.courseRepository = courseRepository;
        this.securityUtils = securityUtils;
    }

    /** Starts a mobile money payment for a course. */
    @PostMapping("/ussd")
    public ResponseEntity<ApiResponse<Map<String, Object>>> initiateUssd(
            @RequestBody Map<String, Object> body) {

        if (!clickPesa.isConfigured()) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(ApiResponse.error(
                            "Mobile money is not switched on yet. Set CLICKPESA_CLIENT_ID "
                                    + "and CLICKPESA_API_KEY on the server."));
        }

        // Confirms the caller is signed in, and gives the reference an owner.
        securityUtils.getCurrentUserId();

        String rawCourseId = asString(body.get("courseId"));
        if (rawCourseId == null) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("A courseId is required."));
        }

        UUID courseId;
        try {
            courseId = UUID.fromString(rawCourseId);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("That course id is not valid."));
        }

        Course course = courseRepository.findById(courseId).orElse(null);
        if (course == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error("That course no longer exists."));
        }

        // The price always comes from the database, never from the request, so
        // a modified client cannot choose what it pays.
        int amount = course.getPrice() == null ? 0 : course.getPrice();
        if (amount <= 0) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("This course is free - no payment is needed."));
        }

        String phone = ClickPesaService.normalizeTzPhone(asString(body.get("phoneNumber")));
        if (phone == null) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(
                            "Enter a Tanzanian mobile number, for example 0712 345 678."));
        }

        String orderReference = newOrderReference();

        try {
            String token = clickPesa.generateToken();
            Map<String, Object> result = clickPesa.initiateUssdPush(
                    token,
                    String.valueOf(amount),
                    "TZS",
                    orderReference,
                    phone
            );

            Map<String, Object> payload = new HashMap<>();
            payload.put("orderReference", orderReference);
            payload.put("status", result.getOrDefault("status", "PROCESSING"));
            payload.put("channel", result.get("channel"));
            payload.put("amount", amount);
            payload.put("phoneNumber", phone);

            return ResponseEntity.ok(ApiResponse.ok(
                    "Check your phone and enter your mobile money PIN.", payload));
        } catch (ClickPesaService.ClickPesaException e) {
            return ResponseEntity.status(HttpStatus.BAD_GATEWAY)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    /** The authoritative status of a payment. */
    @GetMapping("/{orderReference}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> status(
            @PathVariable String orderReference) {

        if (!clickPesa.isConfigured()) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(ApiResponse.error("Mobile money is not switched on yet."));
        }

        securityUtils.getCurrentUserId();

        try {
            String token = clickPesa.generateToken();
            Map<String, Object> record = clickPesa.queryPayment(token, orderReference);

            Map<String, Object> payload = new HashMap<>();
            payload.put("orderReference", orderReference);
            if (record == null) {
                // ClickPesa has not registered the reference yet. The customer
                // is still looking at the PIN prompt.
                payload.put("status", "PROCESSING");
                payload.put("collectedAmount", null);
            } else {
                payload.put("status", record.getOrDefault("status", "PROCESSING"));
                payload.put("collectedAmount", record.get("collectedAmount"));
            }
            return ResponseEntity.ok(ApiResponse.ok(payload));
        } catch (ClickPesaService.ClickPesaException e) {
            return ResponseEntity.status(HttpStatus.BAD_GATEWAY)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * ClickPesa order references must be alphanumeric and unique. Ambiguous
     * characters (0/O, 1/I) are left out so a reference can be read aloud over
     * the phone at the hub.
     */
    private static String newOrderReference() {
        StringBuilder sb = new StringBuilder("BF");
        for (int i = 0; i < 12; i++) {
            sb.append(ALPHABET.charAt(RANDOM.nextInt(ALPHABET.length())));
        }
        return sb.toString();
    }

    private static String asString(Object value) {
        if (value == null) {
            return null;
        }
        String s = String.valueOf(value).trim();
        return s.isEmpty() ? null : s;
    }
}
