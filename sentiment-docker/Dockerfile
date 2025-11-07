# syntax=docker/dockerfile:1

########################
# 1) BUILD STAGE
########################
FROM maven:3.9-amazoncorretto-21 AS build
WORKDIR /workspace

# Kopier kun pom først for best mulig cache
COPY pom.xml ./
# Last ned dependencies (cache)
RUN mvn -B -q -DskipTests dependency:go-offline

# Kopier resten av koden og bygg
COPY src ./src
# Bygg og repackage til kjørbar fat JAR
RUN mvn -B -DskipTests package spring-boot:repackage

########################
# 2) RUNTIME STAGE
########################
FROM amazoncorretto:21-alpine

# (Valgfritt) kjør som non-root
RUN addgroup -S spring && adduser -S spring -G spring
USER spring

WORKDIR /app
# Kopier den repackaged jar-en fra build-stage og gi den et konsistent navn
COPY --from=build /workspace/target/*.jar /app/app.jar

# Eksponer Spring Boot-port
EXPOSE 8080

# (Valgfritt) JAVA_OPTS for tuning (heap, GC, etc.)
ENV JAVA_OPTS=""

# Start applikasjonen
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
