package com.example.wordex_backend.services;

import com.example.wordex_backend.model.Dsq;
import com.example.wordex_backend.repository.DsqRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class DsqService {

    @Autowired
    private DsqRepository dsqRepository;

    // Save an IQ question
    public Dsq saveDsqQuestion(Dsq dsq) {
        System.out.println("Saving IQ Question: " + dsq);
        return dsqRepository.save(dsq);
    }

    // Get all IQ questions
    public List<Dsq> getAllDsqQuestions() {
        return dsqRepository.findAll();
    }

    // Get a specific IQ question by ID
    public Optional<Dsq> getDsqQuestionById(String id) {
        return dsqRepository.findById(id);
    }

    // Get random IQ questions
    public List<Dsq> getRandomQuestions(int count) {
        List<Dsq> allQuestions = dsqRepository.findAll();
        if (allQuestions.size() < count) {
            count = allQuestions.size();
        }
        Collections.shuffle(allQuestions);
        return allQuestions.stream().limit(count).collect(Collectors.toList());
    }

    // Delete an IQ question by ID
    public void deleteDsqQuestion(String id) {
        dsqRepository.deleteById(id);
    }
}
