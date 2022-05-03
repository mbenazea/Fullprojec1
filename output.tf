output "instance_publicIp" {
  description = "Here is your public IP address"
  value       = aws_eip.my-elastic-ip.public_ip

}

output "vpc_id" {
  description = "here is the vpc id"
  value       = aws_vpc.webserver-vpc.id

}

output "securityGpID" {
  description = "hers the secureity group id"
  value       = aws_security_group.webserver-SG.id

}

output "Netwk_interfaceId" {
  description = "hers the secureity group id"
  value       = aws_network_interface.my-Network-Interface.id

}

output "rout_tableId" {
  description = "hers the secureity group id"
  value       = aws_route_table.Public-RT.id

}
