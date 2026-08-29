package com.brightfuture.service;

import com.brightfuture.dto.course.CourseDto;
import com.brightfuture.dto.course.CreateCourseRequest;
import com.brightfuture.dto.course.UpdateCourseRequest;
import com.brightfuture.entity.Course;
import com.brightfuture.exception.ResourceNotFoundException;
import com.brightfuture.repository.CourseRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class CourseService {

    private final CourseRepository courseRepository;

    public CourseService(CourseRepository courseRepository) {
        this.courseRepository = courseRepository;
    }

    @Transactional(readOnly = true)
    public List<CourseDto> getPublishedCourses(String category) {
        List<Course> courses;
        if (category != null && !category.isBlank() && !category.equalsIgnoreCase("all")) {
            courses = courseRepository.findByCategoryAndIsPublishedTrueOrderByCreatedAtDesc(category);
        } else {
            courses = courseRepository.findByIsPublishedTrueOrderByCreatedAtDesc();
        }
        return courses.stream().map(CourseDto::fromEntity).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<CourseDto> getAllCourses() {
        return courseRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(CourseDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public CourseDto getCourseBySlugOrId(String slugOrId) {
        Course course;
        try {
            UUID id = UUID.fromString(slugOrId);
            course = courseRepository.findById(id)
                    .orElseGet(() -> courseRepository.findBySlug(slugOrId)
                            .orElseThrow(() -> new ResourceNotFoundException("Course not found with id or slug: " + slugOrId)));
        } catch (IllegalArgumentException e) {
            course = courseRepository.findBySlug(slugOrId)
                    .orElseThrow(() -> new ResourceNotFoundException("Course not found with slug: " + slugOrId));
        }
        return CourseDto.fromEntity(course);
    }

    public Course findEntityById(UUID id) {
        return courseRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found with id: " + id));
    }

    @Transactional
    public CourseDto createCourse(CreateCourseRequest req) {
        String slug = req.getSlug();
        if (slug == null || slug.isBlank()) {
            slug = slugify(req.getTitle()) + "-" + UUID.randomUUID().toString().substring(0, 4);
        }

        Course course = Course.builder()
                .title(req.getTitle().trim())
                .slug(slug)
                .summary(req.getSummary())
                .description(req.getDescription())
                .category(req.getCategory() != null ? req.getCategory() : "ict")
                .level(req.getLevel())
                .price(req.getPrice() != null ? req.getPrice() : 0)
                .durationWeeks(req.getDurationWeeks() != null ? req.getDurationWeeks() : 4)
                .instructorName(req.getInstructorName())
                .coverGradient(req.getCoverGradient() != null ? req.getCoverGradient() : "mint")
                .isPublished(req.getIsPublished() != null ? req.getIsPublished() : false)
                .deliveryMode(req.getDeliveryMode())
                .build();

        return CourseDto.fromEntity(courseRepository.save(course));
    }

    @Transactional
    public CourseDto updateCourse(UUID id, UpdateCourseRequest req) {
        Course course = findEntityById(id);

        if (req.getTitle() != null) course.setTitle(req.getTitle().trim());
        if (req.getSlug() != null) course.setSlug(req.getSlug().trim());
        if (req.getSummary() != null) course.setSummary(req.getSummary());
        if (req.getDescription() != null) course.setDescription(req.getDescription());
        if (req.getCategory() != null) course.setCategory(req.getCategory());
        if (req.getLevel() != null) course.setLevel(req.getLevel());
        if (req.getPrice() != null) course.setPrice(req.getPrice());
        if (req.getDurationWeeks() != null) course.setDurationWeeks(req.getDurationWeeks());
        if (req.getInstructorName() != null) course.setInstructorName(req.getInstructorName());
        if (req.getCoverGradient() != null) course.setCoverGradient(req.getCoverGradient());
        if (req.getIsPublished() != null) course.setIsPublished(req.getIsPublished());
        if (req.getDeliveryMode() != null) course.setDeliveryMode(req.getDeliveryMode());

        return CourseDto.fromEntity(courseRepository.save(course));
    }

    @Transactional
    public CourseDto togglePublish(UUID id, Boolean isPublished) {
        Course course = findEntityById(id);
        course.setIsPublished(isPublished != null ? isPublished : !course.getIsPublished());
        return CourseDto.fromEntity(courseRepository.save(course));
    }

    @Transactional
    public void deleteCourse(UUID id) {
        if (!courseRepository.existsById(id)) {
            throw new ResourceNotFoundException("Course not found with id: " + id);
        }
        courseRepository.deleteById(id);
    }

    private String slugify(String input) {
        if (input == null) return "";
        return input.toLowerCase()
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("^-|-$", "");
    }
}
