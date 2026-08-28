package com.brightfuture.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Entity
@Table(name = "lab_bookings")
public class LabBooking {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid", updatable = false, nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "workstation_type", nullable = false)
    private WorkstationType workstationType = WorkstationType.COMPUTER;

    @Column(name = "booking_date", nullable = false)
    private LocalDate bookingDate;

    @Column(name = "start_time", nullable = false)
    private LocalTime startTime;

    @Column(name = "duration_hours", nullable = false)
    private Integer durationHours = 1;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private BookingStatus status = BookingStatus.PENDING;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    public LabBooking() {}

    public LabBooking(UUID id, User user, WorkstationType workstationType, LocalDate bookingDate, LocalTime startTime, Integer durationHours, BookingStatus status, String notes, Instant createdAt) {
        this.id = id;
        this.user = user;
        this.workstationType = workstationType != null ? workstationType : WorkstationType.COMPUTER;
        this.bookingDate = bookingDate;
        this.startTime = startTime;
        this.durationHours = durationHours != null ? durationHours : 1;
        this.status = status != null ? status : BookingStatus.PENDING;
        this.notes = notes;
        this.createdAt = createdAt;
    }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private UUID id;
        private User user;
        private WorkstationType workstationType = WorkstationType.COMPUTER;
        private LocalDate bookingDate;
        private LocalTime startTime;
        private Integer durationHours = 1;
        private BookingStatus status = BookingStatus.PENDING;
        private String notes;
        private Instant createdAt;

        public Builder id(UUID id) { this.id = id; return this; }
        public Builder user(User user) { this.user = user; return this; }
        public Builder workstationType(WorkstationType workstationType) { this.workstationType = workstationType; return this; }
        public Builder bookingDate(LocalDate bookingDate) { this.bookingDate = bookingDate; return this; }
        public Builder startTime(LocalTime startTime) { this.startTime = startTime; return this; }
        public Builder durationHours(Integer durationHours) { this.durationHours = durationHours; return this; }
        public Builder status(BookingStatus status) { this.status = status; return this; }
        public Builder notes(String notes) { this.notes = notes; return this; }
        public Builder createdAt(Instant createdAt) { this.createdAt = createdAt; return this; }

        public LabBooking build() {
            return new LabBooking(id, user, workstationType, bookingDate, startTime, durationHours, status, notes, createdAt);
        }
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
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
