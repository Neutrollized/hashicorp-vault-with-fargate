output "_0_login_ecr" {
  value = "aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
}

output "_1_docker_build_and_push" {
  value = <<EOT
docker build -t ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/vault:${var.vault_version} ecs-fargate/.
docker push ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/vault:${var.vault_version}
EOT
}

output "_2_list_running_ecs_service" {
  value = "ecs-cli ps --cluster ${aws_ecs_cluster.ecs_cluster.name} --desired-status RUNNING"
}

output "_3_initialize_vault" {
  value = "curl -s -X PUT http://[VAULT_ADDR]:8200/v1/sys/init --data @ecs-fargate/init.json"
}
