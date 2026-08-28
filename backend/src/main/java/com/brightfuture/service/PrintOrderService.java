package com.brightfuture.service;

import com.brightfuture.dto.print.CreatePrintOrderRequest;
import com.brightfuture.dto.print.PrintOrderDto;
import com.brightfuture.entity.OrderStatus;
import com.brightfuture.entity.PrintOrder;
import com.brightfuture.entity.ServiceType;
import com.brightfuture.entity.User;
import com.brightfuture.exception.ResourceNotFoundException;
import com.brightfuture.repository.PrintOrderRepository;
import com.brightfuture.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class PrintOrderService {

    private final PrintOrderRepository printOrderRepository;
    private final UserRepository userRepository;

    public PrintOrderService(PrintOrderRepository printOrderRepository, UserRepository userRepository) {
        this.printOrderRepository = printOrderRepository;
        this.userRepository = userRepository;
    }

    private static final Map<ServiceType, Integer> BASE_PRICES = Map.of(
            ServiceType.DOCUMENT, 200,
            ServiceType.POSTER, 8000,
            ServiceType.BANNER, 25000,
            ServiceType.BUSINESS_CARD, 15000,
            ServiceType.PHOTO, 1000
    );

    @Transactional(readOnly = true)
    public List<PrintOrderDto> getUserOrders(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return printOrderRepository.findByUserOrderByCreatedAtDesc(user).stream()
                .map(PrintOrderDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PrintOrderDto> getAllOrders() {
        return printOrderRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(PrintOrderDto::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public PrintOrderDto createOrder(UUID userId, CreatePrintOrderRequest req) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        int copies = Math.max(1, req.getCopies() != null ? req.getCopies() : 1);
        boolean isColor = Boolean.TRUE.equals(req.getColor());
        int unitPrice = BASE_PRICES.getOrDefault(req.getServiceType(), 200);
        int estimatedPrice = (int) Math.round(unitPrice * copies * (isColor ? 1.5 : 1.0));

        PrintOrder order = PrintOrder.builder()
                .user(user)
                .serviceType(req.getServiceType())
                .description(req.getDescription() != null ? req.getDescription().trim() : null)
                .copies(copies)
                .color(isColor)
                .status(OrderStatus.SUBMITTED)
                .estimatedPrice(estimatedPrice)
                .build();

        return PrintOrderDto.fromEntity(printOrderRepository.save(order));
    }

    @Transactional
    public PrintOrderDto updateStatus(UUID orderId, OrderStatus status) {
        PrintOrder order = printOrderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Print order not found"));
        order.setStatus(status);
        return PrintOrderDto.fromEntity(printOrderRepository.save(order));
    }
}
