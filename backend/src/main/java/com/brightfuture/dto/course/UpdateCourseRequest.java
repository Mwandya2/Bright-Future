package com.brightfuture.dto.course;

import com.brightfuture.entity.CourseLevel;

public class UpdateCourseRequest {
    private String title;
    private String slug;
    private String summary;
    private String description;
    private String category;
    private CourseLevel level;
    private Integer price;
    private Integer durationWeeks;
    private String instructorName;
    private String coverGradient;
    private Boolean isPublished;

    public UpdateCourseRequest() {}

    public UpdateCourseRequest(String title, String slug, String summary, String description, String category, CourseLevel level, Integer price, Integer durationWeeks, String instructorName, String coverGradient, Boolean isPublished) {
        this.title = title;
        this.slug = slug;
        this.summary = summary;
        this.description = description;
        this.category = category;
        this.level = level;
        this.price = price;
        this.durationWeeks = durationWeeks;
        this.instructorName = instructorName;
        this.coverGradient = coverGradient;
        this.isPublished = isPublished;
    }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private String title;
        private String slug;
        private String summary;
        private String description;
        private String category;
        private CourseLevel level;
        private Integer price;
        private Integer durationWeeks;
        private String instructorName;
        private String coverGradient;
        private Boolean isPublished;

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

        public UpdateCourseRequest build() {
            return new UpdateCourseRequest(title, slug, summary, description, category, level, price, durationWeeks, instructorName, coverGradient, isPublished);
        }
    }

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
}
