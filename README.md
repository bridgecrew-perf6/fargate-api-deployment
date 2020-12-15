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

Run the script deploy.sh, it will do the whole job, including the installation of the tools needed.
```bash
./build.sh deploy
```

## Destroy Instructions:

Run the script destroy.sh, it will do the whole job.
```bash
./build.sh destroy
```
