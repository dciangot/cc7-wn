FROM cern/cc7-base:20170113

# Add the extra system stuff we need
RUN yum install -y yum-plugin-ovl
RUN yum -y update && yum -y install wget
RUN wget -O /etc/yum.repos.d/centos-7-x86_64.repo http://repository.egi.eu/community/software/preview.repository/2.0/releases/repofiles/centos-7-x86_64.repo

RUN wget -O HEP.rpm http://linuxsoft.cern.ch/wlcg/centos7/x86_64/HEP_OSlibs-7.1.9-0.el7.cern.x86_64.rpm 
RUN rpm -Uhv https://repo.grid.iu.edu/osg/3.3/osg-3.3-el7-release-latest.rpm  && yum install -y --enablerepo=osg-upcoming singularity 

RUN yum -y update && yum -y install apache-commons-cli apache-commons-io boost-python boost-python boost-system boost-thread bouncycastle bouncycastle-pkix canl-java c-ares cleanup-grid-accounts condor-classads copy-jdk-configs dcap dcap-devel dcap-libs dcap-tunnel-gsi dcap-tunnel-krb dcap-tunnel-ssl dcap-tunnel-telnet fetch-crl fuse fuse-libs ginfo glib2-devel glite-jobid-api glite-lb-client glite-lb-client-progs glite-lb-common glite-lbjp-common glite-lbjp-common-trio globus-callout gsoap java-1.8.0-openjdk java-1.8.0-openjdk-headless javapackages-tools lcg-info lcg-infosites lcg-ManageVOTag lcg-tags libattr-devel libdb-cxx libfontenc libXcomposite libXfont libxslt lksctp-tools mailcap openldap-clients openssl-devel perl-Authen-SASL perl-Business-ISBN perl-Business-ISBN-Data perl-Compress-Raw-Bzip2 perl-Compress-Raw-Zlib perl-Convert-ASN1 perl-DBI perl-Digest perl-Digest-HMAC perl-Digest-MD5 perl-Digest-SHA perl-Encode-Locale perl-Env perl-File-Listing perl-GSSAPI perl-HTML-Parser perl-HTML-Tagset perl-HTTP-Cookies perl-HTTP-Daemon perl-HTTP-Date perl-HTTP-Message perl-HTTP-Negotiate perl-IO-Compress perl-IO-HTML perl-IO-Socket-IP perl-IO-Socket-SSL perl-JSON perl-LDAP perl-libwww-perl perl-LWP-MediaTypes perl-Net-Daemon perl-Net-HTTP perl-Net-LibIDN perl-Net-SSLeay perl-PlRPC perl-Sys-Syslog perl-Text-Soundex perl-Text-Unidecode perl-TimeDate perl-URI perl-WWW-RobotRules perl-XML-Filter-BufferText perl-XML-NamespaceSupport perl-XML-Parser perl-XML-SAX perl-XML-SAX-Base perl-XML-SAX-Writer pugixml python python-javapackages python-ldap python-libs python-lxml ttmkfdir tzdata-java uberftp voms voms-api-java voms-clients-java voms-devel xmlsec1 xmlsec1-openssl xorg-x11-fonts-Type1 xorg-x11-font-utils zlib

RUN yum clean all
CMD ['/h']
