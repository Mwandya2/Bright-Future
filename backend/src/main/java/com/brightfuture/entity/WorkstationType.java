package com.brightfuture.entity;

public enum WorkstationType {
    COMPUTER,
    GAMING,
    RESEARCH,
    PRINTING_STATION;

    public static WorkstationType fromString(String val) {
        if (val == null) return COMPUTER;
        try {
            return WorkstationType.valueOf(val.toUpperCase().replace("-", "_"));
        } catch (IllegalArgumentException e) {
            return COMPUTER;
        }
    }
}
