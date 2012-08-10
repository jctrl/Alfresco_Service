#!/bin/bash
#################################################################################################
# NAME
#   install.sh
#   
# LAST MODIFIED
#   27-June-2012
#
# SYNOPSIS
#       
# DESCRIPTION
#     This script installs Alfresco Enterprise Bundle. This Script is written only for Alfresco Enterprise 4.0.1
#     bundle 
#
# ENVIRONMENT
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

#- Check validity of OS 
if [ "x$OS" = "x" ]  ; then 
	echo "Unknown OS"
	exit 1
elif [ $OS != 'CentOS' ] ; then 
  	echo "This OS is not supported"
	exit 1
fi        

# Validate Mandatory Arguments
if [ "x$alfresco_admin_password" = "x" ] ; then 
	echo "Mandatory Property  'alfresco_admin_password' is not defined "
	exit 1
fi
if [ "x$installer_url" = "x" ] ; then 
	echo "Mandatory Property  'installer_url' is not defined "
	exit 1
fi

# Validate Mandatory Arguments for MySql integration
mysql_integration=${mysql_integration:-"no"} 
#mandatory_args = ( mysql_db_name mysql_db_username mysql_db_password mysql_connector mysql_db_driver mysql_server_ip )
if [ $mysql_integration == "yes" ] ; then
    error_message=""
	if [ "x$mysql_db_name" = "x" ] ; then 
	    error_message="$error_message\nMandatory Property  'mysql_db_name' is not defined for mysql integration" 
	fi
	if [ "x$mysql_db_username" = "x" ] ; then 
		error_message="$error_message\nMandatory Property  'mysql_db_username' is not defined for mysql integration"
	fi
	if [ "x$mysql_db_password" = "x" ] ; then 
		error_message="$error_message\nMandatory Property  'mysql_db_password' is not defined for mysql integration "
	fi
	if [ "x$mysql_db_driver" = "x" ] ; then 
		error_message="$error_message\nMandatory Property  'mysql_db_driver' is not defined for mysql integration "
	fi
	if [ "x$mysql_connector" = "x" ] ; then 
		error_message="$error_message\nMandatory Property  'mysql_connector' is not defined for mysql integration "
	fi
	if [ "x$mysql_server_ip" = "x" ] ; then 
		error_message="$error_message\nMandatory Property  'mysql_server_ip' is not defined for mysql integration "
	fi
	
	if [ "x$error_message" != "x" ] ; then
	    echo -e $error_message
	    exit 1
	fi
	
fi

# Install the application
if [ ! -f $installer_url ] ; then  # Check if Alfresco Installer file exists
    echo "Application installer not found."
    exit 1
else 
    echo "Setting execute permissions for installer"
    chmod +x $installer_url

    echo "Installing Alfresco Enterprise"
    if [ $mysql_integration == "yes" ] ; then
        echo "MySQL integration enabled for alfresco"            
        echo "Installing Alfresco with MySQL integration enabled"
        jdbc_url="jdbc:mysql://$mysql_server_ip/$mysql_db_name?useUnicode=yes&characterEncoding=UTF-8"
        install_command="$installer_url --mode unattended --alfresco_admin_password $alfresco_admin_password --disable-components postgres --jdbc_url $jdbc_url --jdbc_database $mysql_db_name --jdbc_username $mysql_db_username --jdbc_password $mysql_db_password --jdbc_driver $mysql_db_driver "
    else 
        install_command="$installer_url --mode unattended --alfresco_admin_password $alfresco_admin_password"        
    fi
    
    echo "Installation Started at `date`"
    echo "Executing command '$install_command' to install alfresco"
    $install_command
    echo "Installation completed at `date`"
    
    # Set properties required by other lifecycle stages
    ALFRESCO_HOME=/opt/alfresco-4.0.1
    ALFRESCO_TOMCAT_HOME=$ALFRESCO_HOME/tomcat

    # allow non tty sessions
    #sed -i 's/Defaults    requiretty/#Defaults requiretty/g' /etc/sudoers
fi
