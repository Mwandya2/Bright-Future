package com.brightfuture.dto.auth;

import jakarta.validation.constraints.NotBlank;

public class ResendCodeRequest {

    @NotBlank(message = "Email is required")
    private String email;

    /** PHONE or EMAIL. Defaults to PHONE, which is the one that gates sign-in. */
    private String channel;

    public ResendCodeRequest() {}

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getChannel() { return channel; }
    public void setChannel(String channel) { this.channel = channel; }
}
