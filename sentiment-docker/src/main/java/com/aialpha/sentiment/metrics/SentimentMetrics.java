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

    // Gauge: antall selskaper i siste analyse (kan opp/ned)
    private final AtomicInteger lastCompaniesDetected = new AtomicInteger(0);

    public SentimentMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;

        Gauge.builder("sentiment.companies.last", lastCompaniesDetected, AtomicInteger::get)
                .description("Number of companies detected in the last analysis")
                .register(meterRegistry);
    }

    /** Counter: total antall analyser (tagges med metode) */
    public void recordRequest(String method) {
        Counter.builder("sentiment.analysis.count")
                .description("Total number of sentiment analyses")
                .tag("method", (method == null || method.isBlank()) ? "unknown" : method)
                .register(meterRegistry)
                .increment();
    }

    /** Counter: antall analyser per sentiment og selskap */
    public void recordAnalysis(String sentiment, String company) {
        Counter.builder("sentiment.analysis.count")
                .description("Total number of sentiment analyses")
                .tag("sentiment", (sentiment == null || sentiment.isBlank()) ? "unknown" : sentiment)
                .tag("company",   (company   == null || company.isBlank())   ? "unknown" : company)
                .register(meterRegistry)
                .increment();
    }

    /** Timer: Bedrock-latency i ms, tagget per selskap og modell */
    public void recordDuration(long milliseconds, String company, String model) {
        Timer.builder("sentiment.bedrock.duration")
                .description("Latency for AWS Bedrock calls")
                .publishPercentiles(0.5, 0.9, 0.99)
                .publishPercentileHistogram()
                .tag("company", (company == null || company.isBlank()) ? "unknown" : company)
                .tag("model",   (model   == null || model.isBlank())   ? "unknown" : model)
                .register(meterRegistry)
                .record(Duration.ofMillis(milliseconds));
    }

    /** DistributionSummary: fordeling av confidence [0..1] per sentiment og selskap */
    public void recordConfidence(double confidence, String sentiment, String company) {
        double c = Math.max(0.0, Math.min(1.0, confidence)); // clamp
        DistributionSummary.builder("sentiment.confidence")
                .description("Model confidence score (0..1)")
                .baseUnit("ratio")
                .maximumExpectedValue(1.0)
                .publishPercentiles(0.5, 0.9, 0.99)
                .publishPercentileHistogram()
                .tag("sentiment", (sentiment == null || sentiment.isBlank()) ? "unknown" : sentiment)
                .tag("company",   (company   == null || company.isBlank())   ? "unknown" : company)
                .register(meterRegistry)
                .record(c);
    }

    /** Gauge-oppdatering: sett antall selskaper funnet i denne analysen */
    public void recordCompaniesDetected(int count) {
        lastCompaniesDetected.set(Math.max(0, count));
    }


}