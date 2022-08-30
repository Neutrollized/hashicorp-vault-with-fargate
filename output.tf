#output "aws_default_vpc_id" {
#  value = aws_default_vpc.default.id
#}

#output "aws_default_subnet_ids" {
#  value = data.aws_subnets.default.ids
#}

#output "security_group_id" {
#  value = aws_security_group.vault.id
#}

#output "ecs_cluster_name" {
#  value = aws_ecs_cluster.ecs_cluster.name
#}

#output "awskms_keyid" {
#  value = aws_kms_key.vault_key.key_id
#}

output "_0_login_ecr" {
  value = "aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
}

output "_1_docker_build_and_push" {
  value = <<EOT
docker build -t ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/vault:${var.vault_version} ecs-fargate/.
docker push ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/vault:${var.vault_version}
EOT
}

output "_2_ecs_create_service" {
  value = <<EOT
aws ecs create-service \
  --cluster ${aws_ecs_cluster.ecs_cluster.name} \
  --service-name ${var.ecs_service_name} \
  --task-definition ${aws_ecs_task_definition.ecs-task-def.family} \
  --scheduling-strategy REPLICA \
  --desired-count 1 \
  --capacity-provider-strategy "capacityProvider=FARGATE,weight=100,base=1" \
  --platform-version LATEST \
  --deployment-configuration "deploymentCircuitBreaker={enable=false,rollback=false},maximumPercent=200,minimumHealthyPercent=100" \
  --network-configuration "awsvpcConfiguration={subnets=${jsonencode(data.aws_subnets.default.ids)},securityGroups=[${aws_security_group.vault.id}],assignPublicIp=ENABLED}" \
  --no-enable-ecs-managed-tags
EOT
}

output "_3_list_running_ecs_service" {
  value = "ecs-cli ps --cluster ${aws_ecs_cluster.ecs_cluster.name} --desired-status RUNNING"
}

output "_4_initialize_vault" {
  value = "curl -s -X PUT http://[VAULT_ADDR]:8200/v1/sys/init --data @ecs-fargate/init.json"
}
