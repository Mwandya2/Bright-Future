package com.brightfuture.controller;

import com.brightfuture.config.SecurityUtils;
import com.brightfuture.dto.booking.BookingDto;
import com.brightfuture.dto.booking.CreateBookingRequest;
import com.brightfuture.dto.booking.UpdateBookingStatusRequest;
import com.brightfuture.dto.common.ApiResponse;
import com.brightfuture.service.LabBookingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/bookings")
@Tag(name = "Lab Bookings", description = "Endpoints for workstation lab reservations")
public class LabBookingController {

    private final LabBookingService labBookingService;
    private final SecurityUtils securityUtils;

    public LabBookingController(LabBookingService labBookingService, SecurityUtils securityUtils) {
        this.labBookingService = labBookingService;
        this.securityUtils = securityUtils;
    }

    @GetMapping("/my")
    @Operation(summary = "Get current user's lab bookings")
    public ResponseEntity<ApiResponse<List<BookingDto>>> getMyBookings() {
        UUID currentUserId = securityUtils.getCurrentUserId();
        List<BookingDto> bookings = labBookingService.getUserBookings(currentUserId);
        return ResponseEntity.ok(ApiResponse.ok(bookings));
    }

    @PostMapping
    @Operation(summary = "Create a new lab booking reservation")
    public ResponseEntity<ApiResponse<BookingDto>> createBooking(@Valid @RequestBody CreateBookingRequest request) {
        UUID currentUserId = securityUtils.getCurrentUserId();
        BookingDto booking = labBookingService.createBooking(currentUserId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Booking requested successfully", booking));
    }

    @PatchMapping("/{id}/cancel")
    @Operation(summary = "Cancel a user's own booking")
    public ResponseEntity<ApiResponse<BookingDto>> cancelBooking(@PathVariable UUID id) {
        UUID currentUserId = securityUtils.getCurrentUserId();
        BookingDto booking = labBookingService.cancelBooking(currentUserId, id);
        return ResponseEntity.ok(ApiResponse.ok("Booking cancelled", booking));
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Get all lab bookings across all users (Admin only)")
    public ResponseEntity<ApiResponse<List<BookingDto>>> getAllBookings() {
        List<BookingDto> bookings = labBookingService.getAllBookings();
        return ResponseEntity.ok(ApiResponse.ok(bookings));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Update booking status (Admin only)")
    public ResponseEntity<ApiResponse<BookingDto>> updateStatus(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateBookingStatusRequest request) {
        BookingDto booking = labBookingService.updateStatus(id, request.getStatus());
        return ResponseEntity.ok(ApiResponse.ok("Booking status updated", booking));
    }
}
