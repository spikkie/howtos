#!/usr/bin/env bash
set -x
set -e

echo setup a kubernete cluster

# Creating a Kubernetes Cluster
# Introduction

#Install Docker and Kubernetes on All Servers

# Most of these commands need to be run on each of the nodes. 
# Pay attention though. Down at Step 10, we are going to do a little bit on just the master, and down at Step 15 we'll run something on just the nodes. There are notes down there, just be watching for them.

    # Once we have logged in, we need to elevate privileges using sudo:

sudo su  

    # Disable SELinux:

setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

    # Enable the br_netfilter module for cluster communication:

modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

    # Ensure that the Docker dependencies are satisfied:

yum install -y yum-utils device-mapper-persistent-data lvm2

    # Add the Docker repo and install Docker:

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce

#------------
#or other method
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu

sudo apt-mark hold docker-ce



    # Set the cgroup driver for Docker to systemd, reload systemd, then enable and start Docker:

sed -i '/^ExecStart/ s/$/ --exec-opt native.cgroupdriver=systemd/' /usr/lib/systemd/system/docker.service
systemctl daemon-reload
systemctl enable docker --now

    # Add the Kubernetes repo:

cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

    # Install Kubernetes:

yum install -y kubelet kubeadm kubectl

    # Enable the kubelet service. The kubelet service will fail to start until the cluster is initialized, this is expected:

systemctl enable kubelet

# Note: Complete the following section on the MASTER ONLY!

    # Initialize the cluster using the IP range for Flannel:

kubeadm init --pod-network-cidr=10.244.0.0/16

    # Copy the kubeadmn join command that is in the output. We will need this later.
    # Exit sudo, copy the admin.conf to your home directory, and take ownership.

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

    # Deploy Flannel:

    # On all three nodes, run the following:

echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

    # Check the cluster state:

kubectl get pods --all-namespaces
kubectl get pods -n kube-system # check for flannel

    # Note: Complete the following steps on the NODES ONLY!

    # Run the join command that you copied earlier, this requires running the command prefaced with sudo on the nodes (if we hadn't run sudo su to begin with). Then we'll check the nodes from the master.

 # kubectl get nodes

# Create and Scale a Deployment Using kubectl
# Note: These commands will only be run on the master node.

    # Create a simple deployment:

kubectl create deployment nginx --image=nginx

    # Inspect the pod:

kubectl get pods

    # Scale the deployment:

kubectl scale deployment nginx --replicas=4

    # Inspect the pods. We should have four now:

 kubectl get pods


