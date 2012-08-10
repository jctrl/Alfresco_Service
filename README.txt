This demonstrates creating a standalone Alfresco service.
  
!! IMPORTANT POINT REGARDING PROPERTIES !!
When dealing with setting up properties in this demo take care to notice the Property Type.
If you are downloading any file this must be of type content. If you use another type there is a good chance your deployment will fail.

Steps

1. Create a new service in the catalog.

2. Use the following values for the service details:

	Name: Alfresco
	Version: 4.0.1
	Description: Content management Server
	Tags: "Others"
	Supported OSes: "CentOS 5.6 64bit"
	Supported Components: 

    See alfresco_service_details.png for an example.

3. Use the properties in the "Alfresco_Properties.xlsx" file to specify the properties for the service in the service "Properties" pane.
   See "Al_Properties.JPG" for an example.


4. Add the install.sh, configure.sh, and start.sh script contents to the service lifecycles.
   For each one use the corresponding prefixed alfresco*.sh file included.

5. Get the Alfreco Enterprise 4.0.1 installer to some shared location.
   
NOTES:

* Each property is explained in the "Description" field of the property in Alfresco_Properties.xlsx.
    

* The darwin_global.conf file is an example how you can make shared properties accessible through all the types of scripts.
  Where you see '. $global_conf', this is mapped to the global_conf content property.

* Most properties are set to a default value. And they can be modified in the blueprint before the deployment.

***

