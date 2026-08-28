package com.brightfuture.service;

import com.brightfuture.dto.course.EnrollmentDto;
import com.brightfuture.entity.Course;
import com.brightfuture.entity.Enrollment;
import com.brightfuture.entity.EnrollmentStatus;
import com.brightfuture.entity.User;
import com.brightfuture.exception.BadRequestException;
import com.brightfuture.exception.ResourceNotFoundException;
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

    public EnrollmentService(
            EnrollmentRepository enrollmentRepository,
            CourseRepository courseRepository,
            UserRepository userRepository) {
        this.enrollmentRepository = enrollmentRepository;
        this.courseRepository = courseRepository;
        this.userRepository = userRepository;
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
