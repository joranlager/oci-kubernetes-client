# oci-kubernetes-client

# HOW TO BUILD THIS IMAGE

```
docker build -f Dockerfile -t fra.ocir.io/nose/consultingregistry/oci-oci-kubernetes-client:1.0 .
docker tag fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:1.0 fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:latest
docker push fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:1.0
docker push fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:latest
```

# Running

## Interactive
```

docker run -it --rm --mount type=bind,source="%HOMEDRIVE%%HOMEPATH%\.kube\config",target=/root/.kube/config --mount type=bind,source="%cd%",target=/root/kubernetes-deployments fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:1.0

docker run -it --rm --mount type=bind,source="$(pwd)/config",target=/home/oracle/.kube/config --mount type=bind,source="$(pwd)/kubernetes-deployments",target=/home/oracle/kubernetes-deployments fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:latest
docker run -it --rm --mount type=bind,source="%cd%\config",target=/home/oracle/.kube/config --mount type=bind,source="%cd%\kubernetes-deployments",target=/home/oracle/kubernetes-deployments fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:latest
```

## Non-Interactive
```
docker run --rm --mount type=bind,source="$(pwd)/config",target=/home/oracle/.kube/config --mount type=bind,source="$(pwd)/kubernetes-deployments",target=/home/oracle/kubernetes-deployments fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:latest kubectl create -f kubernetes-deployments/camel-domain-configmap.yml
docker run --rm --mount type=bind,source="%cd%\config",target=/home/oracle/.kube/config --mount type=bind,source="%cd%\kubernetes-deployments",target=/home/oracle/kubernetes-deployments fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:latest kubectl create -f kubernetes-deployments/camel-domain-configmap.yml
```

```
docker run --rm --mount type=bind,source="$(pwd)/config",target=/home/oracle/.kube/config fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:latest kubectl get pods -n backend-dev -o wide
docker run --rm --mount type=bind,source="%cd%\config",target=/home/oracle/.kube/config fra.ocir.io/nose/consultingregistry/oci-kubernetes-client:latest kubectl get pods -n backend-dev -o wide
```

## Setting the Kubernetes context

### Mounting the config

### Passing environment variables

### Run once
Create an alias "kubectl" wrapping the docker run ... /kubectl.sh.

## Run interactive
```
docker run -it --rm --mount type=bind,source="%HOMEDRIVE%%HOMEPATH%\.kube\config",target=/home/oracle/.kube/config --mount type=bind,source="%cd%",target=/home/oracle/kubernetes-deployments fra.ocir.io/nose/consultingregistry/kubernetes-client:latest
```
