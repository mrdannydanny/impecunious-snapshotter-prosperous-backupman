output "instance_details" {
    value = aws_instance.dummy_ec2
}

output "instance_id" {
    value = aws_instance.dummy_ec2.id
}

output "instance_az" {
    value = aws_instance.dummy_ec2.availability_zone
}