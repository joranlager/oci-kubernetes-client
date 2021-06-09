# oci-kubernetes-client DOCKERFILE
# --------------------------------

# This Dockerfile creates a Docker image to be used to run Kubernetes client (kubectl) commands against OKE in OCI.
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# docker build -f Dockerfile -t joranlager/oci-kubernetes-client:2.25.2-1.21.1 .
# docker tag joranlager/oci-kubernetes-client:2.25.2-1.21.1 joranlager/oci-kubernetes-client:latest
# docker push joranlager/oci-kubernetes-client:2.25.2-1.21.1
# docker push joranlager/oci-kubernetes-client:latest

FROM joranlager/oci-cli:2.25.2 AS installk8sandutils

# Maintainer
# ----------
MAINTAINER Joran Lager <joran.lager@oracle.com>

ENV OCI_CLI_SUPPRESS_FILE_PERMISSIONS_WARNING=True

USER root

COPY kubectl.sh /root/
COPY get-clusters.sh /oci/

ARG KUBERNETES_VERSION=v1.21.1
ARG HELM_VERSION=v3.5.4

RUN microdnf install iputils net-tools sudo curl gettext passwd git tar -y && \
microdnf clean all && \
ln -s /root/kubectl.sh /usr/local/bin/kubectl && \
ln -s /oci/get-clusters.sh /usr/local/bin/get-clusters && \
chmod 700 /root/kubectl.sh && \
chmod 700 /oci/get-clusters.sh && \
mkdir /kubectldl && cd /kubectldl && \
curl -L https://dl.k8s.io/release/$KUBERNETES_VERSION/bin/linux/amd64/kubectl -o kubectl && chmod +x kubectl && \
mv kubectl /usr/bin/kubectl && \
cd - && \
rm -rf /kubectldl && \
mkdir /helmdl && \
cd /helmdl && curl -L https://get.helm.sh/helm-$HELM_VERSION-linux-amd64.tar.gz -o helm.tar.gz && tar -zxvf helm.tar.gz && chmod +x linux-amd64/helm && \
mv linux-amd64/helm /usr/local/bin/helm && \
cd - && \
rm -rf /helmdl
#echo "source <(kubectl completion bash)" >> ~/.bashrc

WORKDIR /root
