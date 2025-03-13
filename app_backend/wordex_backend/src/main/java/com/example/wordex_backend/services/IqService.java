package com.example.wordex_backend.services;

import com.example.wordex_backend.model.Iq;
import com.example.wordex_backend.repository.IqRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class IqService {

    @Autowired
    private IqRepository iqRepository;

    // Save an IQ question
    public Iq saveIqQuestion(Iq iq) {
        System.out.println("Saving IQ Question: " + iq);
        return iqRepository.save(iq);
    }

    // Get all IQ questions
    public List<Iq> getAllIqQuestions() {
        return iqRepository.findAll();
    }

    // Get a specific IQ question by ID
    public Optional<Iq> getIqQuestionById(String id) {
        return iqRepository.findById(id);
    }

    // Get random IQ questions
    public List<Iq> getRandomQuestions(int count) {
        List<Iq> allQuestions = iqRepository.findAll();
        if (allQuestions.size() < count) {
            count = allQuestions.size();
        }
        Collections.shuffle(allQuestions);
        return allQuestions.stream().limit(count).collect(Collectors.toList());
    }

    // Delete an IQ question by ID
    public void deleteIqQuestion(String id) {
        iqRepository.deleteById(id);
    }
}
