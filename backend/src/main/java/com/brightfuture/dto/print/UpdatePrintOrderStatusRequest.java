package com.brightfuture.dto.print;

import com.brightfuture.entity.OrderStatus;
import jakarta.validation.constraints.NotNull;

public class UpdatePrintOrderStatusRequest {

    @NotNull(message = "Status is required")
    private OrderStatus status;

    public UpdatePrintOrderStatusRequest() {}

    public UpdatePrintOrderStatusRequest(OrderStatus status) {
        this.status = status;
    }

    public OrderStatus getStatus() { return status; }
    public void setStatus(OrderStatus status) { this.status = status; }
}
