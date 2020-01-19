# oci-kubernetes-client

# How to build this image

```
docker build -f Dockerfile -t fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:1.0 .
docker tag fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:1.0 fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:latest
docker push fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:1.0
docker push fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:latest
```

# Running

## Interactive

### Pass existing kubeconfig
```
docker run -it --rm -p 8001:8001 --mount type=bind,source="%HOMEDRIVE%%HOMEPATH%\.kube\config",target=/root/.kube/config --mount type=bind,source="%cd%",target=/root/.oci fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:0.1
```

### Select the Kubernetes cluster dynamically
```
docker run -it --rm -p 8001:8001 --mount type=bind,source="%cd%",target=/root/.oci fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:0.1
```
Then, from within the shell, create the kubeconfig;
Get the compartment-id:
```
oci iam compartment list --all | grep -B 4 yourcompartment
```

Get the list of clusters for the given compartment-id:
```
oci ce cluster list --compartment-id=ocid1.compartment.oc1..aaaaaaaanyaw6hl5bbbb6fa4jgiuxxxxxxxxxxxxxxxxxxxs2v63u7mjiu4rb2ea

{
  "data": [
    {
      "available-kubernetes-upgrades": [
        "v1.13.5",
        "v1.14.8"
      ],
      "compartment-id": "ocid1.compartment.oc1..aaaaaaaanyaw6hl5bbbb6fa4jgiuxxxxxxxxxxxxxxxxxxxs2v63u7mjiu4rb2ea",
      "endpoints": {
        "kubernetes": "cqtczjrgbtd.eu-frankfurt-1.clusters.oci.oraclecloud.com:6443"
      },
      "id": "ocid1.cluster.oc1.eu-frankfurt-1.aaaaaaaaafsgkmjtmi3dmzdfgjrdgyjzgrtggmzumzsdgyrshcqtczjrgbtd",
      "kubernetes-version": "v1.12.7",
      "lifecycle-details": "",
      "lifecycle-state": "DELETED",
      "metadata": {
        "created-by-user-id": "ocid1.saml2idp.oc1..xxxxxxxxf/joran.lager@oracle.com",
        "created-by-work-request-id": "ocid1.clustersworkrequest.oc1.eu-frankfurt-1.aaaaaaaaafqwmzrvg4zggzrrgyytemjyge4tgmrqg5sgkmjxgwzgmmzrgi2d",
        "deleted-by-user-id": "ocid1.saml2idp.oc1..xxxxxxxxf/joran.lager@oracle.com",
        "deleted-by-work-request-id": "ocid1.clustersworkrequest.oc1.eu-frankfurt-1.aaaaaaaaaezdky3ega4den3emu2wcmzxg4ytgnleheztqnbvmwzdeobxmu2g",
        "time-created": "2019-06-02T20:05:46+00:00",
        "time-deleted": "2020-01-17T22:21:23+00:00",
        "time-updated": null,
        "updated-by-user-id": null,
        "updated-by-work-request-id": null
      },
      "name": "lager",
      "options": {
        "add-ons": {
          "is-kubernetes-dashboard-enabled": true,
          "is-tiller-enabled": true
        },
        "kubernetes-network-config": {
          "pods-cidr": "10.244.0.0/16",
          "services-cidr": "10.96.0.0/16"
        },
        "service-lb-subnet-ids": [
          "ocid1.subnet.oc1.eu-frankfurt-1.fdggfdfgdfgdfgdfgd",
          "ocid1.subnet.oc1.eu-frankfurt-1.uifuisfduiyyuiuiyui"
        ]
      },
      "vcn-id": "ocid1.vcn.oc1.eu-frankfurt-1.jlsfdslfdfkljsfdkljfsdkljfsdklj"
    },
    {
      "available-kubernetes-upgrades": [],
      "compartment-id": "ocid1.compartment.oc1..aaaaaaaanyaw6hl5bbbb6fa4jgiuxxxxxxxxxxxxxxxxxxxs2v63u7mjiu4rb2ea",
      "endpoints": {
        "kubernetes": "c4tazdgmeyg.eu-frankfurt-1.clusters.oci.oraclecloud.com:6443"
      },
      "id": "ocid1.cluster.oc1.eu-frankfurt-1.aaaaaaaaae3wmyjqffffffrxgjssfdsfdsfdqtimjzsfdfsdfsdiolchc4tazdgmeyg",
      "kubernetes-version": "v1.14.8",
      "lifecycle-details": "",
      "lifecycle-state": "ACTIVE",
      "metadata": {
        "created-by-user-id": "ocid1.saml2idp.oc1..xxxxxxxxf/joran.lager@oracle.com",
        "created-by-work-request-id": "ocid1.clustersworkrequest.oc1.eu-frankfurt-1.aaaaaaaaae4tamzuhazweyrxgu2domrqgu3dimzrgazgizddmwydcojsg5qt",
        "deleted-by-user-id": null,
        "deleted-by-work-request-id": null,
        "time-created": "2020-01-17T22:24:19+00:00",
        "time-deleted": null,
        "time-updated": null,
        "updated-by-user-id": null,
        "updated-by-work-request-id": null
      },
      "name": "Dive",
      "options": {
        "add-ons": {
          "is-kubernetes-dashboard-enabled": true,
          "is-tiller-enabled": false
        },
        "kubernetes-network-config": {
          "pods-cidr": "10.244.0.0/16",
          "services-cidr": "10.96.0.0/16"
        },
        "service-lb-subnet-ids": [
          "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaasrptlafqi7gdazwtxf2mf57okdjpuib75g7ge3ece3g2v2q2cu5q"
        ]
      },
      "vcn-id": "ocid1.vcn.oc1.eu-frankfurt-1.amaaaaaa3gkdkiaaf43ogjq747t2gq3dcz3mkdbgsq6dui6yascltelpjpiq"
    }
  ]
}
```

From the cluster list, find the cluster-id and create the kubeconfig to be able to access it:
```
oci ce cluster create-kubeconfig --cluster-id=ocid1.cluster.oc1.eu-frankfurt-1.aaaaaaaaae3wmyjqffffffrxgjssfdsfdsfdqtimjzsfdfsdfsdiolchc4tazdgmeyg
```

Then, check access by fetching the list of the nodes in the cluster:
```
kubectl get nodes -o wide

NAME        STATUS   ROLES   AGE   VERSION   INTERNAL-IP   EXTERNAL-IP      OS-IMAGE                  KERNEL-VERSION                   CONTAINER-RUNTIME
10.0.10.2   Ready    node    47h   v1.14.8   10.0.10.2     130.61.xxx.yyy   Oracle Linux Server 7.7   4.14.35-1902.8.4.el7uek.x86_64   docker://18.9.8
10.0.10.3   Ready    node    47h   v1.14.8   10.0.10.3     130.61.xxx.zz    Oracle Linux Server 7.7   4.14.35-1902.8.4.el7uek.x86_64   docker://18.9.8
10.0.10.4   Ready    node    47h   v1.14.8   10.0.10.4     130.61.xx.bbb    Oracle Linux Server 7.7   4.14.35-1902.8.4.el7uek.x86_64   docker://18.9.8
```


## Non-Interactive TODO
```
docker run --rm --mount type=bind,source="$(pwd)/config",target=/home/oracle/.kube/config --mount type=bind,source="$(pwd)/kubernetes-deployments",target=/home/oracle/kubernetes-deployments fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:latest kubectl create -f kubernetes-deployments/camel-domain-configmap.yml
docker run --rm --mount type=bind,source="%cd%\config",target=/home/oracle/.kube/config --mount type=bind,source="%cd%\kubernetes-deployments",target=/home/oracle/kubernetes-deployments fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:latest kubectl create -f kubernetes-deployments/camel-domain-configmap.yml
```

```
docker run --rm --mount type=bind,source="$(pwd)/config",target=/home/oracle/.kube/config fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:latest kubectl get pods -n backend-dev -o wide
docker run --rm --mount type=bind,source="%cd%\config",target=/home/oracle/.kube/config fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:latest kubectl get pods -n backend-dev -o wide
```

# Accessing the Kubernetes Dashboard

## From within the interactive shell:
### Get the service account token to use for the Dashboard
```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep oke-admin | awk '{print $1}')
```


### Start the kubernetes proxying
```
kubectl proxy --address=0.0.0.0 &
```

## Access the Kubernetes Dashboard using a browser on the host machine running the Docker container

http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login
Use the token 
