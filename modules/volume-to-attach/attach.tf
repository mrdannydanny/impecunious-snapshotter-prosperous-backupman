resource "aws_ebs_volume" "example" {
  availability_zone = var.availability_zone
  size              = 2

  tags = {
    environment = var.environment
  }
}

resource "aws_ebs_volume" "example_second_vol" {
  availability_zone = var.availability_zone
  size              = 3

  tags = {
    environment = var.environment
  }
}

# attach the first volume to the instance
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.example.id
  instance_id = var.instance_id
}

# attach the second volume to the instance
resource "aws_volume_attachment" "ebs_att_second_vol" {
  device_name = "/dev/sdi"
  volume_id   = aws_ebs_volume.example_second_vol.id
  instance_id = var.instance_id
}