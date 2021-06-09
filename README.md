# oci-kubernetes-client - containerized Kubernetes Client for OCI

# Running the oci-kubernetes-client

Before using the image, please create and prepare a directory to contain the Tenancy-specific files and directories.
The following structure is an example:

```
mytenancy (Dir)
  .oci (Dir)
  .kube (Dir)
  kubernetes-yamls (Dir)
  tenancy.env (File)
```
Can be created with these commands (Bash) - please make sure to replace the values in the tenancy.env with something that matches your Tenancy and User (The values can be found using the Oracle Cloud Infrastructure web UI.):

```
mkdir -p mytenancy/.oci
mkdir -p mytenancy/.kube
mkdir -p mytenancy/kubernetes-yamls
cat << EOF > mytenancy/tenancy.env
OCI_TENANCY_NAME=mytenancy
OCI_TENANCY_OCID=ocid1.tenancy.oc1..aaaaaaaaflf2uasrxxxqvwvvbcmvuk52fndxxxs3byra
OCI_USER_OCID=ocid1.user.oc1..aaaaaaaanufslfkvk7rnjjxxxv6uupomxxxxhda
OCI_REGION=eu-frankfurt-1
EOF
```

## Interactive

This will run the oci-kubernetes-client in Interactive mode and give access to the "kubernetes-yamls" directory within the prepared host directory. That Directory would potentially contain Source Code managed Kubernetes YAML files to be used with the kubectl Kubernetes Client.
The Kubernetes Client has autocomplete enabled, so hitting TAB will give completion alternatives.

### Exposing ports from an oci-kubernetes-client container
This Example show the exposure of the Container Port 8001 on the Host Port 8001.
This is only required if we want to run kubectl proxy and access (amongst other), the Kubernetes Dashboard application from the Docker host.

### Mount host directories as prepared to enable the persistence of the .oci and .kube config directories on the host
Make sure to open a Shell and set the current working Directory to the directory containing the prepared files and directories.
Then for Windows Command Shell run:
```
docker run -it --rm -p 8001:8001 --mount type=bind,source="%cd%\.oci",target=/root/.oci --mount type=bind,source="%cd%\.kube",target=/root/.kube/ --mount type=bind,source="%cd%\kubernetes-yamls",target=/root/kubernetes-yamls --env-file "%cd%\tenancy.env" joranlager/oci-kubernetes-client
```

Or for Bash run:
```
docker run -it --rm -p 8001:8001 --mount type=bind,source="$(pwd)/.oci",target=/root/.oci --mount type=bind,source="$(pwd)/.kube",target=/root/.kube/ --mount type=bind,source="$(pwd)/kubernetes-yamls",target=/root/kubernetes-yamls --env-file "$(pwd)/tenancy.env" joranlager/oci-kubernetes-client
```


### Creating and setting the required certificates and Public Key to access OCI
For inital setup of the OCI CLI credentials / certificate of if you need to re-configure, run the setup-oci command in the container shell.
This will overwrite existing OCI CLI config in the .oci Directory on the host (Private and Public keys etc), so please make sure that is the intention.
```
setup-oci
```
Running the Script will display the Public Key in PEM format.
That content must be added as public authentication key for the given user:
1. Log in to the Oracle Cloud using a browser (https://console.eu-frankfurt-1.oraclecloud.com)
2. Navigate to Profile -> <user>, then select Resources -> API Keys and Add Public Key.
3. Paste the public key in PEM format and push Add button.


### Generate the .kube/config

Get the list of clusters for the given compartment name:
```
get-clusters mycompartment

Searching for Kubernetes cluster in compartment mycompartment ...
"Dive (v1.14.8) OCID ocid1.cluster.oc1.eu-frankfurt-1.aaaaaaaaae3wmyjqgxxxxxxxxxxxxxxxxxxxyyyyyyyyyyyyyyyyyyyyyyyg"
Done searching for Kubernetes cluster in compartment mycompartment
```

From the cluster list, find the cluster-id and create the kubeconfig to be able to access it:
```
oci ce cluster create-kubeconfig --cluster-id=ocid1.cluster.oc1.eu-frankfurt-1.aaaaaaaaae3wmyjqgxxxxxxxxxxxxxxxxxxxyyyyyyyyyyyyyyyyyyyyyyyg
```

Then, check access by fetching the list of the nodes in the cluster:
```
kubectl get nodes -o wide

NAME        STATUS   ROLES   AGE   VERSION   INTERNAL-IP   EXTERNAL-IP      OS-IMAGE                  KERNEL-VERSION                   CONTAINER-RUNTIME
10.0.10.2   Ready    node    47h   v1.14.8   10.0.10.2     130.61.xxx.yyy   Oracle Linux Server 7.7   4.14.35-1902.8.4.el7uek.x86_64   docker://18.9.8
10.0.10.3   Ready    node    47h   v1.14.8   10.0.10.3     130.61.xxx.zz    Oracle Linux Server 7.7   4.14.35-1902.8.4.el7uek.x86_64   docker://18.9.8
10.0.10.4   Ready    node    47h   v1.14.8   10.0.10.4     130.61.xx.bbb    Oracle Linux Server 7.7   4.14.35-1902.8.4.el7uek.x86_64   docker://18.9.8
```
       

## Running the oci-kubernetes-client in non-Interactive Mode

In these examples, the Kubernetes config file directory ".kube" and the OCI CLI config directory ".oci" (to contain certificates, OCI CLI config and the "tenancy.env" file) are located in the current directory.
The my-configmap.yml is located in the kubernetes-deployments directory in the current directory:

Then for Windows Command Shell run:
```
docker run --rm --mount type=bind,source="%cd%\.oci",target=/root/.oci --mount type=bind,source="%cd%\.kube",target=/root/.kube/ --mount type=bind,source="%cd%\kubernetes-yamls",target=/root/kubernetes-yamls --env-file "%cd%\tenancy.env" joranlager/oci-kubernetes-client kubectl create -f kubernetes-yamls/my-configmap.yml
```

Or for Bash run:
```
docker run --rm --mount type=bind,source="$(pwd)/.oci",target=/root/.oci --mount type=bind,source="$(pwd)/.kube",target=/root/.kube/ --mount type=bind,source="$(pwd)/kubernetes-deployments",target=/root/kubernetes-yamls --env-file "$(pwd)/tenancy.env" joranlager/oci-kubernetes-client kubectl create -f kubernetes-yamls/my-configmap.yml
```

Then for Windows Command Shell run:
```
docker run --rm --mount type=bind,source="%cd%\.oci",target=/root/.oci --mount type=bind,source="%cd%\.kube",target=/root/.kube/ --env-file "%cd%\tenancy.env" joranlager/oci-kubernetes-client kubectl get pods -n default -o wide
```

Or for Bash run:
```
docker run --rm --mount type=bind,source="$(pwd)/.oci",target=/root/.oci --mount type=bind,source="$(pwd)/.kube",target=/root/.kube/ --env-file "$(pwd)/tenancy.env" joranlager/oci-kubernetes-client kubectl get pods -n default -o wide
```

# Using Lens

The generated .kube/config file contains syntax to authenticate the configured User using the oci command to generate a token.
The oci command must be made available to the Lens Application and that can be done by creating a Wrapper Script and then putting that Script in the OS PATH.

This is a sample Kubernetes config file created by OKE (please note the command and args):

```
---
apiVersion: v1
kind: ""
clusters:
- name: cluster-xyz
  cluster:
    server: https://138.0.0.0:6443
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURpRENDQW5DZ0F3SUJBZ0lRQVoxUWlVSjZqZ0pxN09vazV3L3p4akFOQmdrcWhraUc5dzBCQVFzRkFEQmUKTVE4d0RRWURWUVF
    ... removed part ...
    RXNvZS9NPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
users:
- name: user-cbpxxxxqq
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: oci
      args:
      - ce
      - cluster
      - generate-token
      - --cluster-id
      - ocid1.cluster.oc1.eu-frankfurt-1.aaaaaaaajueqy...removed part...vx66lwjgh6cbpvm3in2qq
      - --region
      - eu-frankfurt-1
      env: []
contexts:
- name: context-xxx
  context:
    cluster: cluster-xyz
    user: user-cbpxxxxqq
current-context: context-xxx
```

## Creating the Wrapper Script

For Windows, please create the Wrapper Script called "oci.cmd" and put it in the OS PATH.
The content of the "oci.cmd" should be targeting the prepared structure of your Tenancy on the Host Machine
(here, the mytenancy Directory Structure is located at the root of the C: Drive)
```
@echo off
set OCIROOT=C:\mytenancy
docker run --rm --mount type=bind,source="%OCIROOT%\.oci",target=/root/.oci --env-file %OCIROOT%\tenancy.env -e OCI_CLI_SUPPRESS_FILE_PERMISSIONS_WARNING=True joranlager/oci-kubernetes-client oci %*
```

## Add a new Kubernetes Cluster in Lens Application
Add a new Cluster by pointing to the mytenancy\.kube\config file.

# Accessing the Kubernetes Dashboard

## From within the interactive shell:
### Get the service account token to use for the Dashboard
```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep oke-admin | awk '{print $1}')
```

### Start the kubernetes proxying
Then, start the proxy listening on all NICs inside the container exposing the proxy on port 8001:
```
kubectl proxy --address=0.0.0.0 &
```

## Access the Kubernetes Dashboard using a browser on the host machine running the Docker container

http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login
Use the token 

# Test the cluster by exposing nginx
This will create a deployment running an nginx pod and exposing the container within the pod on an external loadbalancer port 8080:
```
kubectl create deployment nginx --image=nginx
kubectl create service loadbalancer nginx --tcp=8080:80
```
Check for the external IP and test it in a browser:

```
kubectl get services -o wide

NAME         TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)          AGE     SELECTOR
kubernetes   ClusterIP      10.96.0.1     <none>          443/TCP          2d      <none>
nginx        LoadBalancer   10.96.143.5   132.145.246.5   8080:31741/TCP   5m41s   app=nginx
```

This URL is then accessible from the Internet:
http://132.145.246.5:8080/

Then remove the service and deployment:
```
kubectl delete service nginx
kubectl delete deployment nginx
```

# How to build this image

This image uses the joranlager/oci-cli:2.25.2 image as a base image.

It can be built using the standard`docker build` command, as follows: 

```
docker build -f Dockerfile -t joranlager/oci-kubernetes-client:latest .
```
