#!/bin/bash

cd ~ > /dev/null

numcompartments=0

until [ $numcompartments -gt 0 ]
do
  oci iam compartment list --all > compartments.json
  numcompartments=$(cat compartments.json | wc -l)
done

# If no arguments are given, get the names of all arguments and iterate on them:
if [ $# -eq 0 ]
then
  echo Found $numcompartments compartments in the file:
  jq -r '.data[] | .name + " (" + .description + ")"' compartments.json
  for i in $(jq -r ".data[] | .name" compartments.json)
  do
    if [ $i != "ManagedCompartmentForPaaS" ]; then
      echo Searching for Kubernetes cluster in compartment $i ...

      compartmentid=$(jq -r --arg COMPID "$i" '.data[] | select(.name ==$COMPID).id' compartments.json)
      kubernetescluster=$(oci ce cluster list --compartment-id=$compartmentid | jq '.data|.[]|.name + " (" + ."kubernetes-version" + ") OCID " + .id')
      echo $kubernetescluster

      echo Done searching for Kubernetes cluster in compartment $i
    else
      echo Skipped searching for Kubernetes cluster in compartment $i
    fi
  done
# otherwise, loop the arguments given (compartment names separated by space):
else
  for i in "$@"
  do
    if [ $i != "ManagedCompartmentForPaaS" ]; then
      echo Searching for Kubernetes cluster in compartment $i ...

      compartmentid=$(jq -r --arg COMPID "$i" '.data[] | select(.name ==$COMPID).id' compartments.json)
      kubernetescluster=$(oci ce cluster list --compartment-id=$compartmentid | jq '.data|.[]|.name + " (" + ."kubernetes-version" + ") OCID " + .id')
      echo $kubernetescluster

      echo Done searching for Kubernetes cluster in compartment $i
    else
      echo Skipped searching for Kubernetes cluster in compartment $i
    fi
  done
fi

cd - > /dev/null
