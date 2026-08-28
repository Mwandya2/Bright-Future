package com.brightfuture.entity;

public enum EnrollmentStatus {
    ACTIVE,
    COMPLETED,
    CANCELLED;

    public static EnrollmentStatus fromString(String val) {
        if (val == null) return ACTIVE;
        try {
            return EnrollmentStatus.valueOf(val.toUpperCase());
        } catch (IllegalArgumentException e) {
            return ACTIVE;
        }
    }
}
