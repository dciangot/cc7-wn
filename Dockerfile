FROM cern/cc7-base:20170113

# Add the extra system stuff we need
RUN yum install -y yum-plugin-ovl
RUN yum -y update && yum -y install wget
RUN wget -O HEP.rpm http://linuxsoft.cern.ch/wlcg/centos7/x86_64/HEP_OSlibs-7.1.9-0.el7.cern.x86_64.rpm && wget -O OSG.rpm https://repo.grid.iu.edu/osg/3.3/osg-3.3-el6-release-latest.rpm && yum -y install HEP.rpm OSG.rpm && yum clean all
RUN yum -y install cronie yum-plugin-priorities e2fsprogs git voms-clients-cpp osg-ca-certs vo-client && yum clean all
CMD ['/bin/sh']
