package com.example.sentiment_app.controllers;

import io.github.inference4j.nlp.TextClassification;
import io.github.inference4j.nlp.TextClassifier;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
public class SentimentController {

    private final TextClassifier textClassifier;

    // Spring автоматически внедрит классификатор, так как мы включили его в конфигурации
    public SentimentController(TextClassifier textClassifier) {
        this.textClassifier = textClassifier;
    }

    @GetMapping("/api/sentiment")
    public Map<String, Object> analyzeSentiment(@RequestParam String text) {
        // Классифицируем текст
        List<TextClassification> results = textClassifier.classify(text);

        // Берем наиболее вероятный результат
        TextClassification topResult = results.get(0);

        return Map.of(
                "sentiment", topResult.label().toLowerCase()

        );
    }
}
