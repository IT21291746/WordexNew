package com.example.wordex_backend.repository;

import com.example.wordex_backend.model.Summary;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;

public interface SummaryRepository extends MongoRepository<Summary, String> {
    List<Summary> findByUserId(String userId); // Get all summaries for a specific user
}
