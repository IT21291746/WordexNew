package com.example.wordex_backend.controller;

import com.example.wordex_backend.model.Racq;
import com.example.wordex_backend.services.RacqService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@CrossOrigin(origins = "http://localhost:3000")
@RequestMapping("/racq")
public class RacqController {

    @Autowired
    private RacqService racqService;

    // Save IQ question
    @PostMapping("/save")
    public ResponseEntity<Racq> saveRacqQuestion(@RequestBody Racq racq) {
        System.out.println("Received Question: " + racq.getQuestion());
        Racq savedQuestion = racqService.saveRacqQuestion(racq);
        return ResponseEntity.ok(savedQuestion);
    }

    // Get all IQ questions
    @GetMapping("/all")
    public ResponseEntity<List<Racq>> getAllRacqQuestions() {
        List<Racq> racqQuestions = racqService.getAllRacqQuestions();
        return ResponseEntity.ok(racqQuestions);
    }

    // Get a specific IQ question by ID
    @GetMapping("/{id}")
    public ResponseEntity<Racq> getRacqQuestionById(@PathVariable("id") String id) {
        Optional<Racq> racqQuestion = racqService.getRacqQuestionById(id);
        return racqQuestion.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    // Get random 5 IQ questions
    @GetMapping("/random")
    public ResponseEntity<List<Racq>> getRandomQuestions() {
        List<Racq> questions = racqService.getRandomQuestions(5);
        return ResponseEntity.ok(questions);
    }

    // Delete an IQ question by ID
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<String> deleteRacqQuestion(@PathVariable("id") String id) {
        racqService.deleteRacqQuestion(id);
        return ResponseEntity.ok("IQ question deleted successfully!");
    }
}
