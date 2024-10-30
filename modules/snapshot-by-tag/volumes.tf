data "aws_ebs_volumes" "example" {
  tags = {
    environment = var.environment
  }

 filter {
    name   = "tag:environment"
    values = [var.environment]
  }
}

resource "aws_ebs_snapshot" "example_snapshot" {  
  for_each = toset(data.aws_ebs_volumes.example.ids)
  volume_id = each.value

  tags = {    
    Name = format("snapshot-%s-%s", var.environment, each.value)
  }
}