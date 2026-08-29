package com.brightfuture.repository;

import com.brightfuture.entity.User;
import com.brightfuture.entity.VerificationChannel;
import com.brightfuture.entity.VerificationCode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

public interface VerificationCodeRepository extends JpaRepository<VerificationCode, UUID> {

    /** The code a user should be entering right now. */
    Optional<VerificationCode> findFirstByUserAndChannelAndConsumedAtIsNullOrderByCreatedAtDesc(
            User user, VerificationChannel channel);

    /** How many codes went out recently, for rate limiting. */
    long countByUserAndChannelAndCreatedAtAfter(
            User user, VerificationChannel channel, Instant since);

    void deleteByUserAndChannel(User user, VerificationChannel channel);

    /**
     * Counts a failed attempt with a direct update, so it can be committed in
     * its own transaction rather than being rolled back by the exception that
     * reports the failure.
     */
    @Modifying
    @Query("update VerificationCode v set v.attempts = v.attempts + 1 where v.id = :id")
    void incrementAttempts(@Param("id") UUID id);
}
