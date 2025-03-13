package com.example.wordex_backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = "com.example.wordex_backend")
public class WordexBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(WordexBackendApplication.class, args);
    }
}
