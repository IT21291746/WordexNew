package com.example.wordex_backend.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Document(collection = "dsq")
@Getter
@Setter
@ToString
public class Dsq {

    @Id
    private String id;

    @JsonProperty("question")
    private String question;

    @JsonProperty("answer")
    private String answer;
}
