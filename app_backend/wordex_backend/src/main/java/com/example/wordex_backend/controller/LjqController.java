package com.example.wordex_backend.controller;

import com.example.wordex_backend.model.Ljq;
import com.example.wordex_backend.services.LjqService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@CrossOrigin(origins = "http://localhost:3000")
@RequestMapping("/ljq")
public class LjqController {

    @Autowired
    private LjqService ljqService;

    // Save IQ question
    @PostMapping("/save")
    public ResponseEntity<Ljq> saveLjqQuestion(@RequestBody Ljq ljq) {
        System.out.println("Received Question: " + ljq.getQuestion());
        Ljq savedQuestion = ljqService.saveLjqQuestion(ljq);
        return ResponseEntity.ok(savedQuestion);
    }

    // Get all IQ questions
    @GetMapping("/all")
    public ResponseEntity<List<Ljq>> getAllLjqQuestions() {
        List<Ljq> ljqQuestions = ljqService.getAllLjqQuestions();
        return ResponseEntity.ok(ljqQuestions);
    }

    // Get a specific IQ question by ID
    @GetMapping("/{id}")
    public ResponseEntity<Ljq> getLjqQuestionById(@PathVariable("id") String id) {
        Optional<Ljq> ljqQuestion = ljqService.getLjqQuestionById(id);
        return ljqQuestion.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    // Get random 5 IQ questions
    @GetMapping("/random")
    public ResponseEntity<List<Ljq>> getRandomQuestions() {
        List<Ljq> questions = ljqService.getRandomQuestions(5);
        return ResponseEntity.ok(questions);
    }

    // Delete an IQ question by ID
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<String> deleteLjqQuestion(@PathVariable("id") String id) {
        ljqService.deleteLjqQuestion(id);
        return ResponseEntity.ok("IQ question deleted successfully!");
    }
}
