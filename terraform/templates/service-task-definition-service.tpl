[
    {
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${environment}-${service-name}-log-group",
          "awslogs-region": "${region}",
          "awslogs-stream-prefix": "${environment}-${service-name}"
        }
      },
      "entryPoint": null,
      "portMappings": [
        {
          "protocol": "tcp",
          "containerPort": 8000
        }
      ],
      "command": null,
      "cpu": 256,
      "environment": ${environment-vars},
      "workingDirectory": "/app",
      "memory": 256,
      "image": "094579366022.dkr.ecr.${region}.amazonaws.com/${service-name}:latest",
      "essential": true,
      "name": "${service-name}",
      "networkMode": "awsvpc",
      "requiresCompatibilities": "FARGATE",
      "executionRoleArn": "${role_arn}"
    }
]
