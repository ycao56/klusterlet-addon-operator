#!/bin/bash
###############################################################################
# Copyright (c) 2020 Red Hat, Inc.
###############################################################################
# set -x
# set -e
DOCKER_IMAGE=$1
KIND_CONFIGS=build/kind-config


set_linux_arch () {
    local _arch=$(uname -m)
    if [ "$_arch" == "x86_64" ]; then
        _linux_arch="amd64"
    elif [ "$_arch" == "ppc64le" ]; then
        _linux_arch="ppc64le"
    else
        echo "Unrecognized architecture $_arch"
        return 1
    fi
}

install_kubectl () {
    if $(type kubectl >/dev/null 2>&1); then
        echo "kubectl already installed"
        return 0
    fi
    # alway install when running from Travis
    if [ "$(uname)" != "Darwin" ]; then
        set_linux_arch
        sudo curl -s -L https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/$_linux_arch/kubectl -o /usr/local/bin/kubectl
        sudo chmod +x /usr/local/bin/kubectl
        kubectl version --client=true
        if [ $? != 0 ]; then
          echo "kubectl installation failed"
          return 1
        fi
    fi
}

install_kind () {
    if $(type kind >/dev/null 2>&1); then
        echo "kind installed"
        return 0
    fi
    curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-$(uname)-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    kind version
    if [ $? != 0 ]; then
        echo "kind installation failed"
        return 1
    fi
}


# Wait until the cluster is imported by checking the hub side
# Parameter: KinD Config File
wait_installed() {
    CONFIG_FILE=$1

    _timeout_seconds=120
    _interval_seconds=10
    _max_nb_loop=$(($_timeout_seconds/$_interval_seconds))
    while [ $_max_nb_loop -gt 0 ]
    do
        if [ $ocp_env ]; then
        _result=$(for file in `ls deploy/crs/multicloud.ibm.com_*_cr.yaml deploy/crs/ocp/multicloud.ibm.com_*_cr.yaml`; do kubectl get -f $file -o=jsonpath="{.metadata.name}{' '}{.status.conditions[?(@.reason=='InstallSuccessful')].reason}{'\n'}"; done)
        else
        _result=$(for file in `ls deploy/crs/multicloud.ibm.com_*_cr.yaml deploy/crs/non-ocp/multicloud.ibm.com_*_cr.yaml`; do kubectl get -f $file -o=jsonpath="{.metadata.name}{' '}{.status.conditions[?(@.reason=='InstallSuccessful')].reason}{'\n'}"; done)
        fi
        _result_exit_code=$?
        _result_not_success=$(echo "$_result" | grep -v "InstallSuccessful")
        if [ $? == 0 ] || [ $_result_exit_code != 0 ] ; then
            echo "=========== Waiting for success ==========="
            echo "$_result"
            sleep $_interval_seconds
            _max_nb_loop=$(($_max_nb_loop-1))
        else
            echo "=========== Success ==========="
            echo "$_result"
            return 0
        fi
    done
    echo "====================== ERROR with config $CONFIG_FILE ==================="
    echo "Timeout: Herlm charts deployment failed after "$_timeout_seconds" seconds"
    for cr in $_result_not_success; do kubectl get $cr $cr -n multicluster-endpoint -o=jsonpath="{.metadata.name}{','}{.status.conditions[*].message}{'\n'}"; done
    return 1
}

#Create a cluster with as parameter the KinD config file and run the test
run_test() {
  CONFIG_FILE=$1
  echo "====================== START with config $CONFIG_FILE ==================="
  #Delete cluster
	kind delete cluster --name=test-cluster

  # Create cluster 
  kind create cluster --name=test-cluster --config $CONFIG_FILE

  #export context to kubeconfig
  # export KUBECONFIG=$(mktemp /tmp/kubeconfigXXXX)
  kind export kubeconfig --name=test-cluster

  #Load image into cluster
  kind load docker-image $DOCKER_IMAGE --name=test-cluster

  #Apply all crds
  for file in `ls deploy/crds/multicloud.ibm.com_*_crd.yaml`; do kubectl apply -f $file; done

  #Try to apply the securitycontextconstraints
  ocp_env=0
  kubectl apply -f deploy/crds/security.openshift.io_securitycontextconstraints_crd.yaml
  if [ $? == 0 ]; then
    ocp_env=1
    echo "This is an OCP-like environment"
  else
    echo "This is not an OCP-like environment"
  fi

  #Create the namespace
  kubectl create ns multicluster-endpoint

  #Install all CRs
  for file in `ls deploy/crs/multicloud.ibm.com_*_cr.yaml`; do kubectl apply -f $file; done

  #Install CRs depending if it is an OCP env or not
  if [ $ocp_env == 1 ]; then
    for file in `ls deploy/crs/ocp/multicloud.ibm.com_*_cr.yaml`; do kubectl apply -f $file; done
  else
    for file in `ls deploy/crs/non-ocp/multicloud.ibm.com_*_cr.yaml`; do kubectl apply -f $file; done
  fi

  #Configure kubectl
  tmpKUBECONFIG=$(mktemp /tmp/kubeconfigXXXX)
  kind export kubeconfig --kubeconfig $tmpKUBECONFIG --name=test-cluster

  #Create a generic klusterlet-bootstrap
  kubectl create secret generic klusterlet-bootstrap -n multicluster-endpoint --from-file=kubeconfig=$tmpKUBECONFIG

  #Create the docker secret for quay.io
  kubectl create secret docker-registry multicloud-image-pull-secret \
      --docker-server=quay.io/open-cluster-management \
      --docker-username=open-cluster-management+multiclusterhubdeploy \
      --docker-password=CWI8K93KBWJNSTIQPBZFN2HDAYQNQOGN4R06QRCFFDQGHZ2IREM9NF5B83DU9C1U \
      -n multicluster-endpoint

  #Deploy the operator
  kubectl apply -f deploy/service_account.yaml
  kubectl apply -f deploy/role.yaml
  kubectl apply -f deploy/role_binding.yaml

  tmpOperator=$(mktemp /tmp/operatorXXXX)
  sed s,REPLACE_IMAGE,$DOCKER_IMAGE, deploy/operator.yaml > $tmpOperator
  kubectl apply -f $tmpOperator

  #Wait if all helm-charts are installed
  wait_installed $CONFIG_FILE
  _timeout=$?
  #Delete cluster
	kind delete cluster --name=test-cluster
  echo "====================== END of config $CONFIG_FILE ======================"
  if [ $_timeout != 0 ]; then
    return 1
  fi
}


install_kubectl
if [ $? != 0 ]; then
  exit 1
fi

install_kind
if [ $? != 0 ]; then
  exit 1
fi

FAILED=0
for kube_config in `ls $KIND_CONFIGS/*`; do
  run_test $kube_config
  if [ $? != 0 ]; then
    FAILED=1
  fi
done

if [ $FAILED == 1 ]; then
  echo "At least, one of the KinD configuration failed"
fi

exit $FAILED