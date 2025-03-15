FROM openjdk:23-jdk-slim
WORKDIR /home/jvalidation
COPY target/*.jar jvalidation.jar
RUN chmod -R 7777 /mnt
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-Dspring.profiles.active=prod", "-jar", "jvalidation.jar"]
