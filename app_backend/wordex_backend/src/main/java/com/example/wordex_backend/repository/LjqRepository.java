package com.example.wordex_backend.repository;

import com.example.wordex_backend.model.Ljq;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LjqRepository extends MongoRepository<Ljq, String> {
    // Custom query to find questions by a keyword
    List<Ljq> findByQuestionContainingIgnoreCase(String keyword);
}
