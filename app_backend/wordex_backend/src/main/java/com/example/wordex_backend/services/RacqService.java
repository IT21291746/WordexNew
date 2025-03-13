package com.example.wordex_backend.services;

import com.example.wordex_backend.model.Racq;
import com.example.wordex_backend.repository.RacqRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class RacqService {

    @Autowired
    private RacqRepository racqRepository;

    // Save an IQ question
    public Racq saveRacqQuestion(Racq racq) {
        System.out.println("Saving IQ Question: " + racq);
        return racqRepository.save(racq);
    }

    // Get all IQ questions
    public List<Racq> getAllRacqQuestions() {
        return racqRepository.findAll();
    }

    // Get a specific IQ question by ID
    public Optional<Racq> getRacqQuestionById(String id) {
        return racqRepository.findById(id);
    }

    // Get random IQ questions
    public List<Racq> getRandomQuestions(int count) {
        List<Racq> allQuestions = racqRepository.findAll();
        if (allQuestions.size() < count) {
            count = allQuestions.size();
        }
        Collections.shuffle(allQuestions);
        return allQuestions.stream().limit(count).collect(Collectors.toList());
    }

    // Delete an IQ question by ID
    public void deleteRacqQuestion(String id) {
        racqRepository.deleteById(id);
    }
}
