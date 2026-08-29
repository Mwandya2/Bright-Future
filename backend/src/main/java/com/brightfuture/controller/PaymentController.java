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
                PaymentStatus mapped = mapStatus(status);
                if (mapped != payment.getStatus()) {
                    payment.setStatus(mapped);
                    paymentRepository.save(payment);
                }

                // Settling is what grants access. Enrolling here rather than
                // trusting the client means a student who closes the app mid
                // payment is still enrolled the next time the status is read.
                if (mapped == PaymentStatus.PAID) {
                    try {
                        enrollmentService.enroll(userId, payment.getCourse().getId());
                    } catch (RuntimeException e) {
                        log.error("Payment {} settled but enrolment failed", orderReference, e);
                    }
                }
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
