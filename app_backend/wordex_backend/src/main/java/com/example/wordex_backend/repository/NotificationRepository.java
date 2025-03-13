package com.example.wordex_backend.repository;

import com.example.wordex_backend.model.Notification;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;


public interface NotificationRepository extends MongoRepository<Notification, String> {
    List<Notification> findByUserId(String userId);
}
