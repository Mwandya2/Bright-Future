package com.brightfuture.entity;

public enum OrderStatus {
    SUBMITTED,
    IN_PROGRESS,
    READY,
    COLLECTED,
    CANCELLED;

    public static OrderStatus fromString(String val) {
        if (val == null) return SUBMITTED;
        try {
            return OrderStatus.valueOf(val.toUpperCase().replace("-", "_"));
        } catch (IllegalArgumentException e) {
            return SUBMITTED;
        }
    }
}
