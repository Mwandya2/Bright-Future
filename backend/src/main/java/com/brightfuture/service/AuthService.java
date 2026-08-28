package com.brightfuture.service;

import com.brightfuture.config.JwtTokenProvider;
import com.brightfuture.dto.auth.AuthResponse;
import com.brightfuture.dto.auth.LoginRequest;
import com.brightfuture.dto.auth.SignupRequest;
import com.brightfuture.dto.auth.UserDto;
import com.brightfuture.entity.Role;
import com.brightfuture.entity.User;
import com.brightfuture.exception.BadRequestException;
import com.brightfuture.exception.ResourceNotFoundException;
import com.brightfuture.exception.UnauthorizedException;
import com.brightfuture.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final String adminEmail;

    public AuthService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtTokenProvider tokenProvider,
            @Value("${app.admin.email:admin@brightfuture.best.com}") String adminEmail) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenProvider = tokenProvider;
        this.adminEmail = adminEmail;
    }

    @Transactional
    public AuthResponse signup(SignupRequest req) {
        String email = req.getEmail().trim().toLowerCase();
        if (userRepository.existsByEmailIgnoreCase(email)) {
            throw new BadRequestException("An account with this email already exists.");
        }

        User user = User.builder()
                .email(email)
                .passwordHash(passwordEncoder.encode(req.getPassword()))
                .fullName(req.getFullName().trim())
                .phone(req.getPhone() != null ? req.getPhone().trim() : null)
                .role(Role.STUDENT)
                .build();

        user = userRepository.save(user);

        String token = tokenProvider.generateToken(user);
        return new AuthResponse(token, "Bearer", UserDto.fromEntity(user));
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest req) {
        String email = req.getEmail().trim().toLowerCase();
        User user = userRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new UnauthorizedException("Invalid email or password."));

        if (!passwordEncoder.matches(req.getPassword(), user.getPasswordHash())) {
            throw new UnauthorizedException("Invalid email or password.");
        }

        String token = tokenProvider.generateToken(user);
        return new AuthResponse(token, "Bearer", UserDto.fromEntity(user));
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
