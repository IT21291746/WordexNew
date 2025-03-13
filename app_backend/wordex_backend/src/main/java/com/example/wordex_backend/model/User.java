package com.example.wordex_backend.model;

import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.annotation.Id;
import lombok.Getter;
import lombok.Setter;

@Document(collection = "users")
@Getter
@Setter
public class User {

    @Id
    private String id;  // Use String for MongoDB ID

    private String firstName;
    private String lastName;
    private String birthDate;
    private String mobileNumber;
    private String email;
    private String userName; // Added userName
    private String password;
}
