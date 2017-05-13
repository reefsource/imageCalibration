FROM hblasins/image-preprocess
MAINTAINER Henryk Blasinski <hblasins@stanford.edu>

# Install the MCR dependencies and some things we'll need and download the MCR
# from Mathworks -silently install it
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
    dcraw \
    unzip \
    wget \
    curl \
    libssl-dev \
    libffi-dev \
    python-dev

RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y keyboard-configuration
RUN apt-get install -y --no-install-recommends xorg

RUN mkdir /mcr-install && \
    mkdir /opt/mcr && \
    cd /mcr-install && \
    wget --quiet https://www.mathworks.com/supportfiles/downloads/R2016a/deployment_files/R2016a/installers/glnxa64/MCR_R2016a_glnxa64_installer.zip && \
    cd /mcr-install && \
    unzip -q MCR_R2016a_glnxa64_installer.zip && \
    ./install -destinationFolder /opt/mcr -agreeToLicense yes -mode silent && \
    cd / && \
    rm -rf mcr-install

# Configure environment variables for MCR
# ENV LD_LIBRARY_PATH /opt/mcr/v901/runtime/glnxa64:/opt/mcr/v901/bin/glnxa64:/opt/mcr/v901/sys/os/glnxa64
ENV XAPPLRESDIR /opt/mcr/v901/X11/app-defaults

COPY bin/image-analyze-aws.sh /image-analyze-aws.sh
COPY bin/image-analyze.sh /image-analyze.sh

COPY libs/analyzeImage /analyzeImage
COPY libs/meta.mat /data/meta.mat
COPY libs/normalizer.mat /data/descriptors/normalizer.mat
COPY libs/libsvm /data/libsvm
COPY libs/model.dat /data/descriptors/model.dat
COPY libs/svmLinearData.mat /data/svmLinearData.mat

WORKDIR /data/libsvm
RUN make clean
RUN make
WORKDIR /

ENTRYPOINT ["./image-analyze-aws.sh"]
