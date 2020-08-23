

# User-Provisioned Infrastructure (UPI): OpenShift 4.5 / NSX-T 3.0 (NCP)


![Test Image 1](https://github.com/assafsauer/Openshift/blob/master/Screenshot%202020-07-27%20at%2016.08.14.png) 


The idea behind this repository is to simplifiY OCP/UPI installation with NCP (NSX-T 3.0).
I added terraform automation for NSX-T and replaced the terraform infra automation with GOVC script. 
Some of the benefits of using NSX-T/NCP with OCP: 
* Performance optimization by avoiding double encapsulation and bypassing node TCP/IP stack
* Service type Load Balancer is realized automatically as NSX Virtual Server 
* Admin Firewall policy enforced per service, per cluster, or across all clusters 
* Distributed Firewall and Distributed Intrusion Detection System per Pod 
* Reliable egress source IP address per OCP Project and per Service 
* Mix of private and routed subnets per OpenShift Project 
* Single pane of glass for OpenShift, Kubernetes, VM , and BM workload 
* Network Quality of Service 
* Service Insertion to redirect traffic between Pods to third party security appliance 
* Visibility and Troubleshooting tools like NSX Traceflow, IPFIX, Port Mirroring, vRNI 


##  Installation Notes


* well know issues:
  * conflict with additional VC cluster or WCP.
* Bootstrap SSL CERT is  valid for 24 hours only
* use cleanup script to clean NCP objects (cluster destroy wont work)



 
## quick start

 **##### NSX-T configuration ** 


```diff

+deploy multi Tier routing for OCP4.5 with Terraform

 
git clone https://github.com/assafsauer/OpenShift-4.5-NSX-T.git


cd OpenShift-4.5-NSX-T/NSX-T_Automation   
#Edit variables.tf  
#Edit main.tf   

terraform init  
terraform apply   

#confirm Network connectivity (ping T1 interface 10.4.1.1)

#Create control LB
1) Set Membership Criteria based ip or VM name (Inverntory >> Groups >> Add Group)
2) add LB Active Monitors for port 6443 and port 22623
3) create 2 server pool for each port (make sure to define monitor from previous step)
4)  create the Load Balancer attached to your T1 (OCP)
5) create 2 virtual servers for each port with the ip of the API (10.4.1.5)

##### i will add LB automation shortly  ##### 
```

 **Prep**

 **##### DNS setup (dnsmasq)** 
```diff
+Example of DNS configuration with Dnsmasq below:

WILDCARD   
root@ubuntu:/home/viewadmin# cat /etc/dnsmasq.conf | grep 10.4.1.6  
address=/.apps.ocp.osauer.local/10.4.1.6   

A-RECORD   
root@ubuntu:/home/viewadmin# cat /etc/hosts | grep 10.4.1.5   
10.4.1.5 api.ocp.osauer.local   
10.4.1.5  api-int.ocp.osauer.local    
root@ubuntu:/home/viewadmin#    

SRV
root@ubuntu:/home/viewadmin# cat /etc/dnsmasq.conf |grep etcd
srv-host=_etcd-server-ssl._tcp.ocp.osauer.local,etcd-0.ocp.osauer.local,2380,0,10
srv-host=_etcd-server-ssl._tcp.ocp.osauer.local,etcd-1.ocp.osauer.local,2380,0,10
srv-host=_etcd-server-ssl._tcp.ocp.osauer.local,etcd-2.ocp.osauer.local,2380,0,10


root@sauer-virtual-machine:/home/sauer/Openshift.4.X-Automation# nslookup -type=SRV _etcd-server-ssl._tcp.ocp.osauer.local
Server:		192.168.1.80
Address:	192.168.1.80#53

_etcd-server-ssl._tcp.ocp.osauer.local	service = 0 10 2380 etcd-2.ocp.osauer.local.
_etcd-server-ssl._tcp.ocp.osauer.local	service = 0 10 2380 etcd-1.ocp.osauer.local.
_etcd-server-ssl._tcp.ocp.osauer.local	service = 0 10 2380 etcd-0.ocp.osauer.local.
```

**##### check list ** 
```diff
 ** CONFIRM **
#ping T0 and T1 interfaces from your jumpbox   
#confirm that the nodes get assigned DHCP UP in the overlay segment (ms_t1_int)  
#nslookup resolved api.ocp.osauer.local , api-int.ocp.osauer.local and *apps.ocp.osauer.local  
#verfiy that bootstrap interface is up on the virtual servers.

```

 **##### Packages ######**
```diff
+ download and extracat packages
curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-install-linux.tar.gz

curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz

curl -O https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-4.5.2-x86_64-vmware.x86_64.ova


EXTRACT:<br>
tar -xzvf openshift-install-linux.tar.gz  
tar -xzvf openshift-client-linux.tar.gz 
chmod +x oc  
cp oc /usr/local/bin/oc  
chmod +x kubectl  
cp kubectl /usr/local/bin/kubectl  
mv openshift-install /usr/local/bin/  
```

**##### NCP #####**
 ```diff 
 +edit the NCP vars and run the script  
 https://github.com/assafsauer/OpenShift-4.5-NSX-T/tree/master/NCP
 
**Installation prep**
  
  #Create installtion folder and copy and NCP yamls to the manifest folder:

mkdir ~/vsphere 
 ```
**##### create SSH-KEY #####**

 ```diff

ssh-keygen -t rsa -b 4096 -N '' \
    -f  ~/.ssh/id_rsa
cat /root/.ssh/id_rsa.pub  
 eval "$(ssh-agent -s)" 
 ssh-add  ~/.ssh/id_rsa  
 
  ```
 **##### Install Config #####**
  ```diff
+edit the install-config.yaml..   <br>
use the ssh key from previos step (cat /root/.ssh/id_rsa.pub) and download your secret from https://cloud.redhat.com/openshift/install/vsphere/user-provisioned  <br>
 
 https://github.com/assafsauer/OpenShift-4.5-NSX-T/blob/master/install-config.yaml  
 
 
#Create manifest fodler:
openshift-install create manifests --dir=/root/vsphere/

#copy the NCP yamls to the manifest folder 
cp NCP/*.yaml manifests/

sed -i "s/true/false/g" /root/vsphere/manifests/cluster-scheduler-02-config.yml
 ```
**##### Create Local web Service for the igintion files #####**
 ```diff
+configure nginx and upload the iginition files
https://github.com/assafsauer/OpenShift-4.5-NSX-T/blob/master/nginx.setup.sh

 ```
**##### automate Cluster nodes on Vsphere with govc #####**
 ```diff
 +automate infra (nodes/workers)
the govc will create Master/workers nodes and will insert the proper ingitions values to each VM.   
1) edit the vars section  <br>
2) the govc create MAC for each VM and you can define assign static IP based MAC from the OCP segment  

 ```
**RUN Bootstrap install**
 ```diff
openshift-install --dir=/root/vsphere/ wait-for bootstrap-complete --log-level=debug
```

**Cleanup**
 ```diff

 +cleanup cluster and NSX-T/NCP objects  
# clean NCP objects 
 python nsx_policy_cleanup.py --remove --mgr-ip=192.168.1.70 -u admin -p "SAuer1357N@1357N" --top-tier-router-id=ocp-t1 --cluster=ocp
 rm -r /root/vsphere 

# clean Cluster 
govc vm.power -off=true bootstrap.ocp.osauer.local
govc vm.power -off=true cp-0.ocp.osauer.local
govc vm.power -off=true cp-1.ocp.osauer.local
govc vm.power -off=true cp-2.ocp.osauer.local
govc vm.power -off=true node-0.ocp.osauer.local
govc vm.power -off=true node-1.ocp.osauer.local
govc vm.power -off=true node-2.ocp.osauer.local


govc vm.destroy --dc=PKS-DC bootstrap.ocp.osauer.local
govc vm.destroy --dc=PKS-DC cp-0.ocp.osauer.local
govc vm.destroy --dc=PKS-DC cp-1.ocp.osauer.local
govc vm.destroy --dc=PKS-DC.cp-2.ocp.osauer.local
govc vm.destroy --dc=PKS-DC.node-0.ocp.osauer.local
govc vm.destroy --dc=PKS-DC.node-1.ocp.osauer.local
govc vm.destroy --dc=PKS-DC node-2.ocp.osauer.local
```
 
**Troubleshooting**
 ```diff

oc logs -n nsx-system deploy/nsx-ncp > ncp.log
oc logs -n nsx-system-operator deploy/nsx-ncp-operator > operator.log

### From master (ssh core@master_ip): 
journalctl > journalctl.txt  
Journal  (grep -i error journalctl.log  | sort -u -t :  -k 10,10 )
curl -v -k https://192.168.1.70 ### check connectivitiy to NSX-T 
Nslookup api.ocp.osauer.local
 ```
