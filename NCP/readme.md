
var_nsx_api_managers=192.168.1.70
var_nsx_api_password="SAuer1357V1357V!"
var_external_ip_pools=ocp-lb-pool
var_tier0_gateway=TF_Tier_0
var_apiserver_host_ip=api.ocp.osauer.local
overlayzone_name=Overlay
var_edge_cluster_name=CLUSTER-EDGE-1
var_cluster=ocp

var_overlay_tz=$(curl --silent -k -u admin:$var_nsx_api_password -X GET https://$var_nsx_api_managers/api/v1/transport-zones | awk '/display_name/ && /'$overlayzone_name'/ { print x }; { x=$0 }' | awk '{ print $3 }' | tr ',' '\n')

echo $var_overlay_tz

var_edge_cluster=$(curl --silent -k -u admin:$var_nsx_api_password -X GET https://$var_nsx_api_managers/api/v1/edge-clusters | awk '/display_name/ && /'$var_edge_cluster_name'/ { print x }; { x=$0 }' | awk '{ print $3 }' | tr ',' '\n')

echo $var_edge_cluster

sed -i "s/var_nsx_api_managers/${var_nsx_api_managers}/g" configmap.yaml
sed -i "s/var_nsx_api_password/${var_nsx_api_password}/g" configmap.yaml
sed -i "s/var_external_ip_pools/${var_external_ip_pools}/g" configmap.yaml
sed -i "s/var_overlay_tz/${var_overlay_tz}/g" configmap.yaml
sed -i "s/var_tier0_gateway/${var_tier0_gateway}/g" configmap.yaml
sed -i "s/var_apiserver_host_ip/${var_apiserver_host_ip}/g" configmap.yaml
sed -i "s/var_cluster/${var_cluster}/g" configmap.yaml
sed -i "s/var_edge_cluster/${var_edge_cluster}/g" configmap.yaml


root@sauer-virtual-machine:/home/sauer/ncp# cat configmap.yaml | grep "=" |grep -v "#"
    adaptor = openshift4
    cluster = ocp 
    loglevel = DEBUG
    nsxlib_loglevel = DEBUG
    debug = True
    policy_nsxapi = True
    nsx_api_managers = 192.168.1.70 
    nsx_api_user = admin
    nsx_api_password = SAuer1357V1357V! 
    insecure = True
    subnet_prefix = 24
    log_firewall_traffic = DENY
    use_native_loadbalancer = True
    pool_algorithm = WEIGHTED_ROUND_ROBIN
    service_size = SMALL
    external_ip_pools = ocp-lb-pool 
    tier0_gateway = TF_Tier_0 
    single_tier_topology = True
    overlay_tz = "cfe2c4b2-23ef-4e23-a5e4-28d26740c74b" 
    edge_cluster = "2d8bbae1-c1c9-433b-8943-1fc8bffa2ca6" 
    apiserver_host_ip = api.ocp.osauer.local 
    apiserver_host_port = 6443
    client_token_file = /var/run/secrets/kubernetes.io/serviceaccount/token
    ca_file = /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    loglevel = DEBUG
    baseline_policy_type = allow_cluster
    enable_multus = False
    process_oc_network = False
    ovs_bridge = br-int
    ovs_uplink_port = ens192
root@sauer-virtual-machine:/home/sauer/ncp# 
