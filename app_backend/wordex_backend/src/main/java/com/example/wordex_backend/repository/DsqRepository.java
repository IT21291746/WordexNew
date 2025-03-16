package com.example.wordex_backend.repository;

import com.example.wordex_backend.model.Dsq;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DsqRepository extends MongoRepository<Dsq, String> {
    // Custom query to find questions by a keyword
    List<Dsq> findByQuestionContainingIgnoreCase(String keyword);
}
