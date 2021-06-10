# Setup a Proxy againts the Kubernetes API Service in OKE

## Modify the Host's DNS setup
Find the IP for WSL by using ipconfig/ifconfig
```
Ethernet adapter vEthernet (WSL):

   Connection-specific DNS Suffix  . :
   Link-local IPv6 Address . . . . . : fe80::c4b6:1729:5a89:9350%64
   IPv4 Address. . . . . . . . . . . : 172.22.32.1
   Subnet Mask . . . . . . . . . . . : 255.255.240.0
   Default Gateway . . . . . . . . . :
```

Add the IPv4 Address to your client's hosts file (as Administrator).
On Windows it is in C:\Windows\System32\drivers\etc\hosts

```
172.22.32.1 kubernetes
```

## Start the Docker Container to be used as a Proxy
Then run the oci-kubernetes-client binding to all your machine's IPs:
```
docker run -it --rm -p 0.0.0.0:6443:6443 --mount type=bind,source="%cd%",target=/root/.oci --mount type=bind,source="%cd%\kubeconfig",target=/root/.kube/ --env-file tenancy.env joranlager/oci-kubernetes-client /bin/bash
```

Inside the container, make sure that the required Deployment, Service, Service Account and bindings are created:
```
kubectl apply -f kubernetes-api-proxy-service.yml
```

Get the secret token to use for the newly created kubernetes-api-proxy-sa Service Account - it must be put in the kubeconfig file:
```
kubectl describe secret $(kubectl get secrets | grep kubernetes-api-proxy-sa | awk '{print $1}') | grep token: | awk '{print $2}'
```

Then, inside the container start the port forwarding:
```
kubectl port-forward --address 0.0.0.0 service/kubernetes-api-proxy-service 6443:443
```

## Configure Lens
Paste this into a new cluster paste as text in Lens:
```
apiVersion: v1
clusters:
- name: cluster-xyz
  cluster:
    server: https://kubernetes:6443
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJ...removed_part...ZJQ0FURS0tLS0tCg==
contexts:
- context:
    cluster: cluster-xyz
    user: kubernetes-api-proxy-sa
  name: k8s-oke-context
current-context: k8s-oke-context
kind: Config
preferences: {}
users:
- name: kubernetes-api-proxy-sa
  user:
    token: eyJhbGciOiJSUzI1Ni...removed_part...StuI4lg72W8GHQ
```
