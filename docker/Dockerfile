FROM centos:7

ARG TEST_USER=test
ARG TEST_USER_UID=501

ENV TEST_USER $TEST_USER
ENV TEST_USER_UID $TEST_USER_UID

RUN   yum clean all && \
      yum install -y hostname epel-release && \
      yum -y update && \
      yum -y install which wget tar gcc openssl-devel sudo file make which python36 && \
      echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
      adduser --uid ${TEST_USER_UID} ${TEST_USER} && \
      usermod -a -G wheel ${TEST_USER} && \
      mkdir /home/test/.config && chown test:test /home/test/.config && \
      yum -y install telnet nc

RUN cd /root && \
    wget https://curl.haxx.se/download/curl-7.72.0.tar.gz && \
    tar xvzf curl-7.72.0.tar.gz && \
    cd curl-7.72.0 && \
    ./configure --with-ssl --disable-dependency-tracking && \
    make && make install && \
    cd .. && rm -rf curl-7.72.0 && rm curl-7.72.0.tar.gz

RUN wget https://ci.cloud.cnaf.infn.it/view/repos/job/repo_test_ca/lastSuccessfulBuild/artifact/test-ca.repo -O /etc/yum.repos.d/test-ca.repo && \
    yum -y clean all && yum -y install igi-test-ca && \
    mkdir -p /home/test/.globus && cp /usr/share/igi-test-ca/test0.p12 /home/test/.globus/usercred.p12 && \
    chmod 600 /home/test/.globus/usercred.p12 && \
    chown -R test:test /home/test/.globus

RUN yum -y install voms-clients-java gfal2-util gfal2-all gfal2-python davix jq && \
    curl -sL https://rpm.nodesource.com/setup_14.x | bash - && \
    yum install -y nodejs && \
    npm install -g jwt-cli && \
    yum clean all && \
    wget https://repo.data.kit.edu/data-kit-edu-centos7.repo -O /etc/yum.repos.d/data-kit-edu-centos7.repo && \
    yum install -y oidc-agent && \
    pip3 install --upgrade pip && \
    pip3 install --upgrade robotframework-httplibrary && \
    pip3 install --upgrade oic && \
    pip3 install --upgrade requests && \
    pip3 install --upgrade pyyaml && \
    pip3 install --upgrade shyaml && \
    # bug in newer pyjwt version reported in https://github.com/Azure/azure-sdk-for-python/issues/16035
    pip3 install pyjwt==1.7.0 && \
    rm -rf /var/cache/yum

ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

USER test
WORKDIR /home/test

