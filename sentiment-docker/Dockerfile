# ---------- Build stage ----------
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

COPY pom.xml .
RUN mvn -q -e -B -DskipTests dependency:go-offline

COPY src ./src
RUN mvn -q -e -B -DskipTests clean package

# Plukk første .jar og legg den på en fast sti vi kan kopiere fra
RUN JAR="$(ls -1 target/*.jar | head -n1)" && cp "$JAR" /tmp/app.jar

# ---------- Runtime stage ----------
FROM eclipse-temurin:21-jre
WORKDIR /opt/app

# Non-root for sikkerhet
RUN useradd -r -u 10001 spring && chown -R spring:spring /opt/app
USER spring

# Her får vi med selve artefaktet
COPY --from=build /tmp/app.jar /opt/app/app.jar

EXPOSE 8080
ENTRYPOINT ["java","-jar","/opt/app/app.jar"]
