package com.brightfuture.repository;

import com.brightfuture.entity.Course;
import com.brightfuture.entity.Enrollment;
import com.brightfuture.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface EnrollmentRepository extends JpaRepository<Enrollment, UUID> {
    List<Enrollment> findByUserOrderByCreatedAtDesc(User user);
    List<Enrollment> findByCourse(Course course);
    Optional<Enrollment> findByUserAndCourse(User user, Course course);
    boolean existsByUserAndCourse(User user, Course course);
    long countByUser(User user);
}
