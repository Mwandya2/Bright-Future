package com.brightfuture.controller;

import com.brightfuture.config.SecurityUtils;
import com.brightfuture.dto.common.ApiResponse;
import com.brightfuture.entity.Course;
import com.brightfuture.entity.CoursePayment;
import com.brightfuture.entity.PaymentStatus;
import com.brightfuture.entity.User;
import com.brightfuture.repository.CoursePaymentRepository;
import com.brightfuture.repository.CourseRepository;
import com.brightfuture.repository.UserRepository;
import com.brightfuture.service.ClickPesaService;
import com.brightfuture.service.EnrollmentService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
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

    private static final Logger log = LoggerFactory.getLogger(PaymentController.class);
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final String ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

    private final ClickPesaService clickPesa;
    private final CourseRepository courseRepository;
    private final UserRepository userRepository;
    private final CoursePaymentRepository paymentRepository;
    private final EnrollmentService enrollmentService;
    private final SecurityUtils securityUtils;

    @org.springframework.beans.factory.annotation.Value("${clickpesa.webhook-secret:}")
    private String webhookSecret;

    public PaymentController(ClickPesaService clickPesa,
                             CourseRepository courseRepository,
                             UserRepository userRepository,
                             CoursePaymentRepository paymentRepository,
                             EnrollmentService enrollmentService,
                             SecurityUtils securityUtils) {
        this.clickPesa = clickPesa;
        this.courseRepository = courseRepository;
        this.userRepository = userRepository;
        this.paymentRepository = paymentRepository;
        this.enrollmentService = enrollmentService;
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

        UUID userId = securityUtils.getCurrentUserId();

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

            // Recorded only once ClickPesa has accepted the push, so a rejected
            // request does not leave a phantom PENDING row behind.
            User user = userRepository.findById(userId).orElse(null);
            if (user != null) {
                paymentRepository.save(
                        new CoursePayment(orderReference, user, course, amount, phone));
            }

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

        UUID userId = securityUtils.getCurrentUserId();

        CoursePayment payment = paymentRepository.findByOrderReference(orderReference).orElse(null);

        // A reference belongs to the person who started it. Without this check
        // anyone could poll another student's payment.
        if (payment != null && !payment.getUser().getId().equals(userId)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error("No such payment."));
        }

        // Already settled: answer from our own record rather than paying for
        // another round trip to ClickPesa. Deliberately before the isConfigured
        // check, so a settled payment is still reported if credentials are
        // later removed.
        if (payment != null && payment.getStatus() == PaymentStatus.PAID) {
            return ResponseEntity.ok(ApiResponse.ok(describe(payment, "SUCCESS")));
        }

        if (!clickPesa.isConfigured()) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(ApiResponse.error("Mobile money is not switched on yet."));
        }

        try {
            String token = clickPesa.generateToken();
            Map<String, Object> record = clickPesa.queryPayment(token, orderReference);

            String status = record == null
                    ? "PROCESSING"
                    : String.valueOf(record.getOrDefault("status", "PROCESSING"));

            if (payment != null) {
                settle(payment, status);
            }

            Map<String, Object> payload = new HashMap<>();
            payload.put("orderReference", orderReference);
            payload.put("status", status);
            payload.put("collectedAmount", record == null ? null : record.get("collectedAmount"));
            return ResponseEntity.ok(ApiResponse.ok(payload));
        } catch (ClickPesaService.ClickPesaException e) {
            return ResponseEntity.status(HttpStatus.BAD_GATEWAY)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    /**
     * ClickPesa calls this when a payment changes state, so a student who
     * closes the app mid-payment is still enrolled without waiting for their
     * next poll.
     *
     * <p>The body is treated purely as a trigger. Its claimed status is never
     * believed: the reference is looked up in our own records and the true status
     * is fetched from ClickPesa over an authenticated call. A forged webhook
     * therefore achieves nothing beyond causing one extra API request.
     *
     * <p>The secret in the path is a cheap first filter so obvious noise never
     * reaches the gateway. Configure the URL in the ClickPesa dashboard as
     * {@code https://your-api/api/payments/webhook/<CLICKPESA_WEBHOOK_SECRET>}.
     */
    @PostMapping("/webhook/{secret}")
    public ResponseEntity<ApiResponse<String>> webhook(
            @PathVariable String secret,
            @RequestBody(required = false) Map<String, Object> body) {

        // Fail closed: with no secret configured, no webhook is accepted.
        if (webhookSecret == null || webhookSecret.isBlank()
                || !MessageDigest.isEqual(
                        secret.getBytes(StandardCharsets.UTF_8),
                        webhookSecret.getBytes(StandardCharsets.UTF_8))) {
            log.warn("Rejected a ClickPesa webhook with a bad secret.");
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error("Not found."));
        }

        String orderReference = extractReference(body);
        if (orderReference == null) {
            // 200 on purpose: the payload is unusable, and a non-2xx would make
            // ClickPesa retry something that can never succeed.
            log.warn("ClickPesa webhook carried no order reference: {}", body);
            return ResponseEntity.ok(ApiResponse.message("Ignored."));
        }

        CoursePayment payment = paymentRepository.findByOrderReference(orderReference).orElse(null);
        if (payment == null) {
            log.warn("ClickPesa webhook for an unknown reference: {}", orderReference);
            return ResponseEntity.ok(ApiResponse.message("Unknown reference."));
        }
        if (payment.getStatus() == PaymentStatus.PAID) {
            return ResponseEntity.ok(ApiResponse.message("Already settled."));
        }

        if (!clickPesa.isConfigured()) {
            log.error("ClickPesa webhook received but no credentials are configured.");
            return ResponseEntity.ok(ApiResponse.message("Not configured."));
        }

        try {
            String token = clickPesa.generateToken();
            Map<String, Object> record = clickPesa.queryPayment(token, orderReference);
            String status = record == null
                    ? "PROCESSING"
                    : String.valueOf(record.getOrDefault("status", "PROCESSING"));
            settle(payment, status);
        } catch (ClickPesaService.ClickPesaException e) {
            // Non-2xx so ClickPesa retries: this failure is transient.
            log.error("Could not verify webhook for {}", orderReference, e);
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(ApiResponse.error("Could not verify with ClickPesa."));
        }

        return ResponseEntity.ok(ApiResponse.message("Processed."));
    }

    /**
     * Records the verified status and, when it is PAID, enrols the student.
     *
     * <p>Enrolment happens here rather than in the client so that closing the
     * app mid-payment cannot cost a student the course they just paid for.
     */
    private void settle(CoursePayment payment, String rawStatus) {
        PaymentStatus mapped = mapStatus(rawStatus);
        if (mapped != payment.getStatus()) {
            payment.setStatus(mapped);
            paymentRepository.save(payment);
        }
        if (mapped == PaymentStatus.PAID) {
            try {
                enrollmentService.enroll(
                        payment.getUser().getId(), payment.getCourse().getId());
            } catch (RuntimeException e) {
                log.error("Payment {} settled but enrolment failed",
                        payment.getOrderReference(), e);
            }
        }
    }

    /**
     * Pulls the order reference out of whatever shape the callback arrives in -
     * top level, or nested under `data`/`payment`, and in either camelCase or
     * snake_case.
     */
    @SuppressWarnings("unchecked")
    private static String extractReference(Map<String, Object> body) {
        if (body == null) {
            return null;
        }
        for (String key : new String[]{"orderReference", "order_reference"}) {
            Object v = body.get(key);
            if (v instanceof String s && !s.isBlank()) {
                return s;
            }
        }
        for (String nested : new String[]{"data", "payment"}) {
            if (body.get(nested) instanceof Map<?, ?> m) {
                String found = extractReference((Map<String, Object>) m);
                if (found != null) {
                    return found;
                }
            }
        }
        return null;
    }

    private static Map<String, Object> describe(CoursePayment payment, String status) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("orderReference", payment.getOrderReference());
        payload.put("status", status);
        payload.put("collectedAmount", payment.getAmount());
        return payload;
    }

    /**
     * ClickPesa's vocabulary mapped onto ours. Anything unrecognised stays
     * PENDING rather than becoming a failure, so a new status name on their
     * side can never revoke a payment that actually succeeded.
     */
    private static PaymentStatus mapStatus(String raw) {
        return switch (raw == null ? "" : raw.toUpperCase()) {
            case "SUCCESS", "SUCCESSFUL", "SETTLED", "PAID" -> PaymentStatus.PAID;
            case "FAILED", "REJECTED", "REVERSED", "REFUNDED" -> PaymentStatus.FAILED;
            case "CANCELLED", "CANCELED" -> PaymentStatus.CANCELLED;
            default -> PaymentStatus.PENDING;
        };
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
