FROM eclipse-temurin:21-jre
ENV PORT=8000
EXPOSE 8000
WORKDIR /app
COPY app/build/libs/kotlin-joke-all.jar ./app.jar
ENTRYPOINT ["java","-jar","/app/app.jar"]
