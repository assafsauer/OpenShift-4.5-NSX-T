

**#variables**

var_nsx_api_managers=192.168.1.70  <br>
var_nsx_api_password="SAuer1357N@1357N"   <br>
var_external_ip_pools=ocp-lb-pool  <br>
var_tier0_gateway=TF_Tier_0  <br>
var_top_tier_router=TF-ocp-t1 <br>
var_apiserver_host_ip=api.ocp.osauer.local  <br>
overlayzone_name=Overlay  <br>
var_edge_cluster_name=CLUSTER-EDGE-1  <br>
var_cluster=ocp  <br>

**#get UUID for overlay and EDGE via NSX-T API**

var_overlay_tz=$(curl --silent -k -u admin:$var_nsx_api_password -X GET https://$var_nsx_api_managers/api/v1/transport-zones | awk '/display_name/ && /'$overlayzone_name'/ { print x }; { x=$0 }' | awk '{ print $3 }' | tr ',' '\n')

echo $var_overlay_tz  <br>

var_edge_cluster=$(curl --silent -k -u admin:$var_nsx_api_password -X GET https://$var_nsx_api_managers/api/v1/edge-clusters | awk '/display_name/ && /'$var_edge_cluster_name'/ { print x }; { x=$0 }' | awk '{ print $3 }' | tr ',' '\n')

echo $var_edge_cluster


**#replace variables**

sed -i "s/var_top_tier_router/${var_top_tier_router}/g" configmap.yaml  <br>
sed -i "s/var_nsx_api_managers/${var_nsx_api_managers}/g" configmap.yaml  <br>
sed -i "s/var_nsx_api_password/${var_nsx_api_password}/g" configmap.yaml  <br>
sed -i "s/var_external_ip_pools/${var_external_ip_pools}/g" configmap.yaml  <br>
sed -i "s/var_overlay_tz/${var_overlay_tz}/g" configmap.yaml  <br>
sed -i "s/var_tier0_gateway/${var_tier0_gateway}/g" configmap.yaml  <br>
sed -i "s/var_apiserver_host_ip/${var_apiserver_host_ip}/g" configmap.yaml  <br>
sed -i "s/var_cluster/${var_cluster}/g" configmap.yaml  <br>
sed -i "s/var_edge_cluster/${var_edge_cluster}/g" configmap.yaml  <br>

**#confirm values**

root@sauer-virtual-machine:/home/sauer/ncp# cat configmap.yaml | grep "=" |grep -v "#"  <br>
    adaptor = openshift4  <br>
    cluster = ocp   <br>
    loglevel = DEBUG  <br>
    nsxlib_loglevel = DEBUG  <br>
    debug = True  <br>
    policy_nsxapi = True  <br>
    nsx_api_managers = 192.168.1.70   <br>
    nsx_api_user = admin  <br>
    nsx_api_password = SAuer1357V1357V!   <br>
    insecure = True  <br>
    subnet_prefix = 24  <br>
    log_firewall_traffic = DENY  <br>
    use_native_loadbalancer = True  <br>
    pool_algorithm = WEIGHTED_ROUND_ROBIN  <br>
    service_size = SMALL  <br>
    external_ip_pools = ocp-lb-pool   <br>
    tier0_gateway = TF_Tier_0   <br>
    single_tier_topology = True  <br>
    overlay_tz = "cfe2c4b2-23ef-4e23-a5e4-28d26740c74b"   <br>
    edge_cluster = "2d8bbae1-c1c9-433b-8943-1fc8bffa2ca6"   <br>
    apiserver_host_ip = api.ocp.osauer.local   <br>
    apiserver_host_port = 6443  <br>
    client_token_file = /var/run/secrets/kubernetes.io/serviceaccount/token  <br>
    ca_file = /var/run/secrets/kubernetes.io/serviceaccount/ca.crt  <br>
    loglevel = DEBUG  <br>
    baseline_policy_type = allow_cluster  <br>
    enable_multus = False  <br>
    process_oc_network = False  <br>
    ovs_bridge = br-int  <br>
    ovs_uplink_port = ens192  <br>
root@sauer-virtual-machine:/home/sauer/ncp#   <br>
