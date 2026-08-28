package com.brightfuture.dto.print;

import com.brightfuture.dto.auth.UserDto;
import com.brightfuture.entity.OrderStatus;
import com.brightfuture.entity.PrintOrder;
import com.brightfuture.entity.ServiceType;

import java.time.Instant;
import java.util.UUID;

public class PrintOrderDto {
    private UUID id;
    private UserDto user;
    private ServiceType serviceType;
    private String description;
    private Integer copies;
    private Boolean color;
    private OrderStatus status;
    private Integer estimatedPrice;
    private Instant createdAt;

    public PrintOrderDto() {}

    public PrintOrderDto(UUID id, UserDto user, ServiceType serviceType, String description, Integer copies, Boolean color, OrderStatus status, Integer estimatedPrice, Instant createdAt) {
        this.id = id;
        this.user = user;
        this.serviceType = serviceType;
        this.description = description;
        this.copies = copies;
        this.color = color;
        this.status = status;
        this.estimatedPrice = estimatedPrice;
        this.createdAt = createdAt;
    }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private UUID id;
        private UserDto user;
        private ServiceType serviceType;
        private String description;
        private Integer copies;
        private Boolean color;
        private OrderStatus status;
        private Integer estimatedPrice;
        private Instant createdAt;

        public Builder id(UUID id) { this.id = id; return this; }
        public Builder user(UserDto user) { this.user = user; return this; }
        public Builder serviceType(ServiceType serviceType) { this.serviceType = serviceType; return this; }
        public Builder description(String description) { this.description = description; return this; }
        public Builder copies(Integer copies) { this.copies = copies; return this; }
        public Builder color(Boolean color) { this.color = color; return this; }
        public Builder status(OrderStatus status) { this.status = status; return this; }
        public Builder estimatedPrice(Integer estimatedPrice) { this.estimatedPrice = estimatedPrice; return this; }
        public Builder createdAt(Instant createdAt) { this.createdAt = createdAt; return this; }

        public PrintOrderDto build() {
            return new PrintOrderDto(id, user, serviceType, description, copies, color, status, estimatedPrice, createdAt);
        }
    }

    public static PrintOrderDto fromEntity(PrintOrder order) {
        if (order == null) return null;
        return PrintOrderDto.builder()
                .id(order.getId())
                .user(UserDto.fromEntity(order.getUser()))
                .serviceType(order.getServiceType())
                .description(order.getDescription())
                .copies(order.getCopies())
                .color(order.getColor())
                .status(order.getStatus())
                .estimatedPrice(order.getEstimatedPrice())
                .createdAt(order.getCreatedAt())
                .build();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UserDto getUser() { return user; }
    public void setUser(UserDto user) { this.user = user; }
    public ServiceType getServiceType() { return serviceType; }
    public void setServiceType(ServiceType serviceType) { this.serviceType = serviceType; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Integer getCopies() { return copies; }
    public void setCopies(Integer copies) { this.copies = copies; }
    public Boolean getColor() { return color; }
    public void setColor(Boolean color) { this.color = color; }
    public OrderStatus getStatus() { return status; }
    public void setStatus(OrderStatus status) { this.status = status; }
    public Integer getEstimatedPrice() { return estimatedPrice; }
    public void setEstimatedPrice(Integer estimatedPrice) { this.estimatedPrice = estimatedPrice; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
