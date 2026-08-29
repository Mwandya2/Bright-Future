package com.brightfuture.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

/**
 * A one-time code sent to a phone or email address.
 *
 * <p>The code itself is never stored. Only a hash is kept, so a leaked database
 * does not hand out working codes - the same reason passwords are hashed.
 *
 * <p>Codes expire, count their failed attempts, and are consumed on use, so a
 * six-digit secret cannot be brute forced: a million possibilities against five
 * attempts in ten minutes is not a practical attack.
 */
@Entity
@Table(
    name = "verification_codes",
    indexes = {
        @Index(name = "idx_verification_user_channel", columnList = "user_id, channel")
    }
)
public class VerificationCode {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 8)
    private VerificationChannel channel;

    /** BCrypt hash of the six-digit code. */
    @Column(name = "code_hash", nullable = false, length = 100)
    private String codeHash;

    /** Where it was actually sent, for display and for auditing later. */
    @Column(name = "destination", nullable = false, length = 160)
    private String destination;

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    @Column(name = "consumed_at")
    private Instant consumedAt;

    @Column(nullable = false)
    private Integer attempts = 0;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    public VerificationCode() {}

    public VerificationCode(User user, VerificationChannel channel, String codeHash,
                            String destination, Instant expiresAt) {
        this.user = user;
        this.channel = channel;
        this.codeHash = codeHash;
        this.destination = destination;
        this.expiresAt = expiresAt;
        this.attempts = 0;
    }

    public boolean isExpired() {
        return expiresAt == null || Instant.now().isAfter(expiresAt);
    }

    public boolean isConsumed() {
        return consumedAt != null;
    }

    public UUID getId() { return id; }
    public User getUser() { return user; }
    public VerificationChannel getChannel() { return channel; }
    public String getCodeHash() { return codeHash; }
    public String getDestination() { return destination; }
    public Instant getExpiresAt() { return expiresAt; }
    public Instant getConsumedAt() { return consumedAt; }
    public void setConsumedAt(Instant consumedAt) { this.consumedAt = consumedAt; }
    public Integer getAttempts() { return attempts == null ? 0 : attempts; }
    public void setAttempts(Integer attempts) { this.attempts = attempts; }
    public Instant getCreatedAt() { return createdAt; }
}
