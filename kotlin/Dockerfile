FROM eclipse-temurin:21-jre-focal
ENV PORT=8000
EXPOSE 8000
WORKDIR /app
COPY build/libs/joke-kotlin-all.jar ./app.jar
ENTRYPOINT ["java","-jar","/app/app.jar"]
