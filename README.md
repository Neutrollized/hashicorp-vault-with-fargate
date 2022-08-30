# Vault on AWS ECS Fargate

[AWS Elastic Container Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository)

[AWS S3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)

[AWS Key Management Service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)

[AWS Elastic Container Serivce](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster)

In June 2021, I released [Free-tier Vault with Cloud Run](https://github.com/Neutrollized/hashicorp-vault-with-cloud-run), which allow you to deploy HashiCorp Vault on Google Cloud full managed serverless container platform, Cloud Run. GCP is my primary (and favorite) cloud provider, but I thought I'd try to make a similar deployment equivalent on Azure's [Container Instances](https://azure.microsoft.com/en-us/services/container-instances/) and AWS' [Fargate](https://aws.amazon.com/fargate/).  I figured this would allow me to learn a bit more about Azure and AWS' offerings.

HashiCorp's products makes this possible by offering binaries for all sorts of architectures and operating systems, so whether you're on a Mac or Windows or Raspberry Pi, there's a binary for you!

**NOTE:** I am once again building my own Vault Docker image because I wanted to learn how the IAM piece works with AWS and also using their managed [Azure Container Registry](https://aws.amazon.com/ecr/).  You can just as easily use the HashiCorp provided Docker image when deploying your ECS.

This repo contains Terraform code that will deploy the required underlying infrastructure (ECR, S3, KMS for auto-unseal, ECS Fargate for the app deployment), but the user will have to perform some tasks via the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [ECS CLI](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html).  The details of those command can be found [here](./ecs-fargate/README.md)

ECS Fargate, to me, is a bit weird.  It's not what I would consider truly serverless as you still have to reference a VPC and its subnets.  The unintended "pro" of this is you can apply [security groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html) to it, which is not something you can with GCP or Azure without attaching a load balancer.
 

## How the Services are used
### S3
This will serve as the [storage backend](https://www.vaultproject.io/docs/configuration/storage/s3) for Vault.

### KMS
Used for [auto-unseal](https://www.vaultproject.io/docs/concepts/seal#auto-unseal)

### ECS Fargate
Where the Vault binary will be run from.  

## IMPORTANT
Currently I am *not* encrypting the IAM key during resource creation, meaning that both the access key id and secret access key are stored in plain text in the Terraform state file.  I am aware this is insecure and not best practices but will be something I will look to remediate at a later time.  Optionally, you can leave out the [ECS Task Definition resource](./ecs.tf) and create it via AWS CLI (manual steps outlined [here](./ecs-fargate/README.md)).  However, because the credentials are passed in as part of environment variables to the task definition, it will show up in task details and you probably don't want that.  A better way would probably be using a specific IAM role for the container instance, but I haven't really dug deep into that yet and will be in a later release as I make incremental improvements to this repo.
