package com.brightfuture.entity;

public enum BookingStatus {
    PENDING,
    CONFIRMED,
    COMPLETED,
    CANCELLED;

    public static BookingStatus fromString(String val) {
        if (val == null) return PENDING;
        try {
            return BookingStatus.valueOf(val.toUpperCase());
        } catch (IllegalArgumentException e) {
            return PENDING;
        }
    }
}
