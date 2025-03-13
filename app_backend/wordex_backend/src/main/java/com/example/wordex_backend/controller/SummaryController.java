package com.example.wordex_backend.controller;

import com.example.wordex_backend.model.Summary;
import com.example.wordex_backend.services.SummaryServices;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;  // Import HttpStatus
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@CrossOrigin(origins = "http://localhost:3000") // Allow frontend access
@RequestMapping("/quiz")
public class SummaryController {

    @Autowired
    private SummaryServices summaryService;

    // Save quiz summary
    @PostMapping("/saveSummary")
    public ResponseEntity<String> saveQuizSummary(@RequestBody Summary summary) {
        summaryService.saveSummary(summary);
        return ResponseEntity.status(HttpStatus.CREATED).body("Quiz summary saved successfully!");
    }

    // Get all summaries for a user
    @GetMapping("/summaries/{userId}")
    public ResponseEntity<List<Summary>> getSummariesByUser(@PathVariable String userId) {
        List<Summary> summaries = summaryService.getSummariesByUserId(userId);
        return ResponseEntity.ok(summaries);
    }

    // Get a specific summary by ID
    @GetMapping("/summary/{id}")
    public ResponseEntity<Optional<Summary>> getSummaryById(@PathVariable String id) {
        Optional<Summary> summary = summaryService.getSummaryById(id);
        return ResponseEntity.ok(summary);
    }

    // Delete a summary by ID
    @DeleteMapping("/deleteSummary/{id}")
    public ResponseEntity<String> deleteSummary(@PathVariable String id) {
        summaryService.deleteSummary(id);
        return ResponseEntity.ok("Summary deleted successfully!");
    }
}
