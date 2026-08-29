package com.brightfuture.service.notify;

/** Sends a text message. One implementation per provider. */
public interface SmsSender {

    /**
     * @param destination E.164 without the plus, e.g. 255712345678
     * @return true when the provider accepted it
     */
    boolean send(String destination, String message);

    /** False when credentials are missing, so callers can explain rather than fail. */
    boolean isConfigured();
}
