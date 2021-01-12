This is an example of a fully scaleble api deployment on ECS Fargate.

## Stack used

AWS:
- ECS - Fargate
- ALB
- And all supportive service (IAM, Security Groups, EC2, etc.)

Shell Script

Python

Docker

Terraform

## Some ideas that could be improved over time

- Nginx as a reverse proxy inside the container;
- Terraform modules instead of a single project resources;
- Terraform state would be remote;
- Substitute build.sh script for some configuration tool like Ansible that would be easier to read and maintain the code;
- Substitute cloudwatch standard monitring with different monitoring stack;
- Use actions for deployment instead of running shell commands;

## Deploy Instructions:

DO NOT FORGET TO CONFIGURE YOUR AWS CREDENTIALS AS YOU WISH. I ADVISE TO USE:
```bash
aws configure
```

Add to your Github global variables your AWS credentials: `aws_access_key_id` and `aws_secret_access_key`.

Change `aws_acc_id` and `AWS_ACC_ID` values on `main.tf` and `build.sh` respectively, to your AWS's account id.

Manually create a ECR repository named `service` on the AWS's region you've chosen to deploy you application. The region value must be specified on `main.tf` and `build.sh`.

Container image should be built and pushed to ECR as soon as a commit goes to master and everything above is set up. In case it doesn't work, just run the script deploy.sh with `pipeline` option first, it will build and push the container image to ECR.
```bash
./build.sh pipeline
```

Run the script deploy.sh, it will do the whole job, including the installation of the tools needed.
```bash
./build.sh deploy
```

## Destroy Instructions:

Run the script destroy.sh, it will do the whole job.
```bash
./build.sh destroy
```
