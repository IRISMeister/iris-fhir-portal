ARG IMAGE=store/intersystems/iris-community:2020.1.0.204.0
ARG IMAGE=intersystemsdc/iris-community:2020.1.0.209.0-zpm
ARG IMAGE=intersystemsdc/iris-community:2020.2.0.204.0-zpm
ARG IMAGE=intersystemsdc/irishealth-community:2020.2.0.204.0-zpm
ARG IMAGE=intersystemsdc/irishealth-community:2020.3.0.200.0-zpm
#Replaced with below image to fix Error: Invalid Community Edition license
ARG IMAGE=intersystemsdc/irishealth-community:2021.1.0.215.3-zpm
FROM $IMAGE

USER root

WORKDIR /opt/irisapp
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp
USER ${ISC_PACKAGE_MGRUSER}

COPY  src src
COPY iris.script /tmp/iris.script
#COPY fhirUI /usr/irissys/csp/user/fhirUI

# run iris and initial 
RUN iris start $ISC_PACKAGE_INSTANCENAME \
    && printf 'Do ##class(Config.NLS.Locales).Install("jpuw") h\n' | iris session $ISC_PACKAGE_INSTANCENAME -U %SYS \
	&& iris session $ISC_PACKAGE_INSTANCENAME < /tmp/iris.script \
	&& iris stop $ISC_PACKAGE_INSTANCENAME quietly

# for faster rebuild when data is modified 
COPY data/fhir fhirdata
COPY iris2.script /tmp/iris2.script
# fhir data load phase
RUN iris start $ISC_PACKAGE_INSTANCENAME \
	&& iris session $ISC_PACKAGE_INSTANCENAME < /tmp/iris2.script
