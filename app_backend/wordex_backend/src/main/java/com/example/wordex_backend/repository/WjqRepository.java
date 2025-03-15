package com.example.wordex_backend.repository;

import com.example.wordex_backend.model.Wjq;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WjqRepository extends MongoRepository<Wjq, String> {
    // Custom query to find questions by a keyword
    List<Wjq> findByQuestionContainingIgnoreCase(String keyword);
}
