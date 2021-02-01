ARG OPERATOR_NAME

FROM openjdk
  
LABEL Maintainer prasanth

#RUN cp -r /PWA /PWA

VOLUME /PWA/${OPERATOR_NAME}/config /PWA/${OPERATOR_NAME}/config

WORKDIR "/PWA/${OPERATOR_NAME}/config/"

EXPOSE 8084

CMD ["java", "-jar", "pwa-1.0-SNAPSHOT.jar"
