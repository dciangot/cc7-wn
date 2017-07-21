FROM centos:centos7
MAINTAINER Diego Ciangottini <diego.ciangottini@gmail.com>
ENV        TINI_VERSION v0.9.0
EXPOSE  5000
EXPOSE  22

# complete condor setup here: https://github.com/Cloud-PG/HTCondor-docker-centos
# wn metapackage: https://twiki.cern.ch/twiki/bin/view/LCG/EL7WNMiddleware 

# Add the extra system stuff we need
RUN yum install -y yum-plugin-ovl
RUN yum install -y epel-release
RUN yum update -y; yum clean all
RUN yum -y install wget
RUN wget -O /etc/yum.repos.d/centos-7-x86_64.repo http://repository.egi.eu/community/software/preview.repository/2.0/releases/repofiles/centos-7-x86_64.repo

RUN wget -O HEP.rpm http://linuxsoft.cern.ch/wlcg/centos7/x86_64/HEP_OSlibs-7.1.9-0.el7.cern.x86_64.rpm 
RUN yum install -y singularity

RUN yum -y install wn systemd
#RUN yum -y install voms xrootd-client gfal2 gfal2-util systemd
 
RUN groupadd -r condor && \
    useradd -r -g condor -d /var/lib/condor -s /sbin/nologin condor

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*; \
rm -f /etc/systemd/system/*.wants/*; \
rm -f /lib/systemd/system/local-fs.tar get.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*; \
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ “/sys/fs/cgroup” ]

WORKDIR /root

ADD  https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini

WORKDIR /etc/yum.repos.d
RUN wget http://research.cs.wisc.edu/htcondor/yum/repo.d/htcondor-development-rhel7.repo
RUN wget http://research.cs.wisc.edu/htcondor/yum/repo.d/htcondor-stable-rhel7.repo
RUN wget http://research.cs.wisc.edu/htcondor/yum/RPM-GPG-KEY-HTCondor
RUN rpm --import RPM-GPG-KEY-HTCondor
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

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/sbin/run.sh"]
#CMD ['/h']
