package com.example.wordex_backend.controller;

import com.example.wordex_backend.model.Wjq;
import com.example.wordex_backend.services.WjqService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@CrossOrigin(origins = "http://localhost:3000")
@RequestMapping("/wjq")
public class WjqController {

    @Autowired
    private WjqService wjqService;

    // Save IQ question
    @PostMapping("/save")
    public ResponseEntity<Wjq> saveWjqQuestion(@RequestBody Wjq wjq) {
        System.out.println("Received Question: " + wjq.getQuestion());
        Wjq savedQuestion = wjqService.saveWjqQuestion(wjq);
        return ResponseEntity.ok(savedQuestion);
    }

    // Get all IQ questions
    @GetMapping("/all")
    public ResponseEntity<List<Wjq>> getAllWjqQuestions() {
        List<Wjq> wjqQuestions = wjqService.getAllWjqQuestions();
        return ResponseEntity.ok(wjqQuestions);
    }

    // Get a specific IQ question by ID
    @GetMapping("/{id}")
    public ResponseEntity<Wjq> getWjqQuestionById(@PathVariable("id") String id) {
        Optional<Wjq> wjqQuestion = wjqService.getWjqQuestionById(id);
        return wjqQuestion.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    // Get random 5 IQ questions
    @GetMapping("/random")
    public ResponseEntity<List<Wjq>> getRandomQuestions() {
        List<Wjq> questions = wjqService.getRandomQuestions(5);
        return ResponseEntity.ok(questions);
    }

    // Delete an IQ question by ID
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<String> deleteWjqQuestion(@PathVariable("id") String id) {
        wjqService.deleteWjqQuestion(id);
        return ResponseEntity.ok("IQ question deleted successfully!");
    }
}
