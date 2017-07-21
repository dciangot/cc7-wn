FROM cern/cc7-base:20170113
MAINTAINER Diego Ciangottini <diego.ciangottini@gmail.com>
ENV        TINI_VERSION v0.9.0
EXPOSE  5000
EXPOSE  22

# complete condor setup here: https://github.com/Cloud-PG/HTCondor-docker-centos

#--- Environment variables
ENV USER="user"
ENV USER_HOME="/home/user"

# Add the extra system stuff we need
RUN yum install -y yum-plugin-ovl
RUN yum -y update && yum -y install wget
RUN wget -O /etc/yum.repos.d/centos-7-x86_64.repo http://repository.egi.eu/community/software/preview.repository/2.0/releases/repofiles/centos-7-x86_64.repo

RUN wget -O HEP.rpm http://linuxsoft.cern.ch/wlcg/centos7/x86_64/HEP_OSlibs-7.1.9-0.el7.cern.x86_64.rpm 
RUN rpm -Uhv https://repo.grid.iu.edu/osg/3.3/osg-3.3-el7-release-latest.rpm  && yum install -y --enablerepo=osg-upcoming singularity 

RUN yum install -y epel-release
RUN yum update -y; yum clean all
RUN yum -y install initscripts
RUN yum -y install freetype fuse sudo glibc-devel glibc-headers
RUN yum -y install man nano emacs openssh-server openssl098e libXext libXpm curl wget vim
RUN yum -y install git gsl-devel freetype-devel libSM libX11-devel libXext-devel make gcc-c++
RUN yum -y install gcc binutils libXpm-devel libXft-devel boost-devel
RUN yum -y install ncurses ncurses-devel
RUN yum install -y cvs openssh-clients

RUN yum -y install apache-commons-cli apache-commons-io boost-python boost-python boost-system boost-thread bouncycastle bouncycastle-pkix canl-java c-ares cleanup-grid-accounts condor-classads copy-jdk-configs dcap dcap-devel dcap-libs dcap-tunnel-gsi dcap-tunnel-krb dcap-tunnel-ssl dcap-tunnel-telnet fetch-crl fuse fuse-libs ginfo glib2-devel glite-jobid-api glite-lb-client glite-lb-client-progs glite-lb-common glite-lbjp-common glite-lbjp-common-trio globus-callout gsoap java-1.8.0-openjdk java-1.8.0-openjdk-headless javapackages-tools lcg-info lcg-infosites lcg-ManageVOTag lcg-tags libattr-devel libdb-cxx libfontenc libXcomposite libXfont libxslt lksctp-tools mailcap openldap-clients openssl-devel perl-Authen-SASL perl-Business-ISBN perl-Business-ISBN-Data perl-Compress-Raw-Bzip2 perl-Compress-Raw-Zlib perl-Convert-ASN1 perl-DBI perl-Digest perl-Digest-HMAC perl-Digest-MD5 perl-Digest-SHA perl-Encode-Locale perl-Env perl-File-Listing perl-GSSAPI perl-HTML-Parser perl-HTML-Tagset perl-HTTP-Cookies perl-HTTP-Daemon perl-HTTP-Date perl-HTTP-Message perl-HTTP-Negotiate perl-IO-Compress perl-IO-HTML perl-IO-Socket-IP perl-IO-Socket-SSL perl-JSON perl-LDAP perl-libwww-perl perl-LWP-MediaTypes perl-Net-Daemon perl-Net-HTTP perl-Net-LibIDN perl-Net-SSLeay perl-PlRPC perl-Sys-Syslog perl-Text-Soundex perl-Text-Unidecode perl-TimeDate perl-URI perl-WWW-RobotRules perl-XML-Filter-BufferText perl-XML-NamespaceSupport perl-XML-Parser perl-XML-SAX perl-XML-SAX-Base perl-XML-SAX-Writer pugixml python python-javapackages python-ldap python-libs python-lxml ttmkfdir tzdata-java uberftp voms voms-api-java voms-clients-java voms-devel xmlsec1 xmlsec1-openssl xorg-x11-fonts-Type1 xorg-x11-font-utils zlib

RUN yum -y install systemd; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*; \
rm -f /etc/systemd/system/*.wants/*; \
rm -f /lib/systemd/system/local-fs.tar get.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*; \
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ “/sys/fs/cgroup” ]

WORKDIR /root

# Setting up a user
RUN adduser $USER -d $USER_HOME && echo "$USER:user" | chpasswd && \
    echo "$USER ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER && \
        chmod 0440 /etc/sudoers.d/$USER
        RUN chown -R $USER $USER_HOME

        COPY dot-bashrc $USER_HOME/.bashrc
        RUN chown $USER $USER_HOME/.bashrc
        RUN mkdir $USER_HOME/.ssh
        RUN chown $USER:$USER $USER_HOME/.ssh

ADD  https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini

WORKDIR /etc/yum.repos.d
RUN wget http://research.cs.wisc.edu/htcondor/yum/repo.d/htcondor-development-rhel7.repo
RUN wget http://research.cs.wisc.edu/htcondor/yum/repo.d/htcondor-stable-rhel7.repo
RUN wget http://research.cs.wisc.edu/htcondor/yum/RPM-GPG-KEY-HTCondor
RUN rpm --import RPM-GPG-KEY-HTCondor
RUN yum-config-manager --enable onedata
RUN yum install -y condor-all 

RUN yum install -y python-pip && pip install supervisor supervisor-stdout && \
     mkdir -p /opt/health/master/ /opt/health/executor/ && \
     pip install Flask

RUN pip install --upgrade pip && \
    pip install --upgrade setuptools

USER    root
WORKDIR /root
RUN     chmod u+x /sbin/tini

COPY    supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY    condor_config /etc/condor/condor_config
COPY    executor_healthcheck.py /opt/health/executor/healthcheck.py
COPY    master_healthcheck.py /opt/health/master/healthcheck.py
COPY    sshd_config /etc/ssh/sshd_config
COPY    run.sh /usr/local/sbin/run.sh

RUN yum clean all

RUN     ln -s /usr/lib64/condor /usr/lib/condor
RUN     ln -s /usr/libexec/condor /usr/lib/condor/libexec

#ENTRYPOINT ["/sbin/tini", "--", "/usr/local/sbin/run.sh"]
CMD ['/h']
