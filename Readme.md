

# OpenShift 4.5 integrated with NSX-T SDN (NCP)

 
## quick start

```diff

+deploy multi Tier routing for OCP4.5
 
git clone https://github.com/assafsauer/OpenShift-4.5-NSX-T.git


cd OpenShift-4.5-NSX-T/NSX-T_Automation   
#Edit variables.tf  
#Edit main.tf   

terraform init  
terraform apply   

#confirm Network connectivity (ping T1 interface 10.4.1.1)
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

 ** CONFIRM **
#ping T0 and T1 interfaces from your jumpbox   
#ip assigned from DHCP in the overlay segment (ms_t1_int)  
#nslookup resolved api.ocp.osauer.local , api-int.ocp.osauer.local and *apps.ocp.osauer.local  
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



