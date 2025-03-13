package com.example.wordex_backend.model;

import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.annotation.Id;
import lombok.Getter;
import lombok.Setter;
import java.util.Date;

@Document(collection = "notifications")
@Getter
@Setter
public class Notification {
    @Id
    private String id;  
    private String userId;
    private Date timestamp;
    private String notification;
}
