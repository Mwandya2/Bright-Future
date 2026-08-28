package com.brightfuture.entity;

public enum Role {
    STUDENT,
    INSTRUCTOR,
    ADMIN;

    public static Role fromString(String val) {
        if (val == null) return STUDENT;
        try {
            return Role.valueOf(val.toUpperCase());
        } catch (IllegalArgumentException e) {
            return STUDENT;
        }
    }
}
