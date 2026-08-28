package com.brightfuture.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "print_orders")
public class PrintOrder {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid", updatable = false, nullable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "service_type", nullable = false)
    private ServiceType serviceType = ServiceType.DOCUMENT;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private Integer copies = 1;

    @Column(nullable = false)
    private Boolean color = false;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OrderStatus status = OrderStatus.SUBMITTED;

    @Column(name = "estimated_price")
    private Integer estimatedPrice;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    public PrintOrder() {}

    public PrintOrder(UUID id, User user, ServiceType serviceType, String description, Integer copies, Boolean color, OrderStatus status, Integer estimatedPrice, Instant createdAt) {
        this.id = id;
        this.user = user;
        this.serviceType = serviceType != null ? serviceType : ServiceType.DOCUMENT;
        this.description = description;
        this.copies = copies != null ? copies : 1;
        this.color = color != null ? color : false;
        this.status = status != null ? status : OrderStatus.SUBMITTED;
        this.estimatedPrice = estimatedPrice;
        this.createdAt = createdAt;
    }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private UUID id;
        private User user;
        private ServiceType serviceType = ServiceType.DOCUMENT;
        private String description;
        private Integer copies = 1;
        private Boolean color = false;
        private OrderStatus status = OrderStatus.SUBMITTED;
        private Integer estimatedPrice;
        private Instant createdAt;

        public Builder id(UUID id) { this.id = id; return this; }
        public Builder user(User user) { this.user = user; return this; }
        public Builder serviceType(ServiceType serviceType) { this.serviceType = serviceType; return this; }
        public Builder description(String description) { this.description = description; return this; }
        public Builder copies(Integer copies) { this.copies = copies; return this; }
        public Builder color(Boolean color) { this.color = color; return this; }
        public Builder status(OrderStatus status) { this.status = status; return this; }
        public Builder estimatedPrice(Integer estimatedPrice) { this.estimatedPrice = estimatedPrice; return this; }
        public Builder createdAt(Instant createdAt) { this.createdAt = createdAt; return this; }

        public PrintOrder build() {
            return new PrintOrder(id, user, serviceType, description, copies, color, status, estimatedPrice, createdAt);
        }
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
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
