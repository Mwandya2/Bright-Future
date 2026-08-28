package com.brightfuture.service;

import com.brightfuture.dto.contact.ContactMessageDto;
import com.brightfuture.dto.contact.ContactMessageRequest;
import com.brightfuture.entity.ContactMessage;
import com.brightfuture.repository.ContactMessageRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ContactMessageService {

    private final ContactMessageRepository contactMessageRepository;

    public ContactMessageService(ContactMessageRepository contactMessageRepository) {
        this.contactMessageRepository = contactMessageRepository;
    }

    @Transactional
    public ContactMessageDto saveMessage(ContactMessageRequest req) {
        ContactMessage msg = ContactMessage.builder()
                .name(req.getName().trim())
                .email(req.getEmail().trim().toLowerCase())
                .subject(req.getSubject() != null ? req.getSubject().trim() : null)
                .message(req.getMessage().trim())
                .build();

        return ContactMessageDto.fromEntity(contactMessageRepository.save(msg));
    }

    @Transactional(readOnly = true)
    public List<ContactMessageDto> getAllMessages() {
        return contactMessageRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(ContactMessageDto::fromEntity)
                .collect(Collectors.toList());
    }
}
