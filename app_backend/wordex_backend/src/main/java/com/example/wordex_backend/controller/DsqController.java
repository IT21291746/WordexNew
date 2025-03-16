package com.example.wordex_backend.controller;

import com.example.wordex_backend.model.Dsq;
import com.example.wordex_backend.services.DsqService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@CrossOrigin(origins = "http://localhost:3000")
@RequestMapping("/dsq")
public class DsqController {

    @Autowired
    private DsqService dsqService;

    // Save IQ question
    @PostMapping("/save")
    public ResponseEntity<Dsq> saveDsqQuestion(@RequestBody Dsq dsq) {
        System.out.println("Received Question: " + dsq.getQuestion());
        Dsq savedQuestion = dsqService.saveDsqQuestion(dsq);
        return ResponseEntity.ok(savedQuestion);
    }

    // Get all IQ questions
    @GetMapping("/all")
    public ResponseEntity<List<Dsq>> getAllDsqQuestions() {
        List<Dsq> dsqQuestions = dsqService.getAllDsqQuestions();
        return ResponseEntity.ok(dsqQuestions);
    }

    // Get a specific IQ question by ID
    @GetMapping("/{id}")
    public ResponseEntity<Dsq> getDsqQuestionById(@PathVariable("id") String id) {
        Optional<Dsq> dsqQuestion = dsqService.getDsqQuestionById(id);
        return dsqQuestion.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }

    // Get random 5 IQ questions
    @GetMapping("/random")
    public ResponseEntity<List<Dsq>> getRandomQuestions() {
        List<Dsq> questions = dsqService.getRandomQuestions(5);
        return ResponseEntity.ok(questions);
    }

    // Delete an IQ question by ID
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<String> deleteDsqQuestion(@PathVariable("id") String id) {
        dsqService.deleteDsqQuestion(id);
        return ResponseEntity.ok("IQ question deleted successfully!");
    }
}
