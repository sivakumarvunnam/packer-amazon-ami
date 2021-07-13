variable "ami_name" {
  type = string
  default = "svunnam-amzn2-urllib3-1.23"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioners and post-processors on a
# source.
source "amazon-ebs" "amazon-linux-2" {
  ami_name      = "${var.ami_name}-${local.timestamp}"
  instance_type = "t3.micro"
  region        = "${var.region}"
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-2.0.20210427.0-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "ec2-user"
  tags = {
    OS_VERSION = "Amazon-Linux-2"
    Relase = "20201-Q1"
    Environment = "Development"
    Base_AMI_Name= "${var.ami_name}-${local.timestamp}"
  }
}

# a build block invokes sources and runs provisioning steps on them.
# TODO: Add a test to test the salt-minion
build {
  sources = ["source.amazon-ebs.amazon-linux-2"]

  provisioner "shell" {
    script = "./bootstrap.sh"
  }
}
