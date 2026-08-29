package com.brightfuture.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.util.UUID;

/**
 * A payment attempt for a course.
 *
 * <p>This exists so enrolment can be *verified* rather than trusted. Without a
 * server-side record, the only evidence a course was paid for lives in the
 * client, and any caller able to reach /api/enrollments could take a paid
 * course for free.
 *
 * <p>The amount is copied from the course at the moment the payment starts, so
 * a later price change cannot retroactively invalidate a completed payment.
 */
@Entity
@Table(
    name = "course_payments",
    indexes = {
        @Index(name = "idx_course_payments_user_course", columnList = "user_id, course_id"),
        @Index(name = "idx_course_payments_reference", columnList = "order_reference", unique = true)
    }
)
public class CoursePayment {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    /** ClickPesa's reference for this attempt. Unique, and how status is polled. */
    @Column(name = "order_reference", nullable = false, unique = true, length = 64)
    private String orderReference;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    /** Amount in whole TZS, taken from the course when the payment started. */
    @Column(nullable = false)
    private Integer amount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 16)
    private PaymentStatus status = PaymentStatus.PENDING;

    /** The payer's mobile money number, normalised to 255XXXXXXXXX. */
    @Column(name = "phone_number", length = 16)
    private String phoneNumber;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private Instant updatedAt;

    public CoursePayment() {}

    public CoursePayment(String orderReference, User user, Course course, Integer amount, String phoneNumber) {
        this.orderReference = orderReference;
        this.user = user;
        this.course = course;
        this.amount = amount;
        this.phoneNumber = phoneNumber;
        this.status = PaymentStatus.PENDING;
    }

    public UUID getId() { return id; }
    public String getOrderReference() { return orderReference; }
    public User getUser() { return user; }
    public Course getCourse() { return course; }
    public Integer getAmount() { return amount; }
    public void setAmount(Integer amount) { this.amount = amount; }
    public PaymentStatus getStatus() { return status; }
    public void setStatus(PaymentStatus status) { this.status = status; }
    public String getPhoneNumber() { return phoneNumber; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
}
