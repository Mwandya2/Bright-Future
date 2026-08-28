package com.brightfuture.dto.contact;

import com.brightfuture.entity.ContactMessage;

import java.time.Instant;
import java.util.UUID;

public class ContactMessageDto {
    private UUID id;
    private String name;
    private String email;
    private String subject;
    private String message;
    private Instant createdAt;

    public ContactMessageDto() {}

    public ContactMessageDto(UUID id, String name, String email, String subject, String message, Instant createdAt) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.subject = subject;
        this.message = message;
        this.createdAt = createdAt;
    }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private UUID id;
        private String name;
        private String email;
        private String subject;
        private String message;
        private Instant createdAt;

        public Builder id(UUID id) { this.id = id; return this; }
        public Builder name(String name) { this.name = name; return this; }
        public Builder email(String email) { this.email = email; return this; }
        public Builder subject(String subject) { this.subject = subject; return this; }
        public Builder message(String message) { this.message = message; return this; }
        public Builder createdAt(Instant createdAt) { this.createdAt = createdAt; return this; }

        public ContactMessageDto build() {
            return new ContactMessageDto(id, name, email, subject, message, createdAt);
        }
    }

    public static ContactMessageDto fromEntity(ContactMessage msg) {
        if (msg == null) return null;
        return ContactMessageDto.builder()
                .id(msg.getId())
                .name(msg.getName())
                .email(msg.getEmail())
                .subject(msg.getSubject())
                .message(msg.getMessage())
                .createdAt(msg.getCreatedAt())
                .build();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
