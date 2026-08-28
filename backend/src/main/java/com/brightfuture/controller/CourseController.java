package com.brightfuture.controller;

import com.brightfuture.dto.common.ApiResponse;
import com.brightfuture.dto.course.CourseDto;
import com.brightfuture.dto.course.CreateCourseRequest;
import com.brightfuture.dto.course.UpdateCourseRequest;
import com.brightfuture.service.CourseService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/courses")
@Tag(name = "Courses", description = "Endpoints for course catalogue and course management")
public class CourseController {

    private final CourseService courseService;

    public CourseController(CourseService courseService) {
        this.courseService = courseService;
    }

    @GetMapping
    @Operation(summary = "Get published courses with optional category filter")
    public ResponseEntity<ApiResponse<List<CourseDto>>> getCourses(
            @RequestParam(required = false) String category) {
        List<CourseDto> courses = courseService.getPublishedCourses(category);
        return ResponseEntity.ok(ApiResponse.ok(courses));
    }

    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Get all courses including unpublished (Admin only)")
    public ResponseEntity<ApiResponse<List<CourseDto>>> getAllCourses() {
        List<CourseDto> courses = courseService.getAllCourses();
        return ResponseEntity.ok(ApiResponse.ok(courses));
    }

    @GetMapping("/{slugOrId}")
    @Operation(summary = "Get single course by slug or UUID")
    public ResponseEntity<ApiResponse<CourseDto>> getCourse(@PathVariable String slugOrId) {
        CourseDto course = courseService.getCourseBySlugOrId(slugOrId);
        return ResponseEntity.ok(ApiResponse.ok(course));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Create a new course (Admin only)")
    public ResponseEntity<ApiResponse<CourseDto>> createCourse(@Valid @RequestBody CreateCourseRequest request) {
        CourseDto created = courseService.createCourse(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Course created successfully", created));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Update course details (Admin only)")
    public ResponseEntity<ApiResponse<CourseDto>> updateCourse(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateCourseRequest request) {
        CourseDto updated = courseService.updateCourse(id, request);
        return ResponseEntity.ok(ApiResponse.ok("Course updated successfully", updated));
    }

    @PatchMapping("/{id}/publish")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Toggle or set published status (Admin only)")
    public ResponseEntity<ApiResponse<CourseDto>> togglePublish(
            @PathVariable UUID id,
            @RequestParam(required = false) Boolean isPublished) {
        CourseDto updated = courseService.togglePublish(id, isPublished);
        return ResponseEntity.ok(ApiResponse.ok("Course publication status updated", updated));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete course (Admin only)")
    public ResponseEntity<ApiResponse<Void>> deleteCourse(@PathVariable UUID id) {
        courseService.deleteCourse(id);
        return ResponseEntity.ok(ApiResponse.message("Course deleted successfully"));
    }
}
