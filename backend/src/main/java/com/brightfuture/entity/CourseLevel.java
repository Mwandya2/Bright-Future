package com.brightfuture.entity;

public enum CourseLevel {
    BEGINNER,
    INTERMEDIATE,
    ADVANCED;

    public static CourseLevel fromString(String val) {
        if (val == null) return BEGINNER;
        try {
            return CourseLevel.valueOf(val.toUpperCase());
        } catch (IllegalArgumentException e) {
            return BEGINNER;
        }
    }
}
