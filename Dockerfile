FROM hblasins/image-preprocess
MAINTAINER Henryk Blasinski <hblasins@stanford.edu>

# Install the MCR dependencies and some things we'll need and download the MCR
# from Mathworks -silently install it
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
    dcraw \
    unzip \
    xorg \
    wget \
    curl \
    libssl-dev \
    libffi-dev \
    python-dev

RUN mkdir /mcr-install && \
    mkdir /opt/mcr && \
    cd /mcr-install && \
    wget https://www.mathworks.com/supportfiles/downloads/R2016a/deployment_files/R2016a/installers/glnxa64/MCR_R2016a_glnxa64_installer.zip && \
    cd /mcr-install && \
    unzip -q MCR_R2016a_glnxa64_installer.zip && \
    ./install -destinationFolder /opt/mcr -agreeToLicense yes -mode silent && \
    cd / && \
    rm -rf mcr-install

# Configure environment variables for MCR
# ENV LD_LIBRARY_PATH /opt/mcr/v901/runtime/glnxa64:/opt/mcr/v901/bin/glnxa64:/opt/mcr/v901/sys/os/glnxa64
ENV XAPPLRESDIR /opt/mcr/v901/X11/app-defaults

COPY src/image-analyze-aws.sh /image-analyze-aws.sh
COPY src/image-analyze.sh /image-analyze.sh

COPY libs/analyzeImage /analyzeImage
COPY libs/devkit/meta.mat /data/meta.mat
COPY libs/devkit/descriptors/normalizer.mat /data/descriptors/normalizer.mat
COPY libs/devkit/libsvm /data/libsvm
COPY libs/devkit/descriptors/model.dat /data/descriptors/model.dat
COPY libs/svmLinearData.mat /data/svmLinearData.mat

WORKDIR /data/libsvm
RUN make clean
RUN make
WORKDIR /

ENTRYPOINT ["./bin/image-analyze-aws.sh"]