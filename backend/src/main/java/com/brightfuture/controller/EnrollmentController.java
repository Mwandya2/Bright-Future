package com.brightfuture.controller;

import com.brightfuture.config.SecurityUtils;
import com.brightfuture.dto.common.ApiResponse;
import com.brightfuture.dto.course.EnrollmentDto;
import com.brightfuture.dto.course.UpdateProgressRequest;
import com.brightfuture.service.EnrollmentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/enrollments")
@Tag(name = "Enrollments", description = "Endpoints for course enrollments and learning progress")
public class EnrollmentController {

    private final EnrollmentService enrollmentService;
    private final SecurityUtils securityUtils;

    public EnrollmentController(EnrollmentService enrollmentService, SecurityUtils securityUtils) {
        this.enrollmentService = enrollmentService;
        this.securityUtils = securityUtils;
    }

    @GetMapping("/my")
    @Operation(summary = "Get current user's enrolled courses")
    public ResponseEntity<ApiResponse<List<EnrollmentDto>>> getMyEnrollments() {
        UUID currentUserId = securityUtils.getCurrentUserId();
        List<EnrollmentDto> enrollments = enrollmentService.getUserEnrollments(currentUserId);
        return ResponseEntity.ok(ApiResponse.ok(enrollments));
    }

    @PostMapping
    @Operation(summary = "Enroll current user into a course")
    public ResponseEntity<ApiResponse<EnrollmentDto>> enroll(@RequestBody Map<String, String> body) {
        UUID currentUserId = securityUtils.getCurrentUserId();
        String courseIdStr = body.get("courseId");
        if (courseIdStr == null || courseIdStr.isBlank()) {
            courseIdStr = body.get("course_id");
        }
        if (courseIdStr == null || courseIdStr.isBlank()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("courseId is required"));
        }

        UUID courseId = UUID.fromString(courseIdStr);
        EnrollmentDto enrollment = enrollmentService.enroll(currentUserId, courseId);
        return ResponseEntity.ok(ApiResponse.ok("Enrolled successfully", enrollment));
    }

    @PatchMapping("/{id}/progress")
    @Operation(summary = "Update learning progress for an enrollment")
    public ResponseEntity<ApiResponse<EnrollmentDto>> updateProgress(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateProgressRequest request) {
        UUID currentUserId = securityUtils.getCurrentUserId();
        EnrollmentDto updated = enrollmentService.updateProgress(currentUserId, id, request.getProgress());
        return ResponseEntity.ok(ApiResponse.ok("Progress updated", updated));
    }
}
