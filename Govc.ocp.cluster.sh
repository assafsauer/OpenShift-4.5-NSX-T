 



###### vars ########

 
export GOVC_URL='vcsa.osauer.local'
export GOVC_USERNAME='administrator@osauer.local'
export GOVC_PASSWORD='SAuer1357V!'
export GOVC_NETWORK='ocp'
export GOVC_DATASTORE='datastore5'
export GOVC_INSECURE=1
export GOVC_INSECURE=1


bootstrap=$(cat /root/vsphere/append-bootstrap.ign | base64 -w0)
master=$(cat /root/vsphere/master.ign | base64 -w0)
worker=$(cat /root/vsphere/worker.ign | base64 -w0)

base=base64

###### bootstrap ########




govc vm.clone -vm coreos -annotation=BootstrapNode -c=4 -m=16384 -net "ocp" -net.address 00:1c:14:4f:c1:10 -on=false -folder=/PKS-DC/vm/ocp  -pool=rpool bootstrap.ocp.osauer.local


govc vm.change -e="guestinfo.ignition.config.data=${bootstrap}" -vm=bootstrap.ocp.osauer.local

govc vm.change -e="disk.enableUUID=1" -vm=bootstrap.ocp.osauer.local

govc vm.change -e="guestinfo.ignition.config.data.encoding=${base}" -vm=bootstrap.ocp.osauer.local

govc vm.disk.change -vm bootstrap.ocp.osauer.local -disk.label "Hard disk 1"   -size 60G


###### control plan 1 ########


govc vm.clone -vm coreos -annotation=BootstrapNode -c=4 -m=16384 -net "ocp" -net.address 00:1c:14:4f:c1:20 -on=false -folder=/PKS-DC/vm/ocp  -pool=rpool control-plane-0.ocp.osauer.local

govc vm.change -e="guestinfo.ignition.config.data=${master}" -vm=control-plane-0.ocp.osauer.local

govc vm.change -e="disk.enableUUID=1" -vm=control-plane-0.ocp.osauer.local

govc vm.change -e="guestinfo.ignition.config.data.encoding=${base}" -vm=control-plane-0.ocp.osauer.local

govc vm.disk.change -vm control-plane-0.ocp.osauer.local -disk.label "Hard disk 1"   -size 50g

###### control plan 2 ########


govc vm.clone -vm coreos -annotation=BootstrapNode -c=4 -m=16384 -net "ocp" -net.address 00:1c:14:4f:c1:30 -on=false -folder=/PKS-DC/vm/ocp  -pool=rpool control-plane-1.ocp.osauer.local

govc vm.change -e="guestinfo.ignition.config.data=${master}" -vm=control-plane-1.ocp.osauer.local

govc vm.change -e="disk.enableUUID=1" -vm=control-plane-1.ocp.osauer.local

govc vm.change -e="guestinfo.ignition.config.data.encoding=${base}" -vm=control-plane-1.ocp.osauer.local

govc vm.disk.change -vm control-plane-1.ocp.osauer.local -disk.label "Hard disk 1"   -size 80g


###### control plan 3 ########


govc vm.clone -vm coreos -annotation=BootstrapNode -c=4 -m=16384 -net "ocp" -net.address 00:1c:14:4f:c1:40 -on=false -folder=/PKS-DC/vm/ocp  -pool=rpool control-plane-2.ocp.osauer.local

govc vm.change -e="guestinfo.ignition.config.data=${master}" -vm=control-plane-2.ocp.osauer.local

govc vm.change -e="disk.enableUUID=1" -vm=control-plane-2.ocp.osauer.local

govc vm.change -e="guestinfo.ignition.config.data.encoding=${base}" -vm=control-plane-2.ocp.osauer.local

govc vm.disk.change -vm control-plane-2.ocp.osauer.local -disk.label "Hard disk 1"   -size 50g

###### worker 1 ########


govc vm.clone -vm coreos -annotation=BootstrapNode -c=4 -m=16384 -net "ocp" -net.address 00:1c:14:4f:c1:50 -on=false -folder=/PKS-DC/vm/ocp  -pool=rpool node-0.ocp.osauer.local

govc vm.change -e="guestinfo.ignition.config.data=${worker}" -vm=node-0.ocp.osauer.local

govc vm.change -e="disk.enableUUID=1" -vm=node-0.ocp.osauer.local

govc vm.change -e="guestinfo.ignition.config.data.encoding=${base}" -vm=node-0.ocp.osauer.local

govc vm.disk.change -vm node-0.ocp.osauer.local -disk.label "Hard disk 1"   -size 50g

###### worker 2 ########


govc vm.clone -vm coreos -annotation=BootstrapNode -c=4 -m=16384 -net "ocp" -net.address 00:1c:14:4f:c1:60 -on=false -folder=/PKS-DC/vm/ocp  -pool=rpool node-1.ocp.osauer.local

govc vm.change -e="guestinfo.ignition.config.data=${worker}" -vm=node-1.ocp.osauer.local

govc vm.change -e="disk.enableUUID=1" -vm=node-1.ocp.osauer.local

govc vm.change -e="guestinfo.ignition.config.data.encoding=${base}" -vm=node-1.ocp.osauer.local

govc vm.disk.change -vm node-1.ocp.osauer.local -disk.label "Hard disk 1"   -size 50g




###### worker 3 ########


govc vm.clone -vm coreos -annotation=BootstrapNode -c=4 -m=16384 -net "ocp" -net.address 00:1c:14:4f:c1:70  -on=false -folder=/PKS-DC/vm/ocp  -pool=rpool node-2.ocp.osauer.local

govc vm.change -e="guestinfo.ignition.config.data=${worker}" -vm=node-2.ocp.osauer.local

govc vm.change -e="disk.enableUUID=1" -vm=node-2.ocp.osauer.local

govc vm.change -e="guestinfo.ignition.config.data.encoding=${base}" -vm=node-2.ocp.osauer.local

govc vm.disk.change -vm node-2.ocp.osauer.local -disk.label "Hard disk 1"   -size 50g




###### turn on ########
govc vm.power -on=true bootstrap.ocp.osauer.local
govc vm.power -on=true control-plane-0.ocp.osauer.local
govc vm.power -on=true control-plane-1.ocp.osauer.local
govc vm.power -on=true control-plane-2.ocp.osauer.local
govc vm.power -on=true node-0.ocp.osauer.local
govc vm.power -on=true node-1.ocp.osauer.local
govc vm.power -on=true node-2.ocp.osauer.local
govc vm.power -on=true node-3.ocp.osauer.local
