# oci-kubernetes-client - containerized Kubernetes Client for OCI

# Running the oci-kubernetes-client

The current directory will be used to store your OCI CLI certificate and key, so mount it when running the oci-kubernetes-client.

### Creating the tenancy.env file
Also make sure pass the tenancy.env file to the container setting the properties within that file as ENV variables in the container.
Make sure to set proper values for the entries in that file.
The values can be found using the Oracle Cloud Infrastructure web UI.

```
OCI_TENANCY_NAME=nose
OCI_TENANCY_OCID=ocid1.tenancy.oc1..aaaaaaaaflfxxx
OCI_USER_OCID=ocid1.user.oc1..aaaaaaaanufslfkvkyyy
OCI_REGION=eu-frankfurt-1
```

### Creating and setting the required certificate and key to access OCI
For inital setup of the OCI CLI credentials / certificate of if you need to re-configure, run the setup-oci command in the container shell.
This will overwrite existing certificate and private key so make sure that is the intention.
```
setup-oci
```
Running the script requires the user to hit enter when the script pauses - then the public key in PEM format is displayed.
That content must be added as public authentication key for the given user:
1. Log in to the Oracle Cloud using a browser (https://console.eu-frankfurt-1.oraclecloud.com)
2. Navigate to Profile -> <user>, then select Resources -> API Keys and Add Public Key.
3. Paste the public key in PEM format and push Add button.

## Exposing ports from an oci-kubernetes-client container
These examples show the exposure of the container port 8001 on the host port 8001.
This is only required if we want to run kubectl proxy and access (amongst other), the Kubernetes Dashboard application from the Docker host.

## Interactive

The Kubernetes Client has autocomplete enabled, so hitting TAB will give completion alternatives.

### Pass existing kubeconfig
In this example, the Kubernetes config file "config" and the "tenancy.env" file are located in the current directory:
```
docker run -it --rm -p 8001:8001 --mount type=bind,source="%cd%\kubeconfig",target=/root/.kube/config --mount type=bind,source="%cd%",target=/root/.oci --env-file tenancy.env joranlager/oci-kubernetes-client
docker run -it --rm -p 8001:8001 --mount type=bind,source="$(pwd)/kubeconfig",target=/root/.kube/config --mount type=bind,source="$(pwd)",target=/root/.oci --env-file tenancy.env joranlager/oci-kubernetes-client
```

### Select the Kubernetes cluster dynamically
In this example, the "tenancy.env" file is located in the current directory:
```
docker run -it --rm -p 8001:8001 --mount type=bind,source="%cd%",target=/root/.oci --env-file tenancy.env joranlager/oci-kubernetes-client
docker run -it --rm -p 8001:8001 --mount type=bind,source="$(pwd)",target=/root/.oci --env-file tenancy.env joranlager/oci-kubernetes-client
```
Then, from within the shell, create the kubeconfig;
Get the compartment-id:
```
oci iam compartment list --all | jq '.data[] | .name + " (" + .description + ") OCID: " + .id'
```

Get the list of clusters for the given compartment-id:
```
get-clusters <compartment name 1> <compartment name n>
```

Example running:
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


## Running the oci-kubernetes-client non-Interactive

In these examples, the Kubernetes config file "config" and the "tenancy.env" file are located in the current directory.
The my-configmap.yml is located in the kubernetes-deployments directory in the current directory:

```
docker run --rm --mount type=bind,source="%cd%\config",target=/home/oracle/.kube/kubeconfig --mount type=bind,source="%cd%\kubernetes-deployments",target=/home/oracle/kubernetes-deployments --env-file tenancy.env joranlager/oci-kubernetes-client kubectl create -f kubernetes-deployments/my-configmap.yml
docker run --rm --mount type=bind,source="$(pwd)/kubeconfig",target=/home/oracle/.kube/config --mount type=bind,source="$(pwd)/kubernetes-deployments",target=/home/oracle/kubernetes-deployments --env-file tenancy.env joranlager/oci-kubernetes-client kubectl create -f kubernetes-deployments/my-configmap.yml
```

```
docker run --rm --mount type=bind,source="%cd%\kubeconfig",target=/home/oracle/.kube/config --env-file tenancy.env joranlager/oci-kubernetes-client kubectl get pods -n default -o wide
docker run --rm --mount type=bind,source="$(pwd)/kubeconfig",target=/home/oracle/.kube/config --env-file tenancy.env joranlager/oci-kubernetes-client kubectl get pods -n default -o wide
```

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

This image uses the joranlager/oci-cli:0.1 image as a base image.
Please build https://github.com/joranlager/oci-cli before building this image.

It can be built using the standard`docker build` command, as follows: 

```
docker build -f Dockerfile -t joranlager/oci-kubernetes-client:latest .
```
