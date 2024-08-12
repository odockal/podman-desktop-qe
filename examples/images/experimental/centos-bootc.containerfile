FROM quay.io/centos-bootc/centos-bootc:stream9

# Change the root password
RUN echo "root:root" | chpasswd
