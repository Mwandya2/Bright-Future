package com.brightfuture.service;

import com.brightfuture.config.JwtTokenProvider;
import com.brightfuture.dto.auth.AuthResponse;
import com.brightfuture.dto.auth.LoginRequest;
import com.brightfuture.dto.auth.SignupRequest;
import com.brightfuture.dto.auth.UserDto;
import com.brightfuture.entity.Role;
import com.brightfuture.entity.VerificationChannel;
import com.brightfuture.entity.User;
import com.brightfuture.exception.BadRequestException;
import com.brightfuture.exception.ResourceNotFoundException;
import com.brightfuture.exception.PhoneNotVerifiedException;
import com.brightfuture.exception.UnauthorizedException;
import com.brightfuture.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class AuthService {

    private static final org.slf4j.Logger log =
            org.slf4j.LoggerFactory.getLogger(AuthService.class);

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final String adminEmail;
    private final VerificationService verificationService;

    public AuthService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtTokenProvider tokenProvider,
            @Value("${app.admin.email:admin@brightfuture.best.com}") String adminEmail,
            VerificationService verificationService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenProvider = tokenProvider;
        this.adminEmail = adminEmail;
        this.verificationService = verificationService;
    }

    @Transactional
    public AuthResponse signup(SignupRequest req) {
        String email = req.getEmail().trim().toLowerCase();
        if (userRepository.existsByEmailIgnoreCase(email)) {
            throw new BadRequestException("An account with this email already exists.");
        }

        // A phone number is now required, and normalised the same way payments
        // normalise it, so one account maps to one real handset.
        String phone = ClickPesaService.normalizeTzPhone(req.getPhone());
        if (phone == null) {
            throw new BadRequestException(
                    "Enter a Tanzanian mobile number, for example 0712 345 678.");
        }
        if (userRepository.existsByPhone(phone)) {
            throw new BadRequestException(
                    "An account with this phone number already exists.");
        }

        User user = User.builder()
                .email(email)
                .passwordHash(passwordEncoder.encode(req.getPassword()))
                .fullName(req.getFullName().trim())
                .phone(phone)
                .role(Role.STUDENT)
                .phoneVerified(false)
                .emailVerified(false)
                .build();

        user = userRepository.save(user);

        // No token yet. The account is not usable until the code sent to that
        // handset comes back, which is what ties it to a real person.
        verificationService.sendCode(user, VerificationChannel.PHONE, phone);
        if (user.getEmail() != null) {
            try {
                verificationService.sendCode(user, VerificationChannel.EMAIL, user.getEmail());
            } catch (RuntimeException e) {
                // Email is not required to sign in; never fail a signup on it.
                log.warn("Could not send the email verification code", e);
            }
        }

        return new AuthResponse(null, "Bearer", UserDto.fromEntity(user));
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest req) {
        String email = req.getEmail().trim().toLowerCase();
        User user = userRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new UnauthorizedException("Invalid email or password."));

        if (!passwordEncoder.matches(req.getPassword(), user.getPasswordHash())) {
            throw new UnauthorizedException("Invalid email or password.");
        }

        // Checked after the password so this cannot be used to discover which
        // addresses have accounts.
        if (!user.getPhoneVerified() && user.getRole() != Role.ADMIN) {
            throw new PhoneNotVerifiedException(
                    "Confirm the code sent to your phone to finish signing up.");
        }

        String token = tokenProvider.generateToken(user);
        return new AuthResponse(token, "Bearer", UserDto.fromEntity(user));
    }

    /**
     * Confirms the code sent to the account's phone and completes signup.
     *
     * @return a token, since this is the point the account becomes usable
     */
    @Transactional
    public AuthResponse verifyPhone(String email, String code) {
        User user = requireUser(email);
        if (user.getPhoneVerified()) {
            // Already done: hand back a token rather than an error, so a
            // retried request does not strand someone on the code screen.
            return new AuthResponse(tokenProvider.generateToken(user), "Bearer",
                    UserDto.fromEntity(user));
        }

        verificationService.verify(user, VerificationChannel.PHONE, code);
        user.setPhoneVerified(true);
        user = userRepository.save(user);

        return new AuthResponse(tokenProvider.generateToken(user), "Bearer",
                UserDto.fromEntity(user));
    }

    /** Confirms the code sent to the account's email. Does not gate sign-in. */
    @Transactional
    public UserDto verifyEmail(String email, String code) {
        User user = requireUser(email);
        if (!user.getEmailVerified()) {
            verificationService.verify(user, VerificationChannel.EMAIL, code);
            user.setEmailVerified(true);
            user = userRepository.save(user);
        }
        return UserDto.fromEntity(user);
    }

    /** Issues a fresh code. Rate limited inside VerificationService. */
    @Transactional
    public void resendCode(String email, String rawChannel) {
        User user = requireUser(email);
        VerificationChannel channel = "EMAIL".equalsIgnoreCase(rawChannel)
                ? VerificationChannel.EMAIL
                : VerificationChannel.PHONE;

        boolean alreadyDone = channel == VerificationChannel.PHONE
                ? user.getPhoneVerified()
                : user.getEmailVerified();
        if (alreadyDone) {
            throw new BadRequestException("That is already confirmed.");
        }

        String destination = channel == VerificationChannel.PHONE
                ? user.getPhone()
                : user.getEmail();
        verificationService.sendCode(user, channel, destination);
    }

    private User requireUser(String email) {
        return userRepository.findByEmailIgnoreCase(email.trim().toLowerCase())
                .orElseThrow(() -> new BadRequestException(
                        "No account was found for that email."));
    }

    @Transactional(readOnly = true)
    public AuthResponse adminLogin(LoginRequest req) {
        String email = req.getEmail().trim().toLowerCase();
        User user = userRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new UnauthorizedException("Invalid email or password."));

        if (!passwordEncoder.matches(req.getPassword(), user.getPasswordHash())) {
            throw new UnauthorizedException("Invalid email or password.");
        }

        if (user.getRole() != Role.ADMIN || !email.equalsIgnoreCase(adminEmail.trim())) {
            throw new UnauthorizedException("This account is not authorized as an administrator.");
        }

        String token = tokenProvider.generateToken(user);
        return new AuthResponse(token, "Bearer", UserDto.fromEntity(user));
    }

    @Transactional(readOnly = true)
    public UserDto getCurrentUser(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return UserDto.fromEntity(user);
    }
}
