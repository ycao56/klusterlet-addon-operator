# Copyright (c) 2020 Red Hat, Inc.
# Copyright Contributors to the Open Cluster Management project

#!/bin/bash
###############################################################################
###############################################################################
# set -x #To trace

export DOCKER_IMAGE=$1

KIND_CONFIGS=build/kind-config
KIND_KUBECONFIG="${PROJECT_DIR}/kind_kubeconfig.yaml"
export KUBECONFIG=${KIND_KUBECONFIG}

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
echo "kind version"
kind version
# Wait until the cluster is imported by checking the hub side
# Parameter: KinD Config File
wait_installed() {
    CONFIG_FILE=$1

    _timeout_seconds=120
    _interval_seconds=10
    _max_nb_loop=$(($_timeout_seconds/$_interval_seconds))
    deploy_array=("applicationmanager" "certpolicyctrl" "iampolicycontroller" "policycontroller" "searchcollector" "workmanager")

    while [ $_max_nb_loop -gt 0 ]
    do
        _result=$(for t in ${deploy_array[@]}; do helm ls -n klusterlet | grep $t | awk '{print $1 " "  $8}'; done)
        #_result=$(for file in `ls deploy/crs/agent.open-cluster-management.io_*_cr.yaml`; do kubectl get -f $file -o=jsonpath="{.metadata.name}{' '}{.status.conditions[?(@.reason=='InstallSuccessful')].reason}{'\n'}"; done)
        _result_exit_code=$?
        _result_not_success=$(echo "$_result" | grep -v "deployed")
       
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
    echo "Timeout: Helm charts deployment failed after "$_timeout_seconds" seconds"
    for t in $_result_not_success; do helm ls -n klusterlet | grep $t | awk '{print $1 " "  $8}'; done
    return 1
}

check_ocp_install(){
    echo "checking route installation: kubectl get route -n klusterlet"
    kubectl get route -l component=work-manager -n klusterlet
    _not_installed_route=1
    if [ $(kubectl get route -l component=work-manager -n klusterlet | wc -l)  -gt 1 ]; then
      echo "route installed correctly"
      _not_installed_route=0
    fi
    _is_installed_loadbalancer=1
    kubectl get svc -l component=work-manager -n klusterlet -owide
    kubectl get svc -l component=work-manager -n klusterlet -ocustom-columns='type:.spec.type' | grep -i LoadBalancer || _is_installed_loadbalancer=0

    if [ $_not_installed_route != 0 ]; then
      echo 'route not installed'
      return 1
    fi
    if [ $_is_installed_loadbalancer != 0 ]; then
      echo 'should not use loadbalancer for ocp install'
      return 1
    fi
    return 0
}

#Create a cluster with as parameter the KinD config file and run the test
run_test() {
  CONFIG_FILE=$1
  SELF_IMPORT=$2
  echo "====================== START with config $CONFIG_FILE ==================="
  #Delete cluster
	kind delete cluster --name=test-cluster

  # Create cluster
  kind create cluster --name=test-cluster --config $CONFIG_FILE

  #export context to kubeconfig
  # export KUBECONFIG=$(mktemp /tmp/kubeconfigXXXX)
  kind export kubeconfig --name=test-cluster --kubeconfig ${KIND_KUBECONFIG}

  #Load image into cluster
  kind load docker-image $DOCKER_IMAGE --name=test-cluster

  if [[ $CONFIG_FILE == "build/kind-config/kubernetes-v1.11.10.yaml" || $CONFIG_FILE == "build/kind-config/kubernetes-v1.13.12.yaml" ]]; then
    #Apply all crds
    for file in `ls deploy/crds/agent.open-cluster-management.io_*_crd.yaml`; do kubectl apply -f $file; done

    if [[ "$SELF_IMPORT" == true ]]; then 
      kubectl apply -f deploy/crds/operator.open-cluster-management.io_multiclusterhub.crd.yaml 
    fi
  else
    #Apply all crds
    for file in `ls deploy/crds-v1/agent.open-cluster-management.io_*_crd.yaml`; do kubectl apply -f $file; done

    if [[ "$SELF_IMPORT" == true ]]; then 
      kubectl apply -f deploy/crds-v1/operator.open-cluster-management.io_multiclusterhub.crd.yaml 
    fi
  fi

  #Try to apply the securitycontextconstraints
  ocp_env=0
  kubectl apply -f deploy/crds/security.openshift.io_securitycontextconstraints_crd.yaml
  if [ $? == 0 ]; then
    ocp_env=1
    echo "This is an OCP-like environment"
    kubectl apply -f deploy/crds/fake_route.openshift.io_route_crd.yaml
  else
    echo "This is not an OCP-like environment"
  fi

  #Create the namespace
  kubectl apply -f ${PROJECT_DIR}/deploy/namespace.yaml

  #Install all CRs
  for file in `ls deploy/crs/agent.open-cluster-management.io_*_cr.yaml`; do kubectl apply -f $file; done

  #Configure kubectl
  tmpKUBECONFIG=$(mktemp /tmp/kubeconfigXXXX)
  kind export kubeconfig --kubeconfig $tmpKUBECONFIG --name=test-cluster

  #Create a generic klusterlet-bootstrap
  kubectl create secret generic klusterlet-bootstrap -n klusterlet --from-file=kubeconfig=$tmpKUBECONFIG
  
  for dir in overlays/test/* ; do
    echo "Executing test "$dir
    kubectl apply -k $dir
    kubectl patch deployment klusterlet-addon-operator -n klusterlet -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"klusterlet-addon-operator\",\"image\":\"${DOCKER_IMAGE}\"}]}}}}"
    #Wait if all helm-charts are installed
    wait_installed $CONFIG_FILE 
    _timeout=$?
    if [ $_timeout != 0 ]; then
      break
    fi
    _installed_failed=0
    #Check detailed installed resources
    if [ $ocp_env != 0 ]; then
      check_ocp_install
      _installed_failed=$?
      if [ $_installed_failed != 0 ]; then
        break
      fi
    fi
  done

  #Delete cluster
	kind delete cluster --name=test-cluster
  echo "====================== END of config $CONFIG_FILE ======================"
  if [ $_timeout != 0 ]; then
    return 1
  fi
  if [ $_installed_failed != 0 ]; then
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
SELF_IMPORT=false
for kube_config in `ls $KIND_CONFIGS/*`; do
  if [[ "$kube_config" == *_self-import.yaml ]]; then 
    SELF_IMPORT=true
  fi
  run_test $kube_config $SELF_IMPORT
  if [ $? != 0 ]; then
    echo "$kube_config KinD configuration failed"
    FAILED=1
  fi
done

if [ $FAILED == 1 ]; then
  echo "At least, one of the KinD configuration failed"
fi

exit $FAILED
