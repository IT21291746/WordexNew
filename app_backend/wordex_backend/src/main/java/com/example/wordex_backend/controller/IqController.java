package com.example.wordex_backend.controller;

import com.example.wordex_backend.model.Iq;
import com.example.wordex_backend.services.IqService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@CrossOrigin(origins = "http://localhost:3000")
@RequestMapping("/iq")
public class IqController {

    @Autowired
    private IqService iqService;

    // Save IQ question
    @PostMapping("/save")
    public ResponseEntity<Iq> saveIqQuestion(@RequestBody Iq iq) {
        System.out.println("Received Question: " + iq.getQuestion());
        Iq savedQuestion = iqService.saveIqQuestion(iq);
        return ResponseEntity.ok(savedQuestion);
    }

    // Get all IQ questions
    @GetMapping("/all")
    public ResponseEntity<List<Iq>> getAllIqQuestions() {
        List<Iq> iqQuestions = iqService.getAllIqQuestions();
        return ResponseEntity.ok(iqQuestions);
    }

    // Get a specific IQ question by ID
    @GetMapping("/{id}")
    public ResponseEntity<Iq> getIqQuestionById(@PathVariable("id") String id) {
        Optional<Iq> iqQuestion = iqService.getIqQuestionById(id);
        return iqQuestion.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    // Get random 5 IQ questions
    @GetMapping("/random")
    public ResponseEntity<List<Iq>> getRandomQuestions() {
        List<Iq> questions = iqService.getRandomQuestions(5);
        return ResponseEntity.ok(questions);
    }

    // Delete an IQ question by ID
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<String> deleteIqQuestion(@PathVariable("id") String id) {
        iqService.deleteIqQuestion(id);
        return ResponseEntity.ok("IQ question deleted successfully!");
    }
}
