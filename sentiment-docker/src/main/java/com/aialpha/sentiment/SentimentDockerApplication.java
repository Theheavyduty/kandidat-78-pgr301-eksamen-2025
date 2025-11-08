package com.aialpha.sentiment;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SentimentDockerApplication {

    public static void main(String[] args) {
        SpringApplication.run(SentimentDockerApplication.class, args);
        System.out.println("Sentiment Docker Application started...");
    }
}
