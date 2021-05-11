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

ENV OCI_CLI_SUPPRESS_FILE_PERMISSIONS_WARNING=True

USER root

COPY kubectl.sh /root/
COPY get-clusters.sh /oci/

ARG KUBERNETES_VERSION=v1.21.0

RUN curl -L https://dl.k8s.io/release/$KUBERNETES_VERSION/bin/linux/amd64/kubectl -o /usr/bin/kubectl;chmod +x /usr/bin/kubectl && \
#curl -LO "https://dl.k8s.io/release/$KUBERNETES_VERSION/bin/linux/amd64/kubectl.sha256" && \
#echo "$(<kubectl.sha256) kubectl" | sha256sum --check && \
microdnf install iputils net-tools sudo curl gettext passwd -y && \
microdnf clean all && \
ln -s /root/kubectl.sh /usr/local/bin/kubectl && \
ln -s /oci/get-clusters.sh /usr/local/bin/get-clusters && \
chmod 700 /root/kubectl.sh && \
chmod 700 /oci/get-clusters.sh
#echo "source <(kubectl completion bash)" >> ~/.bashrc

WORKDIR /root
