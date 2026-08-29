package com.brightfuture.service.notify;

/** Sends transactional email. */
public interface EmailSender {

    boolean send(String to, String subject, String html);

    boolean isConfigured();
}
