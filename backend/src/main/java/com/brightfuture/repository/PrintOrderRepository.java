package com.brightfuture.repository;

import com.brightfuture.entity.OrderStatus;
import com.brightfuture.entity.PrintOrder;
import com.brightfuture.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface PrintOrderRepository extends JpaRepository<PrintOrder, UUID> {
    List<PrintOrder> findByUserOrderByCreatedAtDesc(User user);
    List<PrintOrder> findAllByOrderByCreatedAtDesc();
    long countByStatus(OrderStatus status);
}
