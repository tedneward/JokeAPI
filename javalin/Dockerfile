FROM eclipse-temurin:21-jre
WORKDIR /app
COPY build/libs/javalin-joke-all.jar /app/javalin-joke-all.jar
EXPOSE 8000
ENTRYPOINT ["java", "-jar", "/app/javalin-joke-all.jar"]
