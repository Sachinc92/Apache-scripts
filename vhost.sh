##############################################
#AUTHOR            	: SACHIN
#MAIL			          : sachinsacc@live.in		   
#DATE OF CREATION	  : 03-07-2014		   
##############################################

#   USAGE
#  -------
#vhost add         : Creates new virtual host
#vhost drop        : Remove existing virtualhost
#vhost list        : List existing virtualhosts
#vhost enabled     : List enabled virtualhosts
#vhost help        : Help


#!/bin/bash

### Checking for user
if [ "$(whoami)" != 'root' ]; then
        echo "You do not have permission to run vhost command, Use sudo"
        exit 1;
fi

clear

vhroot='/etc/apache2/sites-available'
certfile="/etc/ssl/certs/ssl-cert-snakeoil.pem"
keyfile="/etc/ssl/private/ssl-cert-snakeoil.key"


create_site () {
### Configure vhost dir
iserror='no'
hosterror=''
direrror=''

# Take inputs host name and root directory

echo " "
echo "-------------------------------------------------------------------"
echo "Please create your directory in the document root before you start."
echo "-------------------------------------------------------------------"
echo " "
echo -n "Please provide site name [eg:www.example.com] : "
read  hostname
echo -n "Please provide web root directory [eg:/var/www/site_name] : "
read rootdir

### Check inputs
if [ "$hostname" = "" ]
then
    iserror="yes"
    hosterror="Please provide domain name."
fi


if [ "$rootdir" = "" ]
then
    iserror="yes"
    direrror="Please provide web root directory name."
fi


### Displaying errors
if [ "$iserror" = "yes" ]
then
    echo "Please correct following errors:"
    if [ "$hosterror" != "" ]
    then
        echo "$hosterror"
    fi


    if [ "$direrror" != "" ]
    then
        echo "$direrror"
    fi
    exit;
fi


### check whether hostname already exists
if [ -e $vhroot"/"$hostname ]; then
    iserror="yes"
    hosterror="Hostname already exists. Please provide another hostname."
fi


### check if directory exists or not
if ! [ -d $rootdir ]; then
    iserror="yes"
    direrror="Directory provided does not exists.";
fi


### Displaying errors
if [ "$iserror" = "yes" ]
then
    echo "Please correct following errors:"
    if [ "$hosterror" != "" ]
    then
        echo "$hosterror"
    fi


    if [ "$direrror" != "" ]
    then
        echo "$direrror"
    fi
    exit;
fi


if ! touch $vhroot/$hostname
then
        echo -e "ERROR: "$vhroot"/"$hostname" could not be created."
else

echo -n "Do you want to add 'https' in configuration [y/n] :"
read https

  if [ "$https" = "n" ]; then
           	echo "<VirtualHost *:80>
		ServerName $hostname
		ServerAlias $hostname www.$hostname
		DocumentRoot $rootdir
		<Directory $rootdir>
		        AllowOverride All
			Order allow,deny
                	allow from all
		</Directory>
		ErrorLog /var/log/apache2/$hostname
		 LogLevel error
		CustomLog /var/log/apache2/$hostname custom
</VirtualHost>" > $vhroot/$hostname.conf
		echo -e "\nNew virtual host added to the Apache vhosts file"

  elif [ "$https" = "y" ]; then
	echo -n "Please enter cerificate path[default:$certfile]:"
	read cert
	echo -n "Please enter key file path[default:$keyfile]:"
	read key
	 		if [ ! -n "$cert" ]; then
                cert=$certfile
        	fi
        	if [ ! -n "$key" ]; then
                key=$keyfile
        	fi
		echo "<VirtualHost *:80>
                ServerName $hostname
                ServerAlias $hostname www.$hostname
                DocumentRoot $rootdir
                <Directory $rootdir>
                        AllowOverride All
			Order allow,deny
                	allow from all
                </Directory>
                ErrorLog /var/log/apache2/$hostname
                 LogLevel error
                CustomLog /var/log/apache2/$hostname custom
</VirtualHost>

<IfModule mod_ssl.c>
		<VirtualHost *:443>
	        ServerName $hostname
        	DocumentRoot $rootdir 
	        <Directory $rootdir>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        	</Directory>
   		SSLEngine on
		SSLCertificateFile   $cert 
		SSLCertificateKeyFile $key
		</VirtualHost>
</IfModule>" > $vhroot/$hostname
        echo "\nNew virtual host added to the Apache vhosts file"
        else 
	echo "Please provide valid option\n"
	exit 1;

	fi
fi

### Add hostname in /etc/hosts
if ! echo "127.0.0.1       $hostname" >> /etc/hosts
then
   echo "ERROR: Not able write in /etc/hosts"
else
    echo "Host added to /etc/hosts file"
fi


### enable website
a2ensite $hostname.conf &> /dev/null


### restart Apache
apache2ctl graceful


### give permission to root dir
chmod 755 $rootdir


#if ! touch $rootdir/phpinfo.php
#then
#    echo "ERROR: "$rootdir"/phpinfo.php could not be created."
#else
#    echo ""$rootdir"/phpinfo.php created."
#fi
#if ! echo "<?php
#echo phpinfo();
#?>" > $rootdir/phpinfo.php
#then
#    echo "ERROR: Not able to write in file "$rootdir"/phpinfo.php. Please check permissions."
#else
#    echo "Added content to "$rootdir"/phpinfo.php."
#fi


# show the finished message
echo -e "\nComplete! The new virtual host has been created. Now you can check the status at http://"$hostname"
Document root for this site is "$rootdir"/"$hostname
echo ""

}

remove_site () {
echo " "
echo "###########################################################"
echo "  Warning: You are about to remove a site configuration"
echo "###########################################################"
echo " "
echo -n "Please provide site name [eg:www.example.com] : "
read  hostname
### Check inputs

if [ "$hostname" = "" ]
  then
    echo -e "\nPlease provide domain name.\n"
    exit 1;

       else
## checking vhost file
             if [ -e "$vhroot"/"$hostname" ]; then
	        echo -n "Would you like to backup this configuration [y/n]:"
		read option
			if [ "$option" = "y" ]; then

				cp $vhroot"/"$hostname $vhroot"/"$hostname.bkp
				##disabling site
                            	a2dissite $hostname &> /dev/null
                        	##removing configuration
                            	rm -rf $vhroot"/"$hostname
                        	### restart Apache
                           	/etc/init.d/apache2 reload
                        	echo -e "$hostname has been successfully removed.\n"

			elif [ "$option" = "n" ]; then
			 
				##disabling site
			    	a2dissite $hostname &> /dev/null
				##removing configuration
			    	rm -rf $vhroot"/"$hostname		
				### restart Apache
			   	/etc/init.d/apache2 reload
				echo -e "$hostname has been successfully removed.\n"
			fi
	exit 1;
  else
	echo -e "\n'$hostname' does not exists.Please enter valid virtualhost name.\n"
  fi
		
fi


}

##List existing sites
list_site () {
ls /etc/apache2/sites-available |sort|less
}

## List enabled web sited
list_enabled () {
ls /etc/apache2/sites-enabled |sort|less
}

###Vhost command usage
usage () {
echo "AUTHOR                 : SACHIN"
echo "MAIL                   : sachinsacc@live.in"
echo "DATE OF CREATION       : 03-07-2014"
echo "PLACE                  : CUBET TECHNOLABS"
echo "------------------------------------------------"
echo ""
echo "Syntax"
echo "------"
echo "vhost add         : Creates new virtual host"
echo "vhost drop        : Remove existing virtualhost"
echo "vhost list        : List existing virtualhosts"
echo "vhost enabled     : List enabled virtualhosts"
echo "vhost help        : Help\n"
}


ACTION=`echo $1 | tr '[:upper:]' '[:lower:]'`
case $ACTION in
        "add")
                create_site
                ;;
        "drop")
                remove_site
                ;;
	"list")
		list_site
		;;
	"enabled")
                list_site
                ;;
	"help")
                usage
                ;;
        *)
                echo  "Invalid option. Run vhost help\n"
esac
