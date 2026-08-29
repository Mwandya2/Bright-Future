package com.brightfuture.exception;

/**
 * Sign-in refused because the account's phone number has not been confirmed.
 *
 * <p>Distinct from UnauthorizedException so the client can tell "wrong
 * password" from "right password, finish verifying" and send the user to the
 * code screen instead of making them guess.
 */
public class PhoneNotVerifiedException extends RuntimeException {
    public PhoneNotVerifiedException(String message) {
        super(message);
    }
}
