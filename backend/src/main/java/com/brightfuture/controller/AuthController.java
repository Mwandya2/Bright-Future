package com.brightfuture.controller;

import com.brightfuture.config.SecurityUtils;
import com.brightfuture.dto.auth.AuthResponse;
import com.brightfuture.dto.auth.LoginRequest;
import com.brightfuture.dto.auth.ResendCodeRequest;
import com.brightfuture.dto.auth.SignupRequest;
import com.brightfuture.dto.auth.VerifyCodeRequest;
import com.brightfuture.dto.auth.UserDto;
import com.brightfuture.dto.common.ApiResponse;
import com.brightfuture.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Authentication", description = "Endpoints for user registration, authentication and profile retrieval")
public class AuthController {

    private final AuthService authService;
    private final SecurityUtils securityUtils;

    public AuthController(AuthService authService, SecurityUtils securityUtils) {
        this.authService = authService;
        this.securityUtils = securityUtils;
    }

    @PostMapping("/signup")
    @Operation(summary = "Register a new student account")
    public ResponseEntity<ApiResponse<AuthResponse>> signup(@Valid @RequestBody SignupRequest request) {
        AuthResponse response = authService.signup(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Account created successfully", response));
    }

    @PostMapping("/login")
    @Operation(summary = "Authenticate user with email and password")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.ok("Login successful", response));
    }

    @PostMapping("/admin-login")
    @Operation(summary = "Authenticate designated administrator")
    public ResponseEntity<ApiResponse<AuthResponse>> adminLogin(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.adminLogin(request);
        return ResponseEntity.ok(ApiResponse.ok("Admin login successful", response));
    }

    @GetMapping("/me")
    @Operation(summary = "Get currently authenticated user details")
    public ResponseEntity<ApiResponse<UserDto>> getCurrentUser() {
        UUID currentUserId = securityUtils.getCurrentUserId();
        UserDto userDto = authService.getCurrentUser(currentUserId);
        return ResponseEntity.ok(ApiResponse.ok(userDto));
    }

    @PostMapping("/verify-phone")
    @Operation(summary = "Confirm the code sent by SMS and finish signing up")
    public ResponseEntity<ApiResponse<AuthResponse>> verifyPhone(
            @Valid @RequestBody VerifyCodeRequest req) {
        AuthResponse result = authService.verifyPhone(req.getEmail(), req.getCode());
        return ResponseEntity.ok(ApiResponse.ok("Phone confirmed.", result));
    }

    @PostMapping("/verify-email")
    @Operation(summary = "Confirm the code sent by email")
    public ResponseEntity<ApiResponse<UserDto>> verifyEmail(
            @Valid @RequestBody VerifyCodeRequest req) {
        UserDto user = authService.verifyEmail(req.getEmail(), req.getCode());
        return ResponseEntity.ok(ApiResponse.ok("Email confirmed.", user));
    }

    @PostMapping("/resend-code")
    @Operation(summary = "Send a fresh verification code")
    public ResponseEntity<ApiResponse<String>> resendCode(
            @Valid @RequestBody ResendCodeRequest req) {
        authService.resendCode(req.getEmail(), req.getChannel());
        return ResponseEntity.ok(ApiResponse.message("A new code is on its way."));
    }
}
