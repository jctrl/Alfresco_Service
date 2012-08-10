#!/bin/bash
#################################################################################################
# NAME
#   start.sh
#   
# LAST MODIFIED
#   27-June-2012
#
# SYNOPSIS
#   	
# DESCRIPTION
# 	This script installs Alfresco Enterprise Bundle
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

# set -u, will exit your script if you try to use an uninitialised variable 
set -u

# Import Global conf
. $global_conf

export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# start the alfresco service
/etc/init.d/alfresco start

# Check alfresco tomcat startup
echo "Checking alfresco tomcat startup...."
# Wait for tomcat server to start completely
tomcat_startup_timeout_time=${tomcat_startup_timeout_time:-2400} ;#default value 2400 seconds  ,40 minutes
interval=60 ;# 30 seconds interval between lookups
tomcat_log=$ALFRESCO_TOMCAT_HOME/logs/catalina.out
touch $tomcat_log ;# Create the log file in case it is not created
no_of_lines=$(wc -l $tomcat_log | awk '{print $1}');# Get number of lines in tomcat log file
t1=`date +%s` ;# Capture current time in seconds since 1970-01-01 00:00:00 UTC
while [ 1 ]
do
    sleep $interval ; # sleep for sometime before checking Server startup message
    t2=`date +%s`; #Capture current time in seconds since 1970-01-01 00:00:00 UTC
    echo "Checking Alfresco tomcat startup after $[$t2-$t1] seconds..."
    if [ $[$t2-$t1] -ge $tomcat_startup_timeout_time ] ; then
        echo "Tomcat server did not start even after $timeout_time seconds"
        echo "Please see the logs '$tomcat_log' to find the root cause"
        exit 1
    fi

    # Check server staartup message in log file. If found then come out of while loop
    if tail -n +$[$no_of_lines +  1] $tomcat_log | grep -n "Server startup in" >> /dev/null ; then
        echo "Tomcat server startup completed"
        break ;#Server startup completed
    fi
done

# If we come here then tomcat is successfully started.
# There are chances Alfresco may not have started.
# Make sure Alfresco is really really running.
echo "Checking java process running status"
if ! ps -ef | grep java | grep alfresco  ; then
    echo "Tomcat server stopped after starting up successfully."
    echo "Please see the logs '$tomcat_log' to find the root cause"
    exit 1
fi

echo "Alfresco service started successfully...."