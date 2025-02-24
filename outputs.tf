# 出力：EC2インスタンスのパブリックIP
output "instance_ip" {
  value = aws_instance.ansible_server.public_ip
}
