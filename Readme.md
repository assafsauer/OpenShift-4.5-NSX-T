# OpenShift 4.5 integrated with NSX-T SDN (NCP)

 
## quick start

## deploy multi Tier routing for OCP4.5
 
git clone https://github.com/assafsauer/OpenShift-4.5-NSX-T.git


cd OpenShift-4.5-NSX-T/NSX-T_Automation  <br>
#Edit variables.tf  <br>
#Edit main.tf   <br>

terraform init  <br>
terraform apply  <br>

#confirm Network connectivity (ping T1 interface 10.4.1.1)

## Prep

#####DNS setup (dnsmasq)#######

WILDCARD   <br>
root@ubuntu:/home/viewadmin# cat /etc/dnsmasq.conf | grep 10.4.1.6  <br>
address=/.apps.ocp.osauer.local/10.4.1.6  <br>

A-RECORD  <br>
root@ubuntu:/home/viewadmin# cat /etc/hosts | grep 10.4.1.5  <br>
10.4.1.5 api.ocp.osauer.local  <br>
10.4.1.5  api-int.ocp.osauer.local   <br>
root@ubuntu:/home/viewadmin#   <br>

##### CONFIRM ######
#ping T0 and T1 interfaces from your jumpbox  <br>
#ip assigned from DHCP in the overlay segment (ms_t1_int)  <br>
#nslookup resolved api.ocp.osauer.local , api-int.ocp.osauer.local and *apps.ocp.osauer.local  <br>


##### Packages ######

curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-install-linux.tar.gz

curl -O https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz

curl -O https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-4.5.2-x86_64-vmware.x86_64.ova


EXTRACT:<br>
tar -xzvf openshift-install-linux.tar.gz <br>
tar -xzvf openshift-client-linux.tar.gz <br>
chmod +x oc  <br>
cp oc /usr/local/bin/oc <br>
chmod +x kubectl <br>
cp kubectl /usr/local/bin/kubectl <br>
mv openshift-install /usr/local/bin/ <br>

 
**NCP**
 
 edit the NCP vars and run the script  <br>
 https://github.com/assafsauer/OpenShift-4.5-NSX-T/tree/master/NCP
 
**Installation prep**
  
  #Create installtion folder and copy and NCP yamls to the manifest folder:

mkdir ~/vsphere <br>

**create SSH-KEY**
 

ssh-keygen -t rsa -b 4096 -N '' \
    -f  ~/.ssh/id_rsa
cat /root/.ssh/id_rsa.pub  <br>
 eval "$(ssh-agent -s)" <br>
 ssh-add  ~/.ssh/id_rsa <br>
 
 **Install Config**
 
 edit the install-config.yaml..   <br>
use the ssh key from previos step (cat /root/.ssh/id_rsa.pub) and download your secret from https://cloud.redhat.com/openshift/install/vsphere/user-provisioned  <br>
 https://github.com/assafsauer/OpenShift-4.5-NSX-T/blob/master/install-config.yaml  <br>
 
 
 Create manifest fodler:
openshift-install create manifests --dir=/root/vsphere/

copy the NCP yamls to the manifest folder 
cp NCP/*.yaml manifests/

sed -i "s/true/false/g" /root/vsphere/manifests/cluster-scheduler-02-config.yml

**Create Local web Service for the igintion files**

https://github.com/assafsauer/OpenShift-4.5-NSX-T/blob/master/nginx.setup.sh



