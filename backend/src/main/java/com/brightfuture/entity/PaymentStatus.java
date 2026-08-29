package com.brightfuture.entity;

/** Lifecycle of a course payment, as reported by ClickPesa. */
public enum PaymentStatus {
    /** Push sent, customer has not approved yet. No money has moved. */
    PENDING,

    /** ClickPesa confirmed the money was collected. The only state that grants enrolment. */
    PAID,

    /** Rejected, reversed or refunded. */
    FAILED,

    /** Cancelled on the handset. */
    CANCELLED
}
