package com.brightfuture.repository;

import com.brightfuture.entity.Course;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CourseRepository extends JpaRepository<Course, UUID> {
    Optional<Course> findBySlug(String slug);
    List<Course> findByIsPublishedTrueOrderByCreatedAtDesc();
    List<Course> findByCategoryAndIsPublishedTrueOrderByCreatedAtDesc(String category);
    List<Course> findAllByOrderByCreatedAtDesc();
    boolean existsBySlug(String slug);
}
