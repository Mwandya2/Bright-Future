package com.brightfuture.dto.booking;

import com.brightfuture.dto.auth.UserDto;
import com.brightfuture.entity.BookingStatus;
import com.brightfuture.entity.LabBooking;
import com.brightfuture.entity.WorkstationType;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

public class BookingDto {
    private UUID id;
    private UserDto user;
    private WorkstationType workstationType;
    private LocalDate bookingDate;
    private LocalTime startTime;
    private Integer durationHours;
    private BookingStatus status;
    private String notes;
    private Instant createdAt;

    public BookingDto() {}

    public BookingDto(UUID id, UserDto user, WorkstationType workstationType, LocalDate bookingDate, LocalTime startTime, Integer durationHours, BookingStatus status, String notes, Instant createdAt) {
        this.id = id;
        this.user = user;
        this.workstationType = workstationType;
        this.bookingDate = bookingDate;
        this.startTime = startTime;
        this.durationHours = durationHours;
        this.status = status;
        this.notes = notes;
        this.createdAt = createdAt;
    }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private UUID id;
        private UserDto user;
        private WorkstationType workstationType;
        private LocalDate bookingDate;
        private LocalTime startTime;
        private Integer durationHours;
        private BookingStatus status;
        private String notes;
        private Instant createdAt;

        public Builder id(UUID id) { this.id = id; return this; }
        public Builder user(UserDto user) { this.user = user; return this; }
        public Builder workstationType(WorkstationType workstationType) { this.workstationType = workstationType; return this; }
        public Builder bookingDate(LocalDate bookingDate) { this.bookingDate = bookingDate; return this; }
        public Builder startTime(LocalTime startTime) { this.startTime = startTime; return this; }
        public Builder durationHours(Integer durationHours) { this.durationHours = durationHours; return this; }
        public Builder status(BookingStatus status) { this.status = status; return this; }
        public Builder notes(String notes) { this.notes = notes; return this; }
        public Builder createdAt(Instant createdAt) { this.createdAt = createdAt; return this; }

        public BookingDto build() {
            return new BookingDto(id, user, workstationType, bookingDate, startTime, durationHours, status, notes, createdAt);
        }
    }

    public static BookingDto fromEntity(LabBooking booking) {
        if (booking == null) return null;
        return BookingDto.builder()
                .id(booking.getId())
                .user(UserDto.fromEntity(booking.getUser()))
                .workstationType(booking.getWorkstationType())
                .bookingDate(booking.getBookingDate())
                .startTime(booking.getStartTime())
                .durationHours(booking.getDurationHours())
                .status(booking.getStatus())
                .notes(booking.getNotes())
                .createdAt(booking.getCreatedAt())
                .build();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UserDto getUser() { return user; }
    public void setUser(UserDto user) { this.user = user; }
    public WorkstationType getWorkstationType() { return workstationType; }
    public void setWorkstationType(WorkstationType workstationType) { this.workstationType = workstationType; }
    public LocalDate getBookingDate() { return bookingDate; }
    public void setBookingDate(LocalDate bookingDate) { this.bookingDate = bookingDate; }
    public LocalTime getStartTime() { return startTime; }
    public void setStartTime(LocalTime startTime) { this.startTime = startTime; }
    public Integer getDurationHours() { return durationHours; }
    public void setDurationHours(Integer durationHours) { this.durationHours = durationHours; }
    public BookingStatus getStatus() { return status; }
    public void setStatus(BookingStatus status) { this.status = status; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
