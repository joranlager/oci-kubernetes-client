# oci-kubernetes-client DOCKERFILE
# --------------------------------

# This Dockerfile creates a Docker image to be used to run Kubernetes client (kubectl) commands against OKE in OCI.
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# docker build -f Dockerfile -t joranlager/oci-kubernetes-client:latest .
# docker push joranlager/oci-kubernetes-client:latest

FROM joranlager/oci-cli:latest AS installk8sandutils

# Maintainer
# ----------
MAINTAINER Joran Lager <joran.lager@oracle.com>

USER root

COPY kubectl.sh /root/
COPY get-clusters.sh /oci/

RUN yum install yum-utils -y && \
yum-config-manager --enable ol7_addons && \
yum install kubectl iputils net-tools sudo curl gettext passwd -y && \
yum clean all && \
#yum remove -y yum-utils && \
rm -rf /var/cache/yum/* && \
chmod 700 /root/kubectl.sh && \
chmod 700 /oci/get-clusters.sh && \
ln -s /root/kubectl.sh /usr/local/bin/kubectl && \
ln -s /oci/get-clusters.sh /usr/local/bin/get-clusters && \
echo "source <(kubectl completion bash)" >> ~/.bashrc

WORKDIR /root
