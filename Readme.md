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
