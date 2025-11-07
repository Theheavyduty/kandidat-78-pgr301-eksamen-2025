package com.aialpha.sentiment.config;

import io.micrometer.cloudwatch2.CloudWatchConfig;
import io.micrometer.cloudwatch2.CloudWatchMeterRegistry;

import io.micrometer.core.instrument.Clock;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.cloudwatch.CloudWatchAsyncClient;

import java.time.Duration;
import java.util.Map;

@Configuration
public class MetricsConfig {
    @Bean
    CloudWatchMeterRegistry cloudWatchMeterRegistry(Clock clock, CloudWatchAsyncClient cw) {
        CloudWatchConfig config = new CloudWatchConfig() {
            private final Map<String, String> cfg = Map.of(
                "cloudwatch.namespace", "kandidat-78-SentimentApp",  // <-- bytt <NR>
                "cloudwatch.step", Duration.ofSeconds(1).toString()
            );

            @Override public String get(String key) { return cfg.get(key); }
        };

        // Use the existing CloudWatchAsyncClient bean (injected as 'cw') and the constructor:
        return new CloudWatchMeterRegistry(config, clock, cw);
    }

    @Bean
    public CloudWatchAsyncClient cloudWatchAsyncClient() {
        return CloudWatchAsyncClient
                .builder()
                .region(Region.EU_WEST_1)
                .build();
    }

    @Bean
    public MeterRegistry getMeterRegistry() {
        CloudWatchConfig cloudWatchConfig = setupCloudWatchConfig();
        return
                new CloudWatchMeterRegistry(
                        cloudWatchConfig,
                        Clock.SYSTEM,
                        cloudWatchAsyncClient());
    }

    private CloudWatchConfig setupCloudWatchConfig() {
        return new CloudWatchConfig() {
            // TODO: VIKTIG! Endre "SentimentApp" til ditt kandidatnummer (f.eks. "kandidat123")
            // Du MÅ bruke SAMME namespace når du lager CloudWatch Dashboard i Terraform!
            private Map<String, String> configuration = Map.of(
                    "cloudwatch.namespace", "kandidat78",
                    "cloudwatch.step", Duration.ofSeconds(1).toString());

            @Override
            public String get(String key) {
                return configuration.get(key);
            }
        };
    }

}
