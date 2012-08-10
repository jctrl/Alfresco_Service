#!/bin/bash
#################################################################################################
# NAME
#   configure.sh
#   
# LAST MODIFIED
#   27-June-2012
#
# SYNOPSIS
#       
# DESCRIPTION
#     This script installs Alfresco Enterprise Bundle
#     with optional liferay integration
#
# USAGE
#   Following environment variables are needed by this script:
#   1. global_conf : This is the path to the file https://${darwin.server.ip}:8443/darwin/conf/darwin_global.conf 
#                    on the appdirector server
# LICENSE
#    
# AUTHOR
#    Ankur Goel
#    Persistent Systems Limited
#################################################################################################
# Enables checking of all commands. If a command exits with an error(non-zero status) 
# and the caller does not check such error, the script aborts immediately
set -e 

# Import Global conf
. $global_conf

export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Update host file
address=`ifconfig |grep "inet addr" |grep -v "127.0.0.1" |awk '{print $2;}' |awk -F':' '{print $2;}'`
echo $address `hostname`>>/etc/hosts
echo "hosts file updated"

# Integrate with liferay if enabled
liferay_integration=${liferay_integration:-"no"} ;
if [ "$liferay_integration" == "yes" ] ; then
    echo "Liferay integration enabled"
    alfresco_properties_file=$ALFRESCO_TOMCAT_HOME/shared/classes/alfresco-global.properties
    echo "" >> $alfresco_properties_file
    echo "authentication.chain=alfrescoNtlm1:alfrescoNtlm,external1:external" >> $alfresco_properties_file
    echo "external.authentication.proxyUserName=" >> $alfresco_properties_file
    mkdir -p $ALFRESCO_TOMCAT_HOME/webapps/integration
    cp $ALFRESCO_TOMCAT_HOME/webapps/share.war $ALFRESCO_TOMCAT_HOME/webapps/integration
    echo "share.war available at http://<alfresco IP>:8080/integration/share.war"
fi

#Integrate with MySQL if enabled
mysql_integration=${mysql_integration:-"no"} ;
if [ $mysql_integration == "yes" ] ; then
    echo "MySQL intregration enabled"
    #Configuring alfresco for Mysql JDBC driver
    mysql_connector_jar=`tar -tzf $mysql_connector  | grep -e "mysql-connector-java.*bin\.jar$"` ; 
    tar -xzf $mysql_connector $mysql_connector_jar ;
    cp $mysql_connector_jar $ALFRESCO_TOMCAT_HOME/lib
fi