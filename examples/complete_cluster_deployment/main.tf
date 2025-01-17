provider "intersight" {
  apikey    = var.intersight_key
  secretkey = var.intersight_secret
  endpoint  = var.endpoint
}

data "intersight_organization_organization" "organization_moid" {
  name = var.organization
} 

resource "intersight_kubernetes_cluster_profile" "deployaction" {

  # Kubernetes Cluster Profile  Adjust the values as needed.
  name                = "iks-cloud-b-tfcb"
  action              = "No-Op"
  
  depends_on = [module.iks_cluster]
  
  organization {
    object_type = "organization.Organization"
    moid        = data.intersight_organization_organization.organization_moid.results.0.moid
  } 
    
}

module "iks_cluster" {
  source  = "terraform-cisco-modules/iks/intersight//"
  version = ">= 2.1.3"

  # Kubernetes Cluster Profile  Adjust the values as needed.
  cluster = {
    name                = "iks-cloud-b-tfcb"
    action              = "Unassign"
    wait_for_completion = false
    worker_nodes        = 3
    load_balancers      = 3
    worker_max          = 10
    control_nodes       = 3
    ssh_user            = var.ssh_user
    ssh_public_key      = var.ssh_key
  }

  # IP Pool Information (To create new change "use_existing" to 'false' uncomment variables and modify them to meet your needs.)
  ip_pool = {
    use_existing = true
    name         = "ikspool"
    # ip_starting_address = "10.239.21.220"
    # ip_pool_size        = "20"
    # ip_netmask          = "255.255.255.0"
    # ip_gateway          = "10.239.21.1"
    # dns_servers         = ["10.101.128.15","10.101.128.16"]
  }

  # Sysconfig Policy (UI Reference NODE OS Configuration) (To create new change "use_existing" to 'false' uncomment variables and modify them to meet your needs.)
  sysconfig = {
    use_existing = true
    name         = "iks-cloud-sys-config-policy"
    # domain_name  = "rich.ciscolabs.com"
    # timezone     = "America/New_York"
    # ntp_servers  = ["10.101.128.15"]
    # dns_servers  = ["10.101.128.15"]
  }

  # Kubernetes Network CIDR (To create new change "use_existing" to 'false' uncomment variables and modify them to meet your needs.)
  k8s_network = {
    use_existing = true
    name         = "k8s-cluster1-network-policy"
    ######### Below are the default settings.  Change if needed. #########
    # pod_cidr     = "100.65.0.0/16"
    # service_cidr = "100.64.0.0/24"
    # cni          = "Calico"
  }

  # Version policy (To create new change "use_existing" to 'false' uncomment variables and modify them to meet your needs.)
  versionPolicy = {
    useExisting    = false
    policyName     = "1.21"
    iksVersionName = "1.21.11-iks.2"
  }

  # Trusted Registry Policy (To create new change "use_existing" to 'false' and set "create_new' to 'true' uncomment variables and modify them to meet your needs.)
  # Set both variables to 'false' if this policy is not needed.
  tr_policy = {
    use_existing = false
    create_new   = false
    # name         = "trusted-registry"
  }

  # Runtime Policy (To create new change "use_existing" to 'false' and set "create_new' to 'true' uncomment variables and modify them to meet your needs.)
  # Set both variables to 'false' if this policy is not needed.
  runtime_policy = {
    use_existing = true
    create_new   = false
    name                 = "k8s-cluster1-container-runtime-policy"
    # http_proxy_hostname  = "t"
    # http_proxy_port      = 80
    # http_proxy_protocol  = "http"
    # http_proxy_username  = null
    # http_proxy_password  = null
    # https_proxy_hostname = "t"
    # https_proxy_port     = 8080
    # https_proxy_protocol = "https"
    # https_proxy_username = null
    # https_proxy_password = null
  }

  # Infrastructure Configuration Policy (To create new change "use_existing" to 'false' and uncomment variables and modify them to meet your needs.)
  infraConfigPolicy = {
    use_existing = false
    platformType = "iwe"
    targetName   = "TF-HX-IWE"
    policyName = "iks-vm-config"
    description  = "VM infra policy created by TF"
    interfaces   = ["iwe-vm-net-10"]
    # vcTargetName   = optional(string)
    # vcClusterName      = optional(string)
    # vcDatastoreName     = optional(string)
    # vcResourcePoolName = optional(string)
    # vcPassword      = optional(string)
  }

  # Addon Profile and Policies (To create new change "createNew" to 'true' and uncomment variables and modify them to meet your needs.)
  # This is an Optional item.  Comment or remove to not use.  Multiple addons can be configured.
  addons = [
    #{
    #  createNew       = true
    #  addonPolicyName = "smm-test-cluster"
    #  addonName       = "smm"
    #  description     = "SMM Policy"
    #  upgradeStrategy = "AlwaysReinstall"
    #  installStrategy = "InstallOnly"
    #  releaseVersion  = "1.7.4-cisco4-helm3"
    #  overrides       = yamlencode({ "demoApplication" : { "enabled" : true } })
    #},
    #{
    #  createNew       = false
    #  addonPolicyName = "ccp-monitor"
    #  description     = "monitor Policy"
    #  # upgradeStrategy  = "AlwaysReinstall"
    #  # installStrategy  = "InstallOnly"
    #  releaseVersion = "0.2.61-helm3"
    #},
    {
       createNew       = false
       addonPolicyName = "kubedash"
       description     = "Kubernetes Dashboard"
    #  upgradeStrategy  = "AlwaysReinstall"
    #  installStrategy  = "InstallOnly"
    #  releaseVersion = "0.2.61-helm3"
    }
  ]

  # Worker Node Instance Type (To create new change "use_existing" to 'false' and uncomment variables and modify them to meet your needs.)
  instance_type = {
    use_existing = true
    name         = "vm-type-iks"
    # cpu          = 4
    # memory       = 16386
    # disk_size    = 40
  }

  # Organization and Tag Information
  organization = var.organization
  tags         = var.tags
}
