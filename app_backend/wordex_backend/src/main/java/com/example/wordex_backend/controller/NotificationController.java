package com.example.wordex_backend.controller;

import com.example.wordex_backend.model.Notification;
import com.example.wordex_backend.services.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;


@RestController
@CrossOrigin(origins = "http://localhost:3000")
@RequestMapping("/notifications")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    // Create a new notification
    @PostMapping
    public ResponseEntity<Object> createNotification(@RequestBody Notification notification) {
        Notification createdNotification = notificationService.createNotification(notification);
        return new ResponseEntity<>(createdNotification, HttpStatus.CREATED);
    }

    // Get notification by ID
    @GetMapping("/{id}") // Fixed mapping
    public ResponseEntity<Object> getNotificationById(@PathVariable String id) {
        try {
            Notification notification = notificationService.getNotificationById(id);
            return new ResponseEntity<>(notification, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>("Notification not found", HttpStatus.NOT_FOUND);
        }
    }


    // Get notifications by User ID
@GetMapping("/user/{userId}") // Fixed mapping to use userId in the path
public ResponseEntity<Object> getNotificationsByUserId(@PathVariable String userId) {
    try {
        // Call the service method to retrieve notifications by userId
        List<Notification> notifications = notificationService.getNotificationsByUserId(userId);
        
        // Check if notifications exist for the user
        if (notifications.isEmpty()) {
            return new ResponseEntity<>("No notifications found for this user", HttpStatus.NOT_FOUND);
        }

        return new ResponseEntity<>(notifications, HttpStatus.OK);
    } catch (RuntimeException e) {
        // In case of an error, return internal server error
        return new ResponseEntity<>("An error occurred while fetching notifications", HttpStatus.INTERNAL_SERVER_ERROR);
    }
}

    
    // Delete notification by ID
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteNotification(@PathVariable String id) {
        try {
            notificationService.deleteNotification(id);
            return new ResponseEntity<>("Notification deleted successfully!", HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>("Notification not found", HttpStatus.NOT_FOUND);
        }
    }
}
