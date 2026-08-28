package com.brightfuture.dto.booking;

import com.brightfuture.entity.WorkstationType;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;
import java.time.LocalTime;

public class CreateBookingRequest {

    @NotNull(message = "Workstation type is required")
    private WorkstationType workstationType = WorkstationType.COMPUTER;

    @NotNull(message = "Booking date is required")
    private LocalDate bookingDate;

    @NotNull(message = "Start time is required")
    private LocalTime startTime;

    @Min(value = 1, message = "Duration must be at least 1 hour")
    private Integer durationHours = 1;

    private String notes;

    public CreateBookingRequest() {}

    public CreateBookingRequest(WorkstationType workstationType, LocalDate bookingDate, LocalTime startTime, Integer durationHours, String notes) {
        this.workstationType = workstationType != null ? workstationType : WorkstationType.COMPUTER;
        this.bookingDate = bookingDate;
        this.startTime = startTime;
        this.durationHours = durationHours != null ? durationHours : 1;
        this.notes = notes;
    }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private WorkstationType workstationType = WorkstationType.COMPUTER;
        private LocalDate bookingDate;
        private LocalTime startTime;
        private Integer durationHours = 1;
        private String notes;

        public Builder workstationType(WorkstationType workstationType) { this.workstationType = workstationType; return this; }
        public Builder bookingDate(LocalDate bookingDate) { this.bookingDate = bookingDate; return this; }
        public Builder startTime(LocalTime startTime) { this.startTime = startTime; return this; }
        public Builder durationHours(Integer durationHours) { this.durationHours = durationHours; return this; }
        public Builder notes(String notes) { this.notes = notes; return this; }

        public CreateBookingRequest build() {
            return new CreateBookingRequest(workstationType, bookingDate, startTime, durationHours, notes);
        }
    }

    public WorkstationType getWorkstationType() { return workstationType; }
    public void setWorkstationType(WorkstationType workstationType) { this.workstationType = workstationType; }
    public LocalDate getBookingDate() { return bookingDate; }
    public void setBookingDate(LocalDate bookingDate) { this.bookingDate = bookingDate; }
    public LocalTime getStartTime() { return startTime; }
    public void setStartTime(LocalTime startTime) { this.startTime = startTime; }
    public Integer getDurationHours() { return durationHours; }
    public void setDurationHours(Integer durationHours) { this.durationHours = durationHours; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
