# EC2インスタンスの作成
resource "aws_instance" "ansible_server" {
  ami                    = "ami-072298436ce5cb0c4"   # Amazon Linux の AMI
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  key_name               = "test-keypair"          # 事前に作成済みのキーペア

  # ユーザーデータで Ansible のインストール＆ Ansible Galaxy 経由で Apache ロール取得、プレイブック実行
  user_data = <<-EOF
              #!/bin/bash
              # システムアップデートと必要パッケージのインストール
              yum update -y
              yum install -y git python3-pip
              # pip3 で Ansible をインストール
              pip3 install ansible
              # Ansible Galaxy から Apache ロール（geerlingguy.apache）を取得
              ansible-galaxy install geerlingguy.apache
              # サンプルプレイブックを作成
              cat <<EOL > /home/ec2-user/playbook.yml
              - name: Setup Apache using Ansible Galaxy role
                hosts: localhost
                become: yes
                roles:
                  - geerlingguy.apache
              EOL
              # ec2-user に所有権を変更
              chown ec2-user:ec2-user /home/ec2-user/playbook.yml
              # プレイブックの実行
              ansible-playbook /home/ec2-user/playbook.yml
              EOF

  tags = {
    Name = "test-ansible-apache"
  }
}
