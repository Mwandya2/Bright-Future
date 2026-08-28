package com.brightfuture.repository;

import com.brightfuture.entity.BookingStatus;
import com.brightfuture.entity.LabBooking;
import com.brightfuture.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface LabBookingRepository extends JpaRepository<LabBooking, UUID> {
    List<LabBooking> findByUserOrderByBookingDateDescStartTimeDesc(User user);
    List<LabBooking> findAllByOrderByBookingDateDescStartTimeDesc();
    List<LabBooking> findByBookingDate(LocalDate bookingDate);
    long countByStatus(BookingStatus status);
}
