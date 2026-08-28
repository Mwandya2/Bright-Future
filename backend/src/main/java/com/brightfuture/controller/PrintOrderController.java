package com.brightfuture.controller;

import com.brightfuture.config.SecurityUtils;
import com.brightfuture.dto.common.ApiResponse;
import com.brightfuture.dto.print.CreatePrintOrderRequest;
import com.brightfuture.dto.print.PrintOrderDto;
import com.brightfuture.dto.print.UpdatePrintOrderStatusRequest;
import com.brightfuture.service.PrintOrderService;
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
@RequestMapping("/api/orders")
@Tag(name = "Print Orders", description = "Endpoints for printing and reprographic service orders")
public class PrintOrderController {

    private final PrintOrderService printOrderService;
    private final SecurityUtils securityUtils;

    public PrintOrderController(PrintOrderService printOrderService, SecurityUtils securityUtils) {
        this.printOrderService = printOrderService;
        this.securityUtils = securityUtils;
    }

    @GetMapping("/my")
    @Operation(summary = "Get current user's print orders")
    public ResponseEntity<ApiResponse<List<PrintOrderDto>>> getMyOrders() {
        UUID currentUserId = securityUtils.getCurrentUserId();
        List<PrintOrderDto> orders = printOrderService.getUserOrders(currentUserId);
        return ResponseEntity.ok(ApiResponse.ok(orders));
    }

    @PostMapping
    @Operation(summary = "Submit a new print or reprographic order")
    public ResponseEntity<ApiResponse<PrintOrderDto>> createOrder(@Valid @RequestBody CreatePrintOrderRequest request) {
        UUID currentUserId = securityUtils.getCurrentUserId();
        PrintOrderDto order = printOrderService.createOrder(currentUserId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Order submitted successfully", order));
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Get all print orders across all users (Admin only)")
    public ResponseEntity<ApiResponse<List<PrintOrderDto>>> getAllOrders() {
        List<PrintOrderDto> orders = printOrderService.getAllOrders();
        return ResponseEntity.ok(ApiResponse.ok(orders));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Update print order status (Admin only)")
    public ResponseEntity<ApiResponse<PrintOrderDto>> updateStatus(
            @PathVariable UUID id,
            @Valid @RequestBody UpdatePrintOrderStatusRequest request) {
        PrintOrderDto order = printOrderService.updateStatus(id, request.getStatus());
        return ResponseEntity.ok(ApiResponse.ok("Order status updated", order));
    }
}
