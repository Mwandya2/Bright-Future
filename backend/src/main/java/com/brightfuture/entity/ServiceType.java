package com.brightfuture.entity;

public enum ServiceType {
    DOCUMENT,
    POSTER,
    BANNER,
    BUSINESS_CARD,
    PHOTO;

    public static ServiceType fromString(String val) {
        if (val == null) return DOCUMENT;
        try {
            return ServiceType.valueOf(val.toUpperCase().replace("-", "_"));
        } catch (IllegalArgumentException e) {
            return DOCUMENT;
        }
    }
}
