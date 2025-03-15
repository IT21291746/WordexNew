package com.example.wordex_backend.services;

import com.example.wordex_backend.model.Ljq;
import com.example.wordex_backend.repository.LjqRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class LjqService {

    @Autowired
    private LjqRepository ljqRepository;

    // Save an IQ question
    public Ljq saveLjqQuestion(Ljq ljq) {
        System.out.println("Saving IQ Question: " + ljq);
        return ljqRepository.save(ljq);
    }

    // Get all IQ questions
    public List<Ljq> getAllLjqQuestions() {
        return ljqRepository.findAll();
    }

    // Get a specific IQ question by ID
    public Optional<Ljq> getLjqQuestionById(String id) {
        return ljqRepository.findById(id);
    }

    // Get random IQ questions
    public List<Ljq> getRandomQuestions(int count) {
        List<Ljq> allQuestions = ljqRepository.findAll();
        if (allQuestions.size() < count) {
            count = allQuestions.size();
        }
        Collections.shuffle(allQuestions);
        return allQuestions.stream().limit(count).collect(Collectors.toList());
    }

    // Delete an IQ question by ID
    public void deleteLjqQuestion(String id) {
        ljqRepository.deleteById(id);
    }
}
