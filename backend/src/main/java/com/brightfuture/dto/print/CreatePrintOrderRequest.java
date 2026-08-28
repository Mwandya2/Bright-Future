package com.brightfuture.dto.print;

import com.brightfuture.entity.ServiceType;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public class CreatePrintOrderRequest {

    @NotNull(message = "Service type is required")
    private ServiceType serviceType = ServiceType.DOCUMENT;

    private String description;

    @Min(value = 1, message = "Copies must be at least 1")
    private Integer copies = 1;

    private Boolean color = false;

    public CreatePrintOrderRequest() {}

    public CreatePrintOrderRequest(ServiceType serviceType, String description, Integer copies, Boolean color) {
        this.serviceType = serviceType != null ? serviceType : ServiceType.DOCUMENT;
        this.description = description;
        this.copies = copies != null ? copies : 1;
        this.color = color != null ? color : false;
    }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private ServiceType serviceType = ServiceType.DOCUMENT;
        private String description;
        private Integer copies = 1;
        private Boolean color = false;

        public Builder serviceType(ServiceType serviceType) { this.serviceType = serviceType; return this; }
        public Builder description(String description) { this.description = description; return this; }
        public Builder copies(Integer copies) { this.copies = copies; return this; }
        public Builder color(Boolean color) { this.color = color; return this; }

        public CreatePrintOrderRequest build() {
            return new CreatePrintOrderRequest(serviceType, description, copies, color);
        }
    }

    public ServiceType getServiceType() { return serviceType; }
    public void setServiceType(ServiceType serviceType) { this.serviceType = serviceType; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Integer getCopies() { return copies; }
    public void setCopies(Integer copies) { this.copies = copies; }
    public Boolean getColor() { return color; }
    public void setColor(Boolean color) { this.color = color; }
}
