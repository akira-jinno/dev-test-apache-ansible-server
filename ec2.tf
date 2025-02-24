# EC2インスタンスの作成
resource "aws_instance" "ansible_server" {
  ami                    = "ami-072298436ce5cb0c4"   # Amazon Linux の AMI
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  key_name               = "test-ansible-apache-key"  # 事前に作成済みキーペア

  # ユーザーデータで Ansible のインストール、Ansible Galaxy 経由で Apache ロール取得、
  # 対象サーバー群用の inventory とプレイブックを作成
  user_data = <<-EOF
              #!/bin/bash
              # システムアップデートと必要パッケージのインストール
              yum update -y
              yum install -y git python3-pip
              # pip3 で Ansible をインストール
              pip3 install ansible
              # オプション：Ansible Galaxy から Apache ロール（geerlingguy.apache）を取得
              ansible-galaxy install geerlingguy.apache
              # サンプルインベントリファイルの作成
              cat <<EOL > /home/ec2-user/inventory.ini
              [apache_servers]
              # ここに対象サーバーのIPアドレスを追加してください
              EOL
              # サンプルプレイブックの作成（inventory.ini 内の apache_servers 対象）
              cat <<EOL > /home/ec2-user/playbook.yml
              - name: Setup Apache on remote servers using Ansible Galaxy role
                hosts: apache_servers
                become: yes
                roles:
                  - geerlingguy.apache
              EOL
              # inventory.ini と playbook.yml の所有権を ec2-user に変更
              chown ec2-user:ec2-user /home/ec2-user/inventory.ini /home/ec2-user/playbook.yml
              EOF

  tags = {
    Name = "test-ansible-apache"
  }
}
