package com.brightfuture.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "courses")
public class Course {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid", updatable = false, nullable = false)
    private UUID id;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, unique = true)
    private String slug;

    @Column(columnDefinition = "TEXT")
    private String summary;

    @Column(columnDefinition = "TEXT")
    private String description;

    private String category = "ict";

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CourseLevel level = CourseLevel.BEGINNER;

    private Integer price = 0;

    @Column(name = "duration_weeks")
    private Integer durationWeeks = 4;

    @Column(name = "instructor_name")
    private String instructorName;

    @Column(name = "cover_gradient")
    private String coverGradient = "mint";

    @Column(name = "is_published", nullable = false)
    private Boolean isPublished = false;

    /**
     * Decides whether iOS may take payment for this course in-app. Defaults to
     * IN_PERSON: the hub's courses are taught on site, and that is the mode
     * Apple permits a third-party gateway for.
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "delivery_mode", nullable = false)
    private DeliveryMode deliveryMode = DeliveryMode.IN_PERSON;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    public Course() {}

    public Course(UUID id, String title, String slug, String summary, String description, String category, CourseLevel level, Integer price, Integer durationWeeks, String instructorName, String coverGradient, Boolean isPublished, DeliveryMode deliveryMode, Instant createdAt) {
        this.id = id;
        this.title = title;
        this.slug = slug;
        this.summary = summary;
        this.description = description;
        this.category = category != null ? category : "ict";
        this.level = level != null ? level : CourseLevel.BEGINNER;
        this.price = price != null ? price : 0;
        this.durationWeeks = durationWeeks != null ? durationWeeks : 4;
        this.instructorName = instructorName;
        this.coverGradient = coverGradient != null ? coverGradient : "mint";
        this.isPublished = isPublished != null ? isPublished : false;
        this.deliveryMode = deliveryMode != null ? deliveryMode : DeliveryMode.IN_PERSON;
        this.createdAt = createdAt;
    }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private UUID id;
        private String title;
        private String slug;
        private String summary;
        private String description;
        private String category = "ict";
        private CourseLevel level = CourseLevel.BEGINNER;
        private Integer price = 0;
        private Integer durationWeeks = 4;
        private String instructorName;
        private String coverGradient = "mint";
        private Boolean isPublished = false;
        private DeliveryMode deliveryMode = DeliveryMode.IN_PERSON;
        private Instant createdAt;

        public Builder id(UUID id) { this.id = id; return this; }
        public Builder title(String title) { this.title = title; return this; }
        public Builder slug(String slug) { this.slug = slug; return this; }
        public Builder summary(String summary) { this.summary = summary; return this; }
        public Builder description(String description) { this.description = description; return this; }
        public Builder category(String category) { this.category = category; return this; }
        public Builder level(CourseLevel level) { this.level = level; return this; }
        public Builder price(Integer price) { this.price = price; return this; }
        public Builder durationWeeks(Integer durationWeeks) { this.durationWeeks = durationWeeks; return this; }
        public Builder instructorName(String instructorName) { this.instructorName = instructorName; return this; }
        public Builder coverGradient(String coverGradient) { this.coverGradient = coverGradient; return this; }
        public Builder isPublished(Boolean isPublished) { this.isPublished = isPublished; return this; }
        public Builder deliveryMode(DeliveryMode deliveryMode) { this.deliveryMode = deliveryMode; return this; }
        public Builder createdAt(Instant createdAt) { this.createdAt = createdAt; return this; }

        public Course build() {
            return new Course(id, title, slug, summary, description, category, level, price, durationWeeks, instructorName, coverGradient, isPublished, deliveryMode, createdAt);
        }
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }
    public String getSummary() { return summary; }
    public void setSummary(String summary) { this.summary = summary; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public CourseLevel getLevel() { return level; }
    public void setLevel(CourseLevel level) { this.level = level; }
    public Integer getPrice() { return price; }
    public void setPrice(Integer price) { this.price = price; }
    public Integer getDurationWeeks() { return durationWeeks; }
    public void setDurationWeeks(Integer durationWeeks) { this.durationWeeks = durationWeeks; }
    public String getInstructorName() { return instructorName; }
    public void setInstructorName(String instructorName) { this.instructorName = instructorName; }
    public String getCoverGradient() { return coverGradient; }
    public void setCoverGradient(String coverGradient) { this.coverGradient = coverGradient; }
    public Boolean getIsPublished() { return isPublished; }
    public void setIsPublished(Boolean isPublished) { this.isPublished = isPublished; }
    public DeliveryMode getDeliveryMode() { return deliveryMode; }
    public void setDeliveryMode(DeliveryMode deliveryMode) { this.deliveryMode = deliveryMode; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
