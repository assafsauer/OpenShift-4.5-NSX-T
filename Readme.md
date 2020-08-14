# OpenShift 4.5 integrated with NSX-T SDN (NCP)

 
## quick start

## deploy multi Tier routing for OCP4.5
 
git clone https://github.com/assafsauer/OpenShift-4.5-NSX-T.git


cd OpenShift-4.5-NSX-T/NSX-T_Automation
#Edit variables.tf
#Edit main.tf 

terraform init
terraform apply

#confirm Network connectivity (ping T1 interface 10.4.1.1)

## Prep

DNS setup (dnsmasq)

WILDCARD 
root@ubuntu:/home/viewadmin# cat /etc/dnsmasq.conf | grep 10.4.1.6
address=/.apps.ocp.osauer.local/10.4.1.6

A-RECORD
root@ubuntu:/home/viewadmin# cat /etc/hosts | grep 10.4.1.5
10.4.1.5 api.ocp.osauer.local
10.4.1.5  api-int.ocp.osauer.local 
root@ubuntu:/home/viewadmin# 

#ping T0 and T1 interfaces from your jumpbox
#ip assigned from DHCP in the overlay segment (ms_t1_int)
#nslookup resolved api.ocp.osauer.local , api-int.ocp.osauer.local and *apps.ocp.osauer.local
