package com.brightfuture.service;

import com.brightfuture.dto.course.EnrollmentDto;
import com.brightfuture.entity.Course;
import com.brightfuture.entity.Enrollment;
import com.brightfuture.entity.EnrollmentStatus;
import com.brightfuture.entity.PaymentStatus;
import com.brightfuture.entity.Role;
import com.brightfuture.entity.User;
import com.brightfuture.exception.BadRequestException;
import com.brightfuture.exception.ResourceNotFoundException;
import com.brightfuture.repository.CoursePaymentRepository;
import com.brightfuture.repository.CourseRepository;
import com.brightfuture.repository.EnrollmentRepository;
import com.brightfuture.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class EnrollmentService {

    private final EnrollmentRepository enrollmentRepository;
    private final CourseRepository courseRepository;
    private final UserRepository userRepository;
    private final CoursePaymentRepository paymentRepository;

    public EnrollmentService(
            EnrollmentRepository enrollmentRepository,
            CourseRepository courseRepository,
            UserRepository userRepository,
            CoursePaymentRepository paymentRepository) {
        this.enrollmentRepository = enrollmentRepository;
        this.courseRepository = courseRepository;
        this.userRepository = userRepository;
        this.paymentRepository = paymentRepository;
    }

    @Transactional(readOnly = true)
    public List<EnrollmentDto> getUserEnrollments(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return enrollmentRepository.findByUserOrderByCreatedAtDesc(user).stream()
                .map(EnrollmentDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public EnrollmentDto enroll(UUID userId, UUID courseId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found"));

        requirePaymentForPaidCourse(user, course);

        return enrollmentRepository.findByUserAndCourse(user, course)
                .map(EnrollmentDto::fromEntity)
                .orElseGet(() -> {
                    Enrollment newEnrollment = Enrollment.builder()
                            .user(user)
                            .course(course)
                            .status(EnrollmentStatus.ACTIVE)
                            .progress(0)
                            .build();
                    return EnrollmentDto.fromEntity(enrollmentRepository.save(newEnrollment));
                });
    }

    /**
     * A paid course may only be enrolled in once a payment for it has settled.
     *
     * <p>Enrolment is a separate endpoint from payment, so without this check
     * any authenticated caller could POST /api/enrollments and take a paid
     * course for nothing. The client is never consulted: the price comes from
     * the course row and the evidence of payment from course_payments.
     *
     * <p>Free courses (price 0) are unaffected, as is enrolling again in a
     * course already paid for.
     */
    private void requirePaymentForPaidCourse(User user, Course course) {
        int price = course.getPrice() == null ? 0 : course.getPrice();
        if (price <= 0) {
            return;
        }
        // Administrators run the hub; charging them to open their own course
        // makes no sense, and they need to enrol to review course content.
        if (user.getRole() == Role.ADMIN) {
            return;
        }
        boolean paid = paymentRepository.existsByUserIdAndCourseIdAndStatus(
                user.getId(), course.getId(), PaymentStatus.PAID);
        if (!paid) {
            throw new BadRequestException(
                    "This course must be paid for before you can enrol. "
                            + "If you have just paid, wait a moment and try again.");
        }
    }

    @Transactional
    public EnrollmentDto updateProgress(UUID userId, UUID enrollmentId, Integer progress) {
        Enrollment enrollment = enrollmentRepository.findById(enrollmentId)
                .orElseThrow(() -> new ResourceNotFoundException("Enrollment not found"));

        if (!enrollment.getUser().getId().equals(userId)) {
            throw new BadRequestException("You can only update your own course progress.");
        }

        enrollment.setProgress(progress);
        if (progress >= 100) {
            enrollment.setStatus(EnrollmentStatus.COMPLETED);
        }

        return EnrollmentDto.fromEntity(enrollmentRepository.save(enrollment));
    }
}
