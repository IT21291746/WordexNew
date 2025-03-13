package com.example.wordex_backend.services;

import com.example.wordex_backend.model.Notification;
import com.example.wordex_backend.repository.NotificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.Date;
import java.util.List;


@Service
public class NotificationService {

    @Autowired
    private NotificationRepository notificationRepository;

    // Create a new notification
    public Notification createNotification(Notification notification) {
        notification.setTimestamp(new Date()); // Set current timestamp
        return notificationRepository.save(notification);
    }

    // Get a notification by ID
    public Notification getNotificationById(String id) {
        return notificationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Notification not found with id: " + id));
    }


    public List<Notification> getNotificationsByUserId(String userId) {
    // Assuming you have a repository to interact with the database
    return notificationRepository.findByUserId(userId);
}


    // Delete a notification by ID
    public void deleteNotification(String id) {
        if (notificationRepository.existsById(id)) {
            notificationRepository.deleteById(id);
        } else {
            throw new RuntimeException("Notification not found with id: " + id);
        }
    }
}
