package com.brightfuture.dto.course;

import com.brightfuture.dto.auth.UserDto;
import com.brightfuture.entity.Enrollment;
import com.brightfuture.entity.EnrollmentStatus;

import java.time.Instant;
import java.util.UUID;

public class EnrollmentDto {
    private UUID id;
    private UserDto user;
    private CourseDto course;
    private EnrollmentStatus status;
    private Integer progress;
    private Instant createdAt;

    public EnrollmentDto() {}

    public EnrollmentDto(UUID id, UserDto user, CourseDto course, EnrollmentStatus status, Integer progress, Instant createdAt) {
        this.id = id;
        this.user = user;
        this.course = course;
        this.status = status;
        this.progress = progress;
        this.createdAt = createdAt;
    }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private UUID id;
        private UserDto user;
        private CourseDto course;
        private EnrollmentStatus status;
        private Integer progress;
        private Instant createdAt;

        public Builder id(UUID id) { this.id = id; return this; }
        public Builder user(UserDto user) { this.user = user; return this; }
        public Builder course(CourseDto course) { this.course = course; return this; }
        public Builder status(EnrollmentStatus status) { this.status = status; return this; }
        public Builder progress(Integer progress) { this.progress = progress; return this; }
        public Builder createdAt(Instant createdAt) { this.createdAt = createdAt; return this; }

        public EnrollmentDto build() {
            return new EnrollmentDto(id, user, course, status, progress, createdAt);
        }
    }

    public static EnrollmentDto fromEntity(Enrollment enrollment) {
        if (enrollment == null) return null;
        return EnrollmentDto.builder()
                .id(enrollment.getId())
                .user(UserDto.fromEntity(enrollment.getUser()))
                .course(CourseDto.fromEntity(enrollment.getCourse()))
                .status(enrollment.getStatus())
                .progress(enrollment.getProgress())
                .createdAt(enrollment.getCreatedAt())
                .build();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UserDto getUser() { return user; }
    public void setUser(UserDto user) { this.user = user; }
    public CourseDto getCourse() { return course; }
    public void setCourse(CourseDto course) { this.course = course; }
    public EnrollmentStatus getStatus() { return status; }
    public void setStatus(EnrollmentStatus status) { this.status = status; }
    public Integer getProgress() { return progress; }
    public void setProgress(Integer progress) { this.progress = progress; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
