package com.example.wordex_backend.services;

import com.example.wordex_backend.model.Summary;
import com.example.wordex_backend.repository.SummaryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Optional;

@Service
public class SummaryServices {

    @Autowired
    private SummaryRepository summaryRepository;

    // Save a new summary
    public Summary saveSummary(Summary summary) {
        summary.setTimestamp(new Date()); // Set current timestamp
        return summaryRepository.save(summary);
    }

    // Get all summaries for a specific user
    public List<Summary> getSummariesByUserId(String userId) {
        return summaryRepository.findByUserId(userId);
    }

    // Get a summary by ID
    public Optional<Summary> getSummaryById(String id) {
        return summaryRepository.findById(id);
    }

    // Delete a summary by ID
    public void deleteSummary(String id) {
        summaryRepository.deleteById(id);
    }
}
