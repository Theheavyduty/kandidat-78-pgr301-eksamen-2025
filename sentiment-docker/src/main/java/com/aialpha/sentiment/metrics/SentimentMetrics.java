package com.aialpha.sentiment.metrics;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.DistributionSummary;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.util.concurrent.atomic.AtomicInteger;

@Component
public class SentimentMetrics {

    private final MeterRegistry meterRegistry;

    // Backing value for a Gauge that can go up/down between requests
    private final AtomicInteger companiesDetectedGauge = new AtomicInteger(0);

    public SentimentMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;

        // Register the gauge once; update the AtomicInteger per request
        Gauge.builder("sentiment.analysis.companies.detected", companiesDetectedGauge, AtomicInteger::get)
                .description("Number of companies detected in the most recent analysis")
                .baseUnit("companies")
                .register(meterRegistry);
    }

    /** Counter: count analyses by method (e.g., \"AI-Powered\", \"Rule-Based\"). */
    public void incrementAnalysisCounter(String method) {
        Counter.builder("sentiment.analysis.count")
                .description("Total number of sentiment analyses")
                .tag("method", method)
                .register(meterRegistry)
                .increment();
    }

    /** Counter: count analyses by outcome (sentiment) and company. */
    public void recordAnalysis(String sentiment, String company) {
        Counter.builder("sentiment.analysis.count")
                .description("Total number of sentiment analyses")
                .tag("sentiment", (sentiment == null || sentiment.isBlank()) ? "unknown" : sentiment)
                .tag("company", (company == null || company.isBlank()) ? "unknown" : company)
                .register(meterRegistry)
                .increment();
    }


    /** Timer: record Bedrock latency in milliseconds, tagged by company and model. */
    public void recordDuration(long milliseconds, String company, String model) {
        Timer.builder("sentiment.bedrock.duration")
                .description("Latency for AWS Bedrock calls")
                .publishPercentiles(0.5, 0.9, 0.99)
                .publishPercentileHistogram() // useful for CloudWatch graphs
                .tag("company", company == null ? "unknown" : company)
                .tag("model", model == null ? "unknown" : model)
                .register(meterRegistry)
                .record(Duration.ofMillis(milliseconds));
    }

    /** Gauge: update how many companies were found in the last analysis. */
    public void recordCompaniesDetected(int count) {
        companiesDetectedGauge.set(Math.max(count, 0));
    }

    /** DistributionSummary: record confidence scores in [0..1], tagged by sentiment & company. */
    public void recordConfidence(double confidence, String sentiment, String company) {
        double c = Math.max(0.0, Math.min(1.0, confidence)); // clamp

        DistributionSummary.builder("sentiment.confidence")
                .description("Model confidence score (0..1)")
                .baseUnit("ratio")
                .maximumExpectedValue(1.0)
                .publishPercentiles(0.5, 0.9, 0.99)
                .publishPercentileHistogram()
                .tag("sentiment", sentiment == null || sentiment.isBlank() ? "unknown" : sentiment)
                .tag("company",   company   == null || company.isBlank()   ? "unknown" : company)
                .register(meterRegistry)
                .record(c);
    }


}