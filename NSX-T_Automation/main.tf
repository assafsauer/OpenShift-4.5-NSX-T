
# Data Sources we need for reference later
data "nsxt_policy_transport_zone" "overlay_tz" {
    display_name = "Overlay"
}

data "nsxt_policy_edge_node" "edge_node_1" {
    edge_cluster_path   = data.nsxt_policy_edge_cluster.edge_cluster.path
    display_name        = "EDGE-1"  
}
 
data "nsxt_policy_transport_zone" "vlan_tz" {
    display_name = "VLAN"
}
 
data "nsxt_policy_edge_cluster" "edge_cluster" {
    display_name = "CLUSTER-EDGE-1"
}
 
 
# NSX-T Manager Credentials
provider "nsxt" {
    host                     = var.nsx_manager
    username                 = var.username
    password                 = var.password
    allow_unverified_ssl     = true
    max_retries              = 10
    retry_min_delay          = 500
    retry_max_delay          = 5000
    retry_on_status_codes    = [429]
}

 
# Create NSX-T VLAN Segments
resource "nsxt_policy_vlan_segment" "vlan101" {
    display_name = "vlan101"
    description = "VLAN Segment created by Terraform"
    transport_zone_path = data.nsxt_policy_transport_zone.vlan_tz.path
    vlan_ids = ["0"]
}
 
resource "nsxt_policy_dhcp_server" "dhcprofile1" {
  display_name      = "DHCP-P1"
  description       = "Terraform provisioned DhcpServerConfig"
  edge_cluster_path = data.nsxt_policy_edge_cluster.edge_cluster.path 
  lease_time        = 36000
  server_addresses  = ["10.4.1.10/24"]
} 
 
# Create Tier-0 Gateway
resource "nsxt_policy_tier0_gateway" "tier0_gw" {
    display_name              = "TF_Tier_0"
    description               = "Tier-0 provisioned by Terraform"
    failover_mode             = "NON_PREEMPTIVE"
    default_rule_logging      = false
    enable_firewall           = false
    force_whitelisting        = true
    ha_mode                   = "ACTIVE_STANDBY"
    edge_cluster_path         = data.nsxt_policy_edge_cluster.edge_cluster.path
 
    bgp_config {
        ecmp            = false              
        local_as_num    = "65003"
        inter_sr_ibgp   = false
        multipath_relax = false
    }
 
    tag {
        scope = "color"
        tag   = "blue"
    }
}
 
# Create Tier-0 Gateway Uplink Interfaces
resource "nsxt_policy_tier0_gateway_interface" "uplink1" {
    display_name        = "Uplink-01"
    description         = "Uplink to VLAN101"
    type                = "EXTERNAL"
    edge_node_path      = data.nsxt_policy_edge_node.edge_node_1.path
    gateway_path        = nsxt_policy_tier0_gateway.tier0_gw.path
    segment_path        = nsxt_policy_vlan_segment.vlan101.path
    subnets             = ["192.168.1.13/24"]
    mtu                 = 1600
}
 




resource "nsxt_policy_tier1_gateway" "tier1_gw" {
    description               = "Tier-1 provisioned by Terraform"
    display_name              = "TF-Tier-1-01"
    nsx_id                    = "ocp-t1"
    edge_cluster_path         = data.nsxt_policy_edge_cluster.edge_cluster.path
    failover_mode             = "NON_PREEMPTIVE"
    #default_rule_logging      = "false"
    #enable_firewall           = "false"
    enable_standby_relocation = "false"
    #force_whitelisting        = "false"
    tier0_path                = nsxt_policy_tier0_gateway.tier0_gw.path
    route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED" , "TIER1_NAT", "TIER1_LB_VIP"]
    pool_allocation           = "ROUTING"
}
 




# Create NSX-T Overlay Segments
resource "nsxt_policy_segment" "t1_int" {
    display_name        = "ocp"
    description         = "Segment created by Terraform"
    transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path
    ##connectivity_path   = nsxt_policy_tier1_gateway.tier1_gw.path

    subnet {
       cidr        = "10.4.1.1/24"
     # dhcp_ranges = ["10.4.1.20-10.4.1.250"]

     ## dhcp_v4_config {
      #  server_address = "10.4.1.10/24"
       # lease_time     = 36000

      #  }
    }

}



resource "nsxt_policy_static_route" "route1" {
  display_name = "sroute"
  gateway_path = nsxt_policy_tier0_gateway.tier0_gw.path
  network      = "0.0.0.0/0"

  next_hop {
    admin_distance = "2"
    ip_address     = "192.168.1.30"
  }

  next_hop {
    admin_distance = "4"
    ip_address = "192.168.1.1"
  }

  tag {
    scope = "color"
    tag   = "blue"
  }


} 
