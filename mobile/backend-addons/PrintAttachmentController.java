package com.brightfuture.controller;

import com.brightfuture.config.SecurityUtils;
import com.brightfuture.dto.common.ApiResponse;
import com.brightfuture.dto.print.PrintOrderDto;
import com.brightfuture.entity.PrintOrder;
import com.brightfuture.exception.BadRequestException;
import com.brightfuture.exception.ResourceNotFoundException;
import com.brightfuture.exception.UnauthorizedException;
import com.brightfuture.repository.PrintOrderRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

/**
 * Accepts the file that goes with a print order.
 *
 * Drop this file into com.brightfuture.controller, add the `attachmentUrl`
 * column to PrintOrder + PrintOrderDto, and set the multipart limits in
 * application.yml (see backend-addons/README.md).
 */
@RestController
@RequestMapping("/api/orders")
@Tag(name = "Print Orders", description = "File attachments for print orders")
public class PrintAttachmentController {

    private static final long MAX_BYTES = 25L * 1024 * 1024; // 25 MB

    private static final Set<String> ALLOWED = Set.of(
            "pdf", "doc", "docx", "ppt", "pptx", "xls", "xlsx",
            "jpg", "jpeg", "png", "txt");

    private final PrintOrderRepository printOrderRepository;
    private final SecurityUtils securityUtils;

    @Value("${app.uploads.directory:uploads}")
    private String uploadDirectory;

    public PrintAttachmentController(PrintOrderRepository printOrderRepository,
                                     SecurityUtils securityUtils) {
        this.printOrderRepository = printOrderRepository;
        this.securityUtils = securityUtils;
    }

    @PostMapping("/{id}/attachment")
    @Operation(summary = "Attach the file to be printed to an existing order")
    public ResponseEntity<ApiResponse<PrintOrderDto>> upload(
            @PathVariable UUID id,
            @RequestParam("file") MultipartFile file) throws IOException {

        UUID currentUserId = securityUtils.getCurrentUserId();

        PrintOrder order = printOrderRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Print order not found"));

        if (!order.getUser().getId().equals(currentUserId)) {
            throw new UnauthorizedException("You cannot attach a file to someone else's order.");
        }

        if (file.isEmpty()) {
            throw new BadRequestException("The uploaded file is empty.");
        }
        if (file.getSize() > MAX_BYTES) {
            throw new BadRequestException("Files must be 25 MB or smaller.");
        }

        String original = file.getOriginalFilename() == null ? "upload" : file.getOriginalFilename();
        String extension = "";
        int dot = original.lastIndexOf('.');
        if (dot >= 0 && dot < original.length() - 1) {
            extension = original.substring(dot + 1).toLowerCase(Locale.ROOT);
        }
        if (!ALLOWED.contains(extension)) {
            throw new BadRequestException("That file type is not accepted for printing.");
        }

        String storedName = id + "-" + UUID.randomUUID() + "." + extension;
        String url = store(file, storedName);

        order.setAttachmentUrl(url);
        PrintOrder saved = printOrderRepository.save(order);

        return ResponseEntity.ok(
                ApiResponse.ok("File attached successfully", PrintOrderDto.fromEntity(saved)));
    }

    /**
     * Writes the upload to local disk and returns a reference.
     *
     * Replace the body of this method with a Supabase Storage or S3 upload for
     * a real deployment - nothing else in this class needs to change.
     */
    private String store(MultipartFile file, String storedName) throws IOException {
        Path directory = Paths.get(uploadDirectory).toAbsolutePath().normalize();
        Files.createDirectories(directory);
        Path target = directory.resolve(storedName);
        try (var in = file.getInputStream()) {
            Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
        }
        return "/uploads/" + storedName;
    }
}
