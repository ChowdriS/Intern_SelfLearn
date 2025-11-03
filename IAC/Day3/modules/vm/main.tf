data "aws_ami" "ubuntu" {
    most_recent = true
    owners      = ["099720109477"] 
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
}

resource "aws_security_group" "web_sg" {
    name   = "web-sg"
    vpc_id = var.vpc_id

    dynamic "ingress" {
        for_each = var.ingress_rules
        content {
            from_port   = ingress.value.from_port
            to_port     = ingress.value.to_port
            protocol    = ingress.value.protocol
            cidr_blocks = ingress.value.cidr_blocks
        }
    }

    dynamic "egress" {
        for_each = var.egress_rules
        content {
            from_port   = egress.value.from_port
            to_port     = egress.value.to_port
            protocol    = egress.value.protocol
            cidr_blocks = egress.value.cidr_blocks
        }
    }
}

resource "aws_launch_template" "web_lt" {
    name_prefix   = "web-lt-"
    image_id      = data.aws_ami.ubuntu.id
    instance_type = var.instance_type

    user_data = base64encode(
        templatefile("/Users/chowdri/Documents/Intern_SelfLearn/IAC/Day3/modules/vm/user-data.tpl", {
            db_endpoint = var.rds_endpoint
            db_username = var.db_username
            db_password = var.db_password
            git_repo    = var.git_repo
        })
    )

    vpc_security_group_ids = [aws_security_group.web_sg.id]
}

resource "aws_autoscaling_group" "web_asg" {
    desired_capacity     = 1
    max_size             = 1
    min_size             = 0
    vpc_zone_identifier  = var.subnet_ids

    launch_template {
        id      = aws_launch_template.web_lt.id
        version = "$Latest"
    }

    target_group_arns = [var.tg_arn]

    tag {
        key                 = "Name"
        value               = "web-asg"
        propagate_at_launch = true
    }
}
