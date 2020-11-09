FROM ubuntu:xenial
ENV DEBIAN_FRONTEND noninteractive
COPY sources.list /etc/apt/sources.list

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DC6A13A3 && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 56A3D45E  && \
    apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
            wget \
            unzip \
            composer \
            zlib1g-dev \
            php-cli \
            php-dev \
            php-pear && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Go
RUN mkdir temporary && \
    cd temporary && \
    wget https://dl.google.com/go/go1.15.3.linux-amd64.tar.gz && \
    tar -xvf go1.15.3.linux-amd64.tar.gz && \
    mv go /usr/local

WORKDIR /root
RUN wget https://github.com/google/protobuf/releases/download/v3.13.0/protoc-3.13.0-linux-x86_64.zip && \
    mkdir protoc && cd protoc && \
    unzip ../protoc-3.13.0-linux-x86_64.zip && \
    cd ../ && mv protoc /opt/protoc && \
    echo 'eval `/usr/local/go/bin/go env`' >> ~/.bashrc && \
    echo "PATH=$HOME/go/bin:/usr/local/go/bin:$PATH:/opt/protoc/bin" >> ~/.bashrc

RUN pecl install grpc
RUN git clone --recursive -b v1.33.x https://github.com/grpc/grpc /root/grpc && \
    cd /root/grpc && \
    make grpc_php_plugin && \
    cp /root/grpc/bins/opt/grpc_php_plugin /usr/local/bin/ && \
    cd /usr/local/bin/ && \
    ln -s grpc_php_plugin protoc-gen-grpc

RUN /usr/local/go/bin/go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway

COPY grpc.php.ini /etc/php/7.4/cli/conf.d/grpc.ini
