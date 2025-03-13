package com.example.wordex_backend.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import java.util.Map;

@Document(collection = "iq")
@Getter
@Setter
@ToString
public class Iq {

    @Id
    private String id;

    @JsonProperty("question")
    private String question;

    @JsonProperty("qImageUrl")
    private String qImageUrl;

    @JsonProperty("qAudioUrl")
    private String qAudioUrl;

    @JsonProperty("qVideoUrl")
    private String qVideoUrl;

    @JsonProperty("answer")
    private String answer;

    @JsonProperty("options")
    private Map<String, Object> options;
}
