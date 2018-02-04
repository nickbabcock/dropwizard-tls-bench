FROM maven:3.5.2
COPY . /root/
WORKDIR /root
RUN keytool -keystore keystore -alias jetty -genkey -keyalg RSA -noprompt -dname "CN=example.com, OU=A, O=A, L=B, S=C, C=GB" -storepass thisispassword -keypass thisispassword -storetype pkcs12
RUN wget http://repo1.maven.org/maven2/org/mortbay/jetty/alpn/alpn-boot/8.1.11.v20170118/alpn-boot-8.1.11.v20170118.jar
RUN mvn verify

FROM openjdk:8u151-jre
COPY --from=0 /root/target/tls.bench-1.0-SNAPSHOT.jar /.
COPY --from=0 /root/keystore /. 
COPY --from=0 /root/alpn-boot-8.1.11.v20170118.jar /. 
COPY --from=0 /root/config.yml /.
EXPOSE 9443
ENTRYPOINT ["java"]
