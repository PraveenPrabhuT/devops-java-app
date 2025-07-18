FROM maven:3.8.1-openjdk-17-slim AS dependency
WORKDIR /usr/app
COPY pom.xml .
RUN mvn dependency:go-offline -B --fail-never

FROM dependency as build
WORKDIR /usr/app
COPY pom.xml .
COPY src src
WORKDIR /usr/app
RUN --mount=type=cache,target=.m2 mvn clean install -DskipTests=true

#FROM public.ecr.aws/docker/library/maven:3.9.6-eclipse-temurin-17 AS build
#WORKDIR /app
#COPY pom.xml .
#COPY src ./src
#RUN mvn clean package -DskipTests

FROM public.ecr.aws/amazoncorretto/amazoncorretto:17-al2023-headless
WORKDIR /app
COPY --from=build /usr/app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
