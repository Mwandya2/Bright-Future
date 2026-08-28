package com.brightfuture.service;

import com.brightfuture.dto.booking.BookingDto;
import com.brightfuture.dto.booking.CreateBookingRequest;
import com.brightfuture.entity.BookingStatus;
import com.brightfuture.entity.LabBooking;
import com.brightfuture.entity.User;
import com.brightfuture.exception.BadRequestException;
import com.brightfuture.exception.ResourceNotFoundException;
import com.brightfuture.repository.LabBookingRepository;
import com.brightfuture.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class LabBookingService {

    private final LabBookingRepository labBookingRepository;
    private final UserRepository userRepository;

    public LabBookingService(LabBookingRepository labBookingRepository, UserRepository userRepository) {
        this.labBookingRepository = labBookingRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public List<BookingDto> getUserBookings(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return labBookingRepository.findByUserOrderByBookingDateDescStartTimeDesc(user).stream()
                .map(BookingDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<BookingDto> getAllBookings() {
        return labBookingRepository.findAllByOrderByBookingDateDescStartTimeDesc().stream()
                .map(BookingDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public BookingDto createBooking(UUID userId, CreateBookingRequest req) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        LabBooking booking = LabBooking.builder()
                .user(user)
                .workstationType(req.getWorkstationType())
                .bookingDate(req.getBookingDate())
                .startTime(req.getStartTime())
                .durationHours(req.getDurationHours() != null ? req.getDurationHours() : 1)
                .status(BookingStatus.PENDING)
                .notes(req.getNotes() != null ? req.getNotes().trim() : null)
                .build();

        return BookingDto.fromEntity(labBookingRepository.save(booking));
    }

    @Transactional
    public BookingDto cancelBooking(UUID userId, UUID bookingId) {
        LabBooking booking = labBookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found"));

        if (!booking.getUser().getId().equals(userId)) {
            throw new BadRequestException("You are not authorized to cancel this booking.");
        }

        booking.setStatus(BookingStatus.CANCELLED);
        return BookingDto.fromEntity(labBookingRepository.save(booking));
    }

    @Transactional
    public BookingDto updateStatus(UUID bookingId, BookingStatus status) {
        LabBooking booking = labBookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found"));
        booking.setStatus(status);
        return BookingDto.fromEntity(labBookingRepository.save(booking));
    }
}
