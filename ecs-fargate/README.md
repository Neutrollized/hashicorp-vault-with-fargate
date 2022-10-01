# README
Even though this is supposed to be "serverless", it still requires the default VPC


## Deployment
#### 0 - [Build the Image](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html)
```
aws ecr get-login-password --region [REGION] | docker login --username AWS --password-stdin [ACCOUNT_ID].dkr.ecr.[REGION].amazonaws.com

docker build -t [ACCOUNT_ID].dkr.ecr.[REGION].amazonaws.com/vault:[VAULT_VERSION]
```

#### 1 - [Register ECS Task Defintion](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ecs/register-task-definition.html)
Use the [ECS Task Definition template](./vault-ecs-task-def.json.template) and fill in the required fields and apply 
```
aws ecs register-task-definition \
  --cli-input-json file:///path/to/taskdef/vault-ecs-task-def.json
```

#### 2 - Deploy Service/Task
- [aws ecs create-service](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ecs/create-service.html
- [Tutorial: Creating a cluster with a Fargate Linux task using the AWS CLI])https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_AWSCLI_Fargate.html)

i.e.
```
aws ecs create-service \
  --cluster vault-ecs-cluster \ 
  --service-name vault-ecs-service \
  --task-definition vault-ecs-task-def \
  --scheduling-strategy REPLICA \
  --desired-count 1 \
  --capacity-provider-strategy "capacityProvider=FARGATE,weight=100,base=1" \
  --platform-version LATEST \
  --deployment-configuration "deploymentCircuitBreaker={enable=false,rollback=false},maximumPercent=200,minimumHealthyPercent=100" \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-1234567,subnet-2345678,subnet-3456789],securityGroups=[sg-4567890],assignPublicIp=ENABLED}" \
  --no-enable-ecs-managed-tags
```

#### 3 - Initialize Vault
I found it easiest to use the [Amazon ECS CLI](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html) to get the public IP of your service.  Unlike Cloud Run or Azure Container Instances, the deployment in ECS only provides an IP that changes with each (re)dployment which makes this annoying:
```
ecs-cli ps --cluster [ECS_CLUSTER_NAME] --desired-status RUNNING
```

```
export VAULT_ADDR="http://[ECS_TASK_PUBLIC_IP]:8200"
curl -s -X PUT ${VAULT_ADDR}/v1/sys/init --data @init.json
```


## Clean up
#### 1 - Destroy Resources
```
terraform destroy -auto-approve
```
