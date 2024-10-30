provider "aws" {}

# spins up a dummy ec2 for testing
module "dummy-ec2" {
  source = "./modules/dummy-ec2/"

  environment   = var.environment
  instance_type = var.instance_type
}

# attach a volume with a certain tag for testing
module "volume-to-attach" {
  source = "./modules/volume-to-attach"

  environment       = var.environment
  instance_id       = module.dummy-ec2.instance_id # value comes from output "instance_id" in ./modules/dummy-ec2/ec2-outputs.tf
  availability_zone = module.dummy-ec2.instance_az
}

# takes snapshot by tag
module "snapshot-by-tag" {
  source = "./modules/snapshot-by-tag"
  environment = var.environment # tag used to filter snapshots being created
}

# outputs
output "instance_id" {
  value = module.dummy-ec2.instance_details
}

output "volume_output_data" {
  value = module.snapshot-by-tag.volume_output_data
}