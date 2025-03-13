package com.example.wordex_backend.repository;

import com.example.wordex_backend.model.Racq;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RacqRepository extends MongoRepository<Racq, String> {
    // Custom query to find questions by a keyword
    List<Racq> findByQuestionContainingIgnoreCase(String keyword);
}
