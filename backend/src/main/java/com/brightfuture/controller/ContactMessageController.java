package com.brightfuture.controller;

import com.brightfuture.dto.common.ApiResponse;
import com.brightfuture.dto.contact.ContactMessageDto;
import com.brightfuture.dto.contact.ContactMessageRequest;
import com.brightfuture.service.ContactMessageService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/contact")
@Tag(name = "Contact Messages", description = "Endpoints for public contact form inquiries")
public class ContactMessageController {

    private final ContactMessageService contactMessageService;

    public ContactMessageController(ContactMessageService contactMessageService) {
        this.contactMessageService = contactMessageService;
    }

    @PostMapping
    @Operation(summary = "Submit a public contact message")
    public ResponseEntity<ApiResponse<ContactMessageDto>> submitContactMessage(
            @Valid @RequestBody ContactMessageRequest request) {
        ContactMessageDto message = contactMessageService.saveMessage(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Message sent successfully. We will be in touch soon.", message));
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "List all contact inquiries (Admin only)")
    public ResponseEntity<ApiResponse<List<ContactMessageDto>>> getAllMessages() {
        List<ContactMessageDto> messages = contactMessageService.getAllMessages();
        return ResponseEntity.ok(ApiResponse.ok(messages));
    }
}
