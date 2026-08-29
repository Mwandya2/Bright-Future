package com.brightfuture.entity;

/**
 * How a course reaches the student, which decides whether it may be paid for
 * inside the iOS app.
 *
 * <p>Apple requires in-app purchase for digital content consumed inside an app
 * (App Store Review Guideline 3.1.1), but explicitly forbids it for goods and
 * services consumed elsewhere (3.1.3(e), 3.1.5(a)). A course taught in person
 * at the hub is the second kind, so it can be charged for directly with
 * ClickPesa on any platform. A course delivered inside the app is the first
 * kind, so on iOS the app reserves a place free of charge instead.
 *
 * <p>Android has no equivalent restriction: both modes pay in-app there.
 */
public enum DeliveryMode {
    /** Taught at the Bright Future hub. A physical service. */
    IN_PERSON,

    /** Delivered inside the app or on the website. Digital content. */
    ONLINE
}
