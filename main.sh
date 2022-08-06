#!/bin/bash

set -e

function awkenvsubst() {
  awk '!/# *nosubst/{while(match($0,"[$]{[^}]*}")) {var=substr($0,RSTART+2,RLENGTH -3);val=ENVIRON[var];gsub(/["\\]/,"\\\\&", val);gsub("\n", "\\n", val);gsub("\r", "\\r", val);gsub("[$]{"var"}",val)}}1'
}

# Download and install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Write kube config
mkdir $HOME/.kube && echo "${KUBE_CONFIG}" > ~/.kube/config

if [[ ! -z ${DOCKERFILE_PATH} ]]; then
  # Build docker image
  export DOCKER_IMAGE=ghcr.io/${GITHUB_USERNAME}/${DOCKER_IMAGE}
  docker build ${DOCKERFILE_PATH} -t ${DOCKER_IMAGE}

  #Publish image to GitHub Container Registry
  echo ${GITHUB_TOKEN} | docker login ghcr.io --username ${GITHUB_USERNAME} --password-stdin
  docker push ${DOCKER_IMAGE}
fi

if [[ ! -z ${DEPLOYMENT} ]]; then
  awkenvsubst < ${DEPLOYMENT} > generated-deployment.yml
  kubectl apply -f generated-deployment.yml
fi