FROM tomcat:10.1-jdk17

# Download MySQL Connector/J
RUN wget https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar -O /usr/local/tomcat/lib/mysql-connector-j-8.0.33.jar

# Copy the webapp to Tomcat webapps directory
COPY src/main/webapp /usr/local/tomcat/webapps/pp

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
