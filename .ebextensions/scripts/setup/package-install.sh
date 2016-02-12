#!/bin/bash


# Execute "export DEBUG=1" to debug this script.
# Set value to 2 to debug this script and the scripts called within this script.
# Set value to 3,4,5 and so on to increase the nesting level of the scripts to be debugged.
[[ $DEBUG -gt 0 ]] && set -x; export DEBUG=$(($DEBUG - 1))


#
# Install all the required packages and utilities
#

yum -y install dos2unix mailx gcc git rubygem-json perl-XML-XPath perl-File-Slurp jwhois make libtool

yum -y install tomcat-native

yum -y remove httpd.x86_64 httpd-tools.x86_64
yum -y install httpd24.x86_64 httpd24-devel.x86_64 httpd24-tools.x86_64

yum -y install mysql

yum -y install libxml2 libxml2-devel.x86_64

yum -y install php56-devel php56 php56-mbstring php56-gd php56-xml php56-mcrypt

yum -y install php56-mysqlnd.x86_64 php56-pecl-apc

#yum -y install php-devel php php-mysql php-mbstring php-gd php-xml php-mcrypt
#yum -y install make php-pecl-apc

yum -y install geoip-devel

# install geoip PECL module
pecl channel-update pecl.php.net
sudo pecl install geoip

# Copy repo file to install mod-pagespeed
/bin/cp -f -R $ELASTICBEANSTALK_APP_DIR/.ebextensions/copy-to-slash/etc/yum.repos.d /etc/
yum -y install mod-pagespeed

#yum -y install mod_security

# install mod_security
if ([ ! -e /etc/httpd/modules/mod_security2.so ]) then
    pushd $ELASTICBEANSTALK_APP_DIR/tmp
    fileDownload=modsecurity-2.9.0.tar.gz
    urlDownload=https://www.modsecurity.org/tarball/2.9.0
    wget -q $urlDownload/$fileDownload
	tar -zxvf modsecurity-2.9.0.tar.gz
	cd modsecurity-2.9.0
	./autogen.sh
	./configure --enable-standalone-module 
	make
	make install
    popd
fi


# install elastic beanstalk command line utilities
if ([ ! -e /opt/aws/AWS-ElasticBeanstalk-CLI-2.2 ]) then
    pushd $ELASTICBEANSTALK_APP_DIR/tmp
    fileDownload=AWS-ElasticBeanstalk-CLI-2.2.zip
    urlDownload=https://s3.amazonaws.com/elasticbeanstalk/cli
    wget -q $urlDownload/$fileDownload
    unzip -q $fileDownload -d /opt/aws
    popd
fi


# install dnscurl script to manage Route53
if ([ ! -e /opt/aws/bin/dnscurl.pl ]) then
    pushd /opt/aws/bin
    fileDownload=dnscurl.pl
    urlDownload=http://awsmedia.s3.amazonaws.com/catalog/attachments
    wget -q $urlDownload/$fileDownload
    chmod 700 dnscurl.pl
    popd
fi


# install s3cmd
if ([ ! -e /etc/yum.repos.d/s3tools.repo ]) then
    pushd /etc/yum.repos.d
    wget -q http://s3tools.org/repo/RHEL_6/s3tools.repo
    yum -y install s3cmd
    popd
	
	#s3cmd works only with python2.6
	sed -i '1 s|^#!/usr/bin/python$|#!/usr/bin/python2.6|g' /usr/bin/s3cmd
fi
