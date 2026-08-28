package com.brightfuture.dto.admin;

public class AdminStatsDto {
    private long totalUsers;
    private long totalCourses;
    private long publishedCourses;
    private long totalBookings;
    private long pendingBookings;
    private long totalPrintOrders;
    private long activePrintOrders;
    private long totalContactMessages;

    public AdminStatsDto() {}

    public AdminStatsDto(long totalUsers, long totalCourses, long publishedCourses, long totalBookings, long pendingBookings, long totalPrintOrders, long activePrintOrders, long totalContactMessages) {
        this.totalUsers = totalUsers;
        this.totalCourses = totalCourses;
        this.publishedCourses = publishedCourses;
        this.totalBookings = totalBookings;
        this.pendingBookings = pendingBookings;
        this.totalPrintOrders = totalPrintOrders;
        this.activePrintOrders = activePrintOrders;
        this.totalContactMessages = totalContactMessages;
    }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private long totalUsers;
        private long totalCourses;
        private long publishedCourses;
        private long totalBookings;
        private long pendingBookings;
        private long totalPrintOrders;
        private long activePrintOrders;
        private long totalContactMessages;

        public Builder totalUsers(long totalUsers) { this.totalUsers = totalUsers; return this; }
        public Builder totalCourses(long totalCourses) { this.totalCourses = totalCourses; return this; }
        public Builder publishedCourses(long publishedCourses) { this.publishedCourses = publishedCourses; return this; }
        public Builder totalBookings(long totalBookings) { this.totalBookings = totalBookings; return this; }
        public Builder pendingBookings(long pendingBookings) { this.pendingBookings = pendingBookings; return this; }
        public Builder totalPrintOrders(long totalPrintOrders) { this.totalPrintOrders = totalPrintOrders; return this; }
        public Builder activePrintOrders(long activePrintOrders) { this.activePrintOrders = activePrintOrders; return this; }
        public Builder totalContactMessages(long totalContactMessages) { this.totalContactMessages = totalContactMessages; return this; }

        public AdminStatsDto build() {
            return new AdminStatsDto(totalUsers, totalCourses, publishedCourses, totalBookings, pendingBookings, totalPrintOrders, activePrintOrders, totalContactMessages);
        }
    }

    public long getTotalUsers() { return totalUsers; }
    public void setTotalUsers(long totalUsers) { this.totalUsers = totalUsers; }
    public long getTotalCourses() { return totalCourses; }
    public void setTotalCourses(long totalCourses) { this.totalCourses = totalCourses; }
    public long getPublishedCourses() { return publishedCourses; }
    public void setPublishedCourses(long publishedCourses) { this.publishedCourses = publishedCourses; }
    public long getTotalBookings() { return totalBookings; }
    public void setTotalBookings(long totalBookings) { this.totalBookings = totalBookings; }
    public long getPendingBookings() { return pendingBookings; }
    public void setPendingBookings(long pendingBookings) { this.pendingBookings = pendingBookings; }
    public long getTotalPrintOrders() { return totalPrintOrders; }
    public void setTotalPrintOrders(long totalPrintOrders) { this.totalPrintOrders = totalPrintOrders; }
    public long getActivePrintOrders() { return activePrintOrders; }
    public void setActivePrintOrders(long activePrintOrders) { this.activePrintOrders = activePrintOrders; }
    public long getTotalContactMessages() { return totalContactMessages; }
    public void setTotalContactMessages(long totalContactMessages) { this.totalContactMessages = totalContactMessages; }
}
