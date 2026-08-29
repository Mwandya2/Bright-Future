package com.brightfuture.service;

import com.brightfuture.entity.User;
import com.brightfuture.entity.VerificationChannel;
import com.brightfuture.entity.VerificationCode;
import com.brightfuture.exception.BadRequestException;
import com.brightfuture.repository.VerificationCodeRepository;
import com.brightfuture.service.notify.EmailSender;
import com.brightfuture.service.notify.SmsSender;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;

/**
 * One-time codes for confirming a phone number or email address.
 *
 * <p>Codes are six digits, hashed before storage, valid for ten minutes, and
 * limited to five attempts. Sending is rate limited per user and channel, so a
 * signup form cannot be turned into a way of texting someone repeatedly at the
 * hub's expense.
 */
@Service
public class VerificationService {

    private static final Logger log = LoggerFactory.getLogger(VerificationService.class);
    private static final SecureRandom RANDOM = new SecureRandom();

    private static final Duration VALIDITY = Duration.ofMinutes(10);
    private static final int MAX_ATTEMPTS = 5;
    private static final Duration RATE_WINDOW = Duration.ofHours(1);
    private static final int MAX_SENDS_PER_WINDOW = 5;

    private final VerificationCodeRepository codeRepository;
    private final PasswordEncoder passwordEncoder;
    private final SmsSender smsSender;
    private final EmailSender emailSender;

    /**
     * Runs a failed-attempt increment in its own transaction. Without this the
     * BadRequestException that reports the failure rolls the increment back,
     * and the attempt limit never bites.
     */
    private final TransactionTemplate ownTransaction;

    @Value("${app.verification.log-codes:false}")
    private boolean logCodes;

    public VerificationService(VerificationCodeRepository codeRepository,
                               PasswordEncoder passwordEncoder,
                               SmsSender smsSender,
                               EmailSender emailSender,
                               PlatformTransactionManager transactionManager) {
        this.codeRepository = codeRepository;
        this.passwordEncoder = passwordEncoder;
        this.smsSender = smsSender;
        this.emailSender = emailSender;
        this.ownTransaction = new TransactionTemplate(transactionManager);
        this.ownTransaction.setPropagationBehavior(
                TransactionDefinition.PROPAGATION_REQUIRES_NEW);
    }

    public boolean canSendSms() {
        return smsSender.isConfigured();
    }

    /**
     * Issues a code and sends it.
     *
     * @return false when the provider could not be reached, so the caller can
     *         tell the user to try again rather than silently doing nothing
     */
    @Transactional
    public boolean sendCode(User user, VerificationChannel channel, String destination) {
        Instant since = Instant.now().minus(RATE_WINDOW);
        long recent = codeRepository.countByUserAndChannelAndCreatedAtAfter(user, channel, since);
        if (recent >= MAX_SENDS_PER_WINDOW) {
            throw new BadRequestException(
                    "Too many codes requested. Please wait an hour and try again.");
        }

        String code = sixDigits();
        VerificationCode record = new VerificationCode(
                user, channel, passwordEncoder.encode(code), destination,
                Instant.now().plus(VALIDITY));
        codeRepository.save(record);

        // A development escape hatch: with no provider configured there is no
        // other way to complete a signup locally. Never enabled in production -
        // it puts a working credential in the log.
        if (logCodes) {
            log.warn("VERIFICATION CODE for {} via {}: {}", destination, channel, code);
        }

        String message = channel == VerificationChannel.PHONE
                ? "Your Bright Future code is " + code + ". It expires in 10 minutes."
                : null;

        if (channel == VerificationChannel.PHONE) {
            return smsSender.send(destination, message) || logCodes;
        }
        return emailSender.send(destination, "Confirm your Bright Future email",
                emailHtml(code)) || logCodes;
    }

    /**
     * Checks a code and consumes it.
     *
     * <p>Deliberately NOT @Transactional. A failed attempt increments the
     * counter and then throws; inside a transaction that throw rolls the
     * increment back, leaving the attempt limit permanently at zero and the
     * code open to brute force. Each save here commits on its own.
     *
     * @throws BadRequestException with a message safe to show the user
     */
    public void verify(User user, VerificationChannel channel, String submitted) {
        VerificationCode record = codeRepository
                .findFirstByUserAndChannelAndConsumedAtIsNullOrderByCreatedAtDesc(user, channel)
                .orElseThrow(() -> new BadRequestException(
                        "No code is waiting. Request a new one."));

        if (record.isExpired()) {
            throw new BadRequestException("That code has expired. Request a new one.");
        }
        if (record.getAttempts() >= MAX_ATTEMPTS) {
            throw new BadRequestException(
                    "Too many incorrect attempts. Request a new code.");
        }

        String cleaned = submitted == null ? "" : submitted.replaceAll("\\D", "");
        if (!passwordEncoder.matches(cleaned, record.getCodeHash())) {
            ownTransaction.executeWithoutResult(
                    status -> codeRepository.incrementAttempts(record.getId()));
            int left = MAX_ATTEMPTS - (record.getAttempts() + 1);
            throw new BadRequestException(left > 0
                    ? "That code is not right. " + left + " attempt(s) left."
                    : "Too many incorrect attempts. Request a new code.");
        }

        record.setConsumedAt(Instant.now());
        codeRepository.save(record);
    }

    private static String sixDigits() {
        // 100000-999999, so it never renders with a leading zero that a user
        // might drop when typing it back.
        return String.valueOf(100000 + RANDOM.nextInt(900000));
    }

    private static String emailHtml(String code) {
        return """
            <div style="font-family:system-ui,sans-serif;max-width:420px">
              <h2 style="color:#0d253d">Confirm your email</h2>
              <p style="color:#4a5568">Enter this code in the Bright Future app:</p>
              <p style="font-size:30px;letter-spacing:6px;font-weight:700;color:#533afd">%s</p>
              <p style="color:#718096;font-size:13px">
                It expires in 10 minutes. If you did not sign up, ignore this email.
              </p>
            </div>
            """.formatted(code);
    }
}
