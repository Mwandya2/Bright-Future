package com.brightfuture.controller;

import com.brightfuture.config.SecurityUtils;
import com.brightfuture.dto.common.ApiResponse;
import com.brightfuture.exception.BadRequestException;
import com.brightfuture.exception.ResourceNotFoundException;
import com.brightfuture.entity.Course;
import com.brightfuture.repository.CourseRepository;
import com.stripe.Stripe;
import com.stripe.model.PaymentIntent;
import com.stripe.param.PaymentIntentCreateParams;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * Creates Stripe PaymentIntents for course enrolments.
 *
 * The mobile app never sees the secret key - it receives only the intent's
 * client secret, which is safe to hand to the Stripe SDK on the device.
 *
 * Drop this file into com.brightfuture.controller and add the stripe-java
 * dependency (see backend-addons/README.md).
 */
@RestController
@RequestMapping("/api/payments")
@Tag(name = "Payments", description = "Card payment endpoints for course enrolment")
public class PaymentController {

    private final CourseRepository courseRepository;
    private final SecurityUtils securityUtils;

    @Value("${app.stripe.secret-key:}")
    private String stripeSecretKey;

    public PaymentController(CourseRepository courseRepository, SecurityUtils securityUtils) {
        this.courseRepository = courseRepository;
        this.securityUtils = securityUtils;
    }

    @PostConstruct
    void init() {
        if (stripeSecretKey != null && !stripeSecretKey.isBlank()) {
            Stripe.apiKey = stripeSecretKey;
        }
    }

    @PostMapping("/intent")
    @Operation(summary = "Create a PaymentIntent for a paid course")
    public ResponseEntity<ApiResponse<Map<String, Object>>> createIntent(
            @RequestBody Map<String, Object> body) throws Exception {

        if (stripeSecretKey == null || stripeSecretKey.isBlank()) {
            throw new BadRequestException("Payments are not configured on this server.");
        }

        UUID userId = securityUtils.getCurrentUserId();

        Object rawCourseId = body.get("courseId");
        if (rawCourseId == null) {
            throw new BadRequestException("courseId is required");
        }
        UUID courseId = UUID.fromString(rawCourseId.toString());

        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found"));

        // Never trust an amount sent by the client - read it from the database.
        int amount = course.getPrice() == null ? 0 : course.getPrice();
        if (amount <= 0) {
            throw new BadRequestException("This course is free - no payment is needed.");
        }

        String currency = body.getOrDefault("currency", "tzs").toString().toLowerCase();

        // Stripe expects the smallest currency unit. TZS is a zero-decimal
        // currency, so the whole-shilling price is already correct. If you
        // switch to USD/EUR, multiply by 100 here.
        long stripeAmount = amount;

        PaymentIntentCreateParams params = PaymentIntentCreateParams.builder()
                .setAmount(stripeAmount)
                .setCurrency(currency)
                .setDescription(course.getTitle())
                .putMetadata("courseId", courseId.toString())
                .putMetadata("userId", userId.toString())
                .setAutomaticPaymentMethods(
                        PaymentIntentCreateParams.AutomaticPaymentMethods.builder()
                                .setEnabled(true)
                                .build())
                .build();

        PaymentIntent intent = PaymentIntent.create(params);

        Map<String, Object> data = new HashMap<>();
        data.put("clientSecret", intent.getClientSecret());
        data.put("paymentIntentId", intent.getId());
        data.put("amount", amount);
        data.put("currency", currency);

        return ResponseEntity.ok(ApiResponse.ok(data));
    }
}
