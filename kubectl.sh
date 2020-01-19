#!/bin/bash

# if /root/.kube/config doesn't exist - try to use environment variables creating the kube config:
if [ ! -f "/root/.kube/config" ]
then
    /usr/bin/kubectl config set-credentials $service_account_name --token=$service_account_token_data >> /dev/null
    /usr/bin/kubectl config set-context sa-context --user=$service_account_name --cluster=$cluster_name >> /dev/null
    /usr/bin/kubectl config set-cluster $cluster_name --insecure-skip-tls-verify=false --server=$cluster_server >> /dev/null
    /usr/bin/kubectl config set clusters.$cluster_name.certificate-authority-data $certificate_authority_data >> /dev/null
    /usr/bin/kubectl config use-context sa-context >> /dev/null
fi

/usr/bin/kubectl "$@"
