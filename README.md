# TIBCO  JasperReports&reg; Server for Containers (CE)

# Table of contents

1. [Introduction](#introduction)
1. [Purpose](#purpose)
   1. [Changes](#changes)

# Introduction

This is a fork of the official TIBCO [repository](https://github.com/TIBCOSoftware/js-docker). Please refere to the orginal documentation from TIBCO.
Only changes to the original documentation will be on this page.

For more information about JasperReports Server, see the
[Jaspersoft community](http://community.jaspersoft.com/).

# Purpose

The page from TIBCO handles the pro version from jasperreport only. This page aims to provide the same functionality for the community edition (ce) of jasperserver.


## changes
- replace all references with value pro to cp/ce in the scripts
- add log4j2.xml to prevent error message on startup
- add resfactory.properties to prevent JNDI error message on startup
- add jdbc driver for mssql
- add some fonts
- disable phantomjs
- add plugin for Webservicedatasource
- add Import-ZIP File for [SeicentoBillingReports](https://github.com/xware-gmbh/SeicentoBilling)

# Docker Image
The docker images for the JasperServer and the cmdline - Tools can be retrieved from [Dockerhub](https://hub.docker.com/repository/docker/jmurihub/jasperserver-cp)

# Pitfalls

## Login not possible

[Howto reset pw](https://community.jaspersoft.com/wiki/how-reset-superuser-password)

## import Reports for SeicentoBilling

After starting the image(s). Jasperserver will be available with the standard user/pw. Login and import the Import-ZIP File. After importing change the password for user jasperadmin.
