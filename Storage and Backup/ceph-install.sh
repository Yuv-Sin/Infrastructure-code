# --------------------- ceph ----------------------------

# Ceph storage clustering tutorial
# Installation of cluster and hosts using cephadm

# Install cephadm
# This will install the cephadm orchestrator for managing Ceph
sudo apt update && apt install cephadm -y

# Bootstrap the localhost (create a admin host)
cephadm bootstrap --mon-ip <mon-ip>
cephadm bootstrap --mon-ip 10.196.36.132

# Install the ceph cli for better managing the cluster

# 2 ways of installing ceph-cli 
# This will deploy the command line to a container in which the ceph commands are issued to control and manage the cluster
cephadm shell
# but you can also install the ceph-common tools to do this outside a container. 
cephadm install ceph-common

# Adding hosts to the cluster

# Install the cluster’s public SSH key in the new host’s root user’s authorized_keys file:
# before doing this remember to add your public_key into the root users auth_keys and chmod 700,600 permissions to .ssh and .ssh/auth_keys 
ssh-copy-id -f -i /etc/ceph/ceph.pub root@*<new-host>*
# Example 
ssh-copy-id -f -i /etc/ceph/ceph.pub root@10.196.36.191

# Tell Ceph that the new node is part of the cluster:
# Remember to install docker on the host instance
ceph orch host add *<newhost>* [*<ip>*] [*<label1> ...*]
# Example 
ceph orch host add ysi-ceph-host-1 10.196.36.191

# Add the _admin label to additional host(s), run a command of the following form:
ceph orch host label add *<host>* _admin
# Example 
sudo ceph orch host label add ysi-ceph-host-1 _admin