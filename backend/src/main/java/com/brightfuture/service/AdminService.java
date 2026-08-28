package com.brightfuture.service;

import com.brightfuture.dto.admin.AdminStatsDto;
import com.brightfuture.dto.auth.UserDto;
import com.brightfuture.entity.BookingStatus;
import com.brightfuture.entity.OrderStatus;
import com.brightfuture.entity.Role;
import com.brightfuture.entity.User;
import com.brightfuture.exception.BadRequestException;
import com.brightfuture.exception.ResourceNotFoundException;
import com.brightfuture.repository.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class AdminService {

    private final UserRepository userRepository;
    private final CourseRepository courseRepository;
    private final LabBookingRepository labBookingRepository;
    private final PrintOrderRepository printOrderRepository;
    private final ContactMessageRepository contactMessageRepository;
    private final String adminEmail;

    public AdminService(
            UserRepository userRepository,
            CourseRepository courseRepository,
            LabBookingRepository labBookingRepository,
            PrintOrderRepository printOrderRepository,
            ContactMessageRepository contactMessageRepository,
            @Value("${app.admin.email:admin@brightfuture.best.com}") String adminEmail) {
        this.userRepository = userRepository;
        this.courseRepository = courseRepository;
        this.labBookingRepository = labBookingRepository;
        this.printOrderRepository = printOrderRepository;
        this.contactMessageRepository = contactMessageRepository;
        this.adminEmail = adminEmail;
    }

    @Transactional(readOnly = true)
    public AdminStatsDto getSystemStats() {
        long totalUsers = userRepository.count();
        long totalCourses = courseRepository.count();
        long publishedCourses = courseRepository.findByIsPublishedTrueOrderByCreatedAtDesc().size();
        long totalBookings = labBookingRepository.count();
        long pendingBookings = labBookingRepository.countByStatus(BookingStatus.PENDING);
        long totalPrintOrders = printOrderRepository.count();
        long activePrintOrders = printOrderRepository.countByStatus(OrderStatus.SUBMITTED)
                + printOrderRepository.countByStatus(OrderStatus.IN_PROGRESS)
                + printOrderRepository.countByStatus(OrderStatus.READY);
        long totalContactMessages = contactMessageRepository.count();

        return AdminStatsDto.builder()
                .totalUsers(totalUsers)
                .totalCourses(totalCourses)
                .publishedCourses(publishedCourses)
                .totalBookings(totalBookings)
                .pendingBookings(pendingBookings)
                .totalPrintOrders(totalPrintOrders)
                .activePrintOrders(activePrintOrders)
                .totalContactMessages(totalContactMessages)
                .build();
    }

    @Transactional(readOnly = true)
    public List<UserDto> getAllUsers() {
        return userRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(UserDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public UserDto updateUserRole(UUID userId, Role newRole) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (newRole == Role.ADMIN) {
            throw new BadRequestException("Promoting to Admin via API is restricted.");
        }

        if (user.getEmail().equalsIgnoreCase(adminEmail.trim())) {
            throw new BadRequestException("The primary administrator's role cannot be modified.");
        }

        user.setRole(newRole);
        return UserDto.fromEntity(userRepository.save(user));
    }
}
