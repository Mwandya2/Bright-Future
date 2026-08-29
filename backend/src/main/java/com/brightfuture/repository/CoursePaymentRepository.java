package com.brightfuture.repository;

import com.brightfuture.entity.CoursePayment;
import com.brightfuture.entity.PaymentStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface CoursePaymentRepository extends JpaRepository<CoursePayment, UUID> {

    Optional<CoursePayment> findByOrderReference(String orderReference);

    /** The check the enrolment gate relies on. */
    boolean existsByUserIdAndCourseIdAndStatus(UUID userId, UUID courseId, PaymentStatus status);
}
