FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM payara/micro:6.2024.10-jdk17
COPY --from=build /app/target/Glasss-1.0-SNAPSHOT.war $DEPLOY_DIR/ROOT.war
CMD ["--deploy", "/opt/payara/deployments/ROOT.war", "--port", "8080", "--noCluster"]
