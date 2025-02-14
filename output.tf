output "load_balancer_dns" {
  value = aws_lb.MyLoadBalancer.dns_name
}

output "instance_public_ip" {
  value = aws_instance.Web_Server1.public_ip
}

output "instance_public_ip2" {
  value = aws_instance.Web_Server2.public_ip
}
