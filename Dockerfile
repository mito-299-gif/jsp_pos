FROM tomcat:10.1-jdk17


RUN wget https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar -O /usr/local/tomcat/lib/mysql-connector-j-8.0.33.jar


COPY src/main/webapp /usr/local/tomcat/webapps/pp


EXPOSE 8080


CMD ["catalina.sh", "run"]
