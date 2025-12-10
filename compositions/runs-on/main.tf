data "aws_region" "current" {}

locals {
  tags = merge(
    {
      Environment = terraform.workspace
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

module "runs_on" {
  source = "../../modules/cloudformation"
  
  stack_name   = var.stack_name
  template_url = "https://runs-on.s3.eu-west-1.amazonaws.com/cloudformation/template-${var.template_version}.yaml"
  
  parameters = {
    # Required
    GithubOrganization = var.organization
    LicenseKey         = var.license_key
    EmailAddress       = var.email
    NetworkingStack    = var.networking_stack
    
    # Cost Management
    CostReportsEnabled = var.cost_reports_enabled ? "true" : "false"
    CostAllocationTag  = var.cost_allocation_tag
    
    # Monitoring
    EnableDashboard       = var.enable_dashboard ? "true" : "false"
    Ec2LogRetentionInDays = tostring(var.ec2_log_retention_days)
    
    # Disk Performance
    RunnerDefaultVolumeThroughput = tostring(var.runner_default_volume_throughput)
    RunnerDefaultDiskSize         = tostring(var.runner_default_disk_size)
    
    # Spot Instance Protection
    SpotCircuitBreaker = var.spot_circuit_breaker
    
    # Security
    EncryptEbs   = var.encrypt_ebs ? "true" : "false"
    SSHAllowed   = var.ssh_allowed ? "true" : "false"
    SSHCidrRange = var.ssh_cidr_range
  }
  
  capabilities = ["CAPABILITY_IAM"]
  
  tags = local.tags
}