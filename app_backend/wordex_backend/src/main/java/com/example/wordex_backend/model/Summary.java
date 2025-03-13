package com.example.wordex_backend.model;

import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.annotation.Id;
import lombok.Getter;
import lombok.Setter;
import java.util.Map; // Import Map
import java.util.Date;


@Document(collection = "summaries") // MongoDB Collection Name
@Getter
@Setter
public class Summary {

    @Id
    private String id; // MongoDB Auto-Generated ID

    private String userId; // Link summary to a specific user
    private Date timestamp; // Store the date & time of the quiz

    private int totalCorrect; // Total correct answers
    private int totalTimeSpent; // Total time spent in seconds

    private String racResult;
    private String dsResult;
    private String ljResult;
    private String wjResult;

    private Map<String, Object> racDetails; // Store RAC round details
    private Map<String, Object> dsDetails; // Store DS round details
    private Map<String, Object> ljDetails; // Store LJ round details
    private Map<String, Object> wjDetails; // Store WJ round details
}
