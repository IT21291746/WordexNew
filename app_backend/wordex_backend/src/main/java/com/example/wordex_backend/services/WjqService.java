package com.example.wordex_backend.services;

import com.example.wordex_backend.model.Wjq;
import com.example.wordex_backend.repository.WjqRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class WjqService {

    @Autowired
    private WjqRepository wjqRepository;

    // Save an IQ question
    public Wjq saveWjqQuestion(Wjq wjq) {
        System.out.println("Saving IQ Question: " + wjq);
        return wjqRepository.save(wjq);
    }

    // Get all IQ questions
    public List<Wjq> getAllWjqQuestions() {
        return wjqRepository.findAll();
    }

    // Get a specific IQ question by ID
    public Optional<Wjq> getWjqQuestionById(String id) {
        return wjqRepository.findById(id);
    }

    // Get random IQ questions
    public List<Wjq> getRandomQuestions(int count) {
        List<Wjq> allQuestions = wjqRepository.findAll();
        if (allQuestions.size() < count) {
            count = allQuestions.size();
        }
        Collections.shuffle(allQuestions);
        return allQuestions.stream().limit(count).collect(Collectors.toList());
    }

    // Delete an IQ question by ID
    public void deleteWjqQuestion(String id) {
        wjqRepository.deleteById(id);
    }
}
