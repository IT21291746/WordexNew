package com.example.wordex_backend.repository;

import com.example.wordex_backend.model.Iq;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IqRepository extends MongoRepository<Iq, String> {
    // Custom query to find questions by a keyword
    List<Iq> findByQuestionContainingIgnoreCase(String keyword);
}
