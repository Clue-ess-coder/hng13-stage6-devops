FROM maven:3.8-openjdk-8-slim as build-stage

WORKDIR /app

COPY pom.xml ./
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean install -DskipTests

FROM eclipse-temurin:8-jre-jammy as production-stage

ARG JAR_FILE=/app/target/users-api-0.0.1-SNAPSHOT.jar

COPY --from=build-stage ${JAR_FILE} /app/app.jar

EXPOSE 8083

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
