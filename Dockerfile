# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained
# in the license file that is distributed with this file.

# ***************************************************
# XWare GmbH: changed to work with community edition
# ***************************************************

# Tomcat official Docker Hub images are not using Oracle anymore, hence the rename
#FROM tomcat:9.0-jre8

# set certified Tomcat+JRE image version for the JasperReports Server
# Certified version of Tomcat for JasperReports Server 7.2.0 commercial editions
# ARG TOMCAT_BASE_IMAGE=tomcat:9.0.17-jre8

# Certified version of Tomcat for JasperReports Server 7.5.0 commercial editions
#ARG TOMCAT_BASE_IMAGE=tomcat:9.0.31-jdk8-openjdk
ARG TOMCAT_BASE_IMAGE=tomcat:9.0.37-jdk11-openjdk
FROM ${TOMCAT_BASE_IMAGE}

ARG DN_HOSTNAME
ARG KS_PASSWORD
ARG JRS_HTTPS_ONLY
ARG HTTP_PORT
ARG HTTPS_PORT
ARG POSTGRES_JDBC_DRIVER_VERSION
ARG JASPERREPORTS_SERVER_VERSION
ARG EXPLODED_INSTALLER_DIRECTORY

#ENV PHANTOMJS_VERSION         ${PHANTOMJS_VERSION:-2.1.1}
ENV DN_HOSTNAME         ${DN_HOSTNAME:-localhost.localdomain}
ENV KS_PASSWORD         ${KS_PASSWORD:-changeit}
ENV JRS_HTTPS_ONLY         ${JRS_HTTPS_ONLY:-false}
ENV HTTP_PORT             ${HTTP_PORT:-8080}
ENV HTTPS_PORT             ${HTTPS_PORT:-8443}
ENV JAVASCRIPT_RENDERING_ENGINE  ${JAVASCRIPT_RENDERING_ENGINE:-chromium}

ENV POSTGRES_JDBC_DRIVER_VERSION ${POSTGRES_JDBC_DRIVER_VERSION:-42.2.5}
ENV JASPERREPORTS_SERVER_VERSION ${JASPERREPORTS_SERVER_VERSION:-7.8.0}
ENV EXPLODED_INSTALLER_DIRECTORY ${EXPLODED_INSTALLER_DIRECTORY:-resources/jasperreports-server-cp-$JASPERREPORTS_SERVER_VERSION-bin}

# This Dockerfile requires an exploded JasperReports Server WAR file installer file 
# EXPLODED_INSTALLER_DIRECTORY (default jasperreports-server-bin/) directory below the Dockerfile.

# To use with pipeline - download ZIP from souurceforge (instead of having it manuall copied)
# comment out for performance reason, if you build it locally
#
#RUN pwd && \
#    echo ${EXPLODED_INSTALLER_DIRECTORY} && \
#    wget "https://sourceforge.net/projects/jasperserver/files/JasperServer/JasperReports%20Server%20Community%20edition%20${JASPERREPORTS_SERVER_VERSION}/TIB_js-jrs-cp_${JASPERREPORTS_SERVER_VERSION}_bin.zip/download" \
#         -O resources/jasperserver.zip  && \
#    unzip ./resources/jasperserver.zip -d ${EXPLODED_INSTALLER_DIRECTORY}/ && \
#    rm ./resources/jasperserver.zip && \
#    unzip ${EXPLODED_INSTALLER_DIRECTORY}/jasperserver.war

RUN mkdir -p /usr/src/jasperreports-server

# deploy the WAR to Tomcat
COPY ${EXPLODED_INSTALLER_DIRECTORY}/jasperserver $CATALINA_HOME/webapps/jasperserver/

#copy copyright notices
COPY ${EXPLODED_INSTALLER_DIRECTORY}/TIB* /usr/src/jasperreports-server/

# Ant
COPY ${EXPLODED_INSTALLER_DIRECTORY}/apache-ant /usr/src/jasperreports-server/apache-ant/

# js-ant script, Ant XMLs and support in bin
COPY ${EXPLODED_INSTALLER_DIRECTORY}/buildomatic/js-ant /usr/src/jasperreports-server/buildomatic/
COPY ${EXPLODED_INSTALLER_DIRECTORY}/buildomatic/build.xml /usr/src/jasperreports-server/buildomatic/
COPY ${EXPLODED_INSTALLER_DIRECTORY}/buildomatic/bin/*.xml /usr/src/jasperreports-server/buildomatic/bin/
COPY ${EXPLODED_INSTALLER_DIRECTORY}/buildomatic/bin/app-server /usr/src/jasperreports-server/buildomatic/bin/app-server/
COPY ${EXPLODED_INSTALLER_DIRECTORY}/buildomatic/bin/groovy /usr/src/jasperreports-server/buildomatic/bin/groovy/

# supporting resources
COPY ${EXPLODED_INSTALLER_DIRECTORY}/buildomatic/conf_source /usr/src/jasperreports-server/buildomatic/conf_source/
COPY ${EXPLODED_INSTALLER_DIRECTORY}/buildomatic/lib /usr/src/jasperreports-server/buildomatic/lib/

# js-docker specific scripts and resources
COPY scripts /usr/src/jasperreports-server/scripts/

# custom files
COPY resources/log4j2.xml $CATALINA_HOME/webapps/jasperserver/WEB-INF/classes/
COPY resources/resfactory.properties $CATALINA_HOME/webapps/jasperserver/WEB-INF/classes/
COPY resources/mssql-jdbc-7.4.1.jre8.jar /usr/src/jasperreports-server/buildomatic/conf_source/db/app-srv-jdbc-drivers/mssql-jdbc-7.4.1.jre8.jar

#wohin mit diesen JARS??
#ADD ./resources/Calibri.jar /usr/local/openjdk-11/lib/fonts/
#ADD ./resources/OCRB.jar /usr/lib/jvm/java-11-openjdk-amd64/jre/lib/fonts/
COPY resources/Calibri.jar $CATALINA_HOME/webapps/jasperserver/WEB-INF/lib/
COPY resources/OCRB.jar $CATALINA_HOME/webapps/jasperserver/WEB-INF/lib/
COPY resources/TradeGothic.jar $CATALINA_HOME/webapps/jasperserver/WEB-INF/lib/


RUN chmod +x /usr/src/jasperreports-server/scripts/*.sh && \
    /usr/src/jasperreports-server/scripts/installPackagesForJasperserver-ce.sh && \
    rm -rf $CATALINA_HOME/webapps/ROOT && \
    rm -rf $CATALINA_HOME/webapps/docs && \
    rm -rf $CATALINA_HOME/webapps/examples && \
    rm -rf $CATALINA_HOME/webapps/host-manager && \
    rm -rf $CATALINA_HOME/webapps/manager && \
    #
	cp -R /usr/src/jasperreports-server/scripts/buildomatic /usr/src/jasperreports-server/buildomatic && \
    chmod +x /usr/src/jasperreports-server/buildomatic/js-* && \
    chmod +x /usr/src/jasperreports-server/apache-ant/bin/* && \
    java -version && \

    wget "https://jdbc.postgresql.org/download/postgresql-${POSTGRES_JDBC_DRIVER_VERSION}.jar"  \
        -P /usr/src/jasperreports-server/buildomatic/conf_source/db/postgresql/jdbc --no-verbose && \

# enable Jasperserver for WebServices as DataSource
# Add WebServiceDataSource plugin
    wget https://community.jaspersoft.com/sites/default/files/releases/jaspersoft_webserviceds_v1.5.zip \
         -O /tmp/jasper.zip && \
    unzip /tmp/jasper.zip -d /tmp/ && \
    cp -rfv /tmp/JRS/WEB-INF/* $CATALINA_HOME/webapps/jasperserver/WEB-INF/ && \
    sed -i 's/queryLanguagesPro/queryLanguagesCe/g' $CATALINA_HOME/webapps/jasperserver/WEB-INF/applicationContext-WebServiceDataSource.xml && \
    rm -rf /tmp/* &&\

#
# Configure tomcat for SSL by default with a self-signed certificate.
# Option to set up JasperReports Server to use HTTPS only.
#
     keytool -genkey -alias self_signed -dname "CN=${DN_HOSTNAME}" \
        -storetype PKCS12 \
        -storepass "${KS_PASSWORD}" \
        -keypass "${KS_PASSWORD}" \
        -keystore $CATALINA_HOME/conf/.keystore.p12 && \
    keytool -list -keystore $CATALINA_HOME/conf/.keystore.p12 -storepass "${KS_PASSWORD}" -storetype PKCS12 && \
    xmlstarlet ed --inplace --subnode "/Server/Service" --type elem \
        -n Connector -v "" --var connector-ssl '$prev' \
    --insert '$connector-ssl' --type attr -n port -v "${HTTPS_PORT}" \
    --insert '$connector-ssl' --type attr -n protocol -v \
        "org.apache.coyote.http11.Http11NioProtocol" \
    --insert '$connector-ssl' --type attr -n maxThreads -v "150" \
    --insert '$connector-ssl' --type attr -n SSLEnabled -v "true" \
    --insert '$connector-ssl' --type attr -n scheme -v "https" \
    --insert '$connector-ssl' --type attr -n secure -v "true" \
    --insert '$connector-ssl' --type attr -n clientAuth -v "false" \
    --insert '$connector-ssl' --type attr -n sslProtocol -v "TLS" \
    --insert '$connector-ssl' --type attr -n keystorePass \
        -v "${KS_PASSWORD}"\
    --insert '$connector-ssl' --type attr -n keystoreFile \
        -v "$CATALINA_HOME/conf/.keystore.p12" \
    ${CATALINA_HOME}/conf/server.xml
	

# Expose ports. Note that you must do one of the following:
# map them to local ports at container runtime via "-p 8080:8080 -p 8443:8443"
# or use dynamic ports.
EXPOSE ${HTTP_PORT} ${HTTPS_PORT}

ENTRYPOINT ["/usr/src/jasperreports-server/scripts/entrypoint.sh"]

# Default action executed by entrypoint script.
CMD ["run"]
