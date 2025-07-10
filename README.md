ECS - Elastic Container Service

AWS's fully managed container orchestration service - allows to run Docker without managing the cluster control plane. 

Difference between ECS & Kubernetes? 
- ECS is fully managed by AWS, k8s is managed by control plane (the brain of the orchestration, controls the workers, handles networking, scaling & health checks)

K8S control plane is a manager with a team of assistants, and assistants are:
- kube-apiserver - receives commands from you
- kube-scheduler - places pods/apps
- controller-manager - makes sure that things are as you said
and etc.

The ECS on the hand is fully hidden & managed by AWS. It just does what it is being told.
For example: create 3 containers running an image XYZ, it figures out where to run, how and etc. If a pod dies, it restarts it. 

ECS Launch Types:
- FarGate (aka Serverless):
  - AWS manages
  - you define CPU, memory & container specs
  - No EC2 instances to manage
  - Best for simple apps, event driven workloads, CI/CD pipelines
- EC2:
  - You manage the EC2 instance in the ECS cluster
  - Greater control (custom AMIs, file systems, daemon processses)
  - Best for consistent, long running apps, also can be used with reserved & spot instances
- External:
  - ECS on your own hardware
  - Best for on-prem deployments
 
ECS components (architecture): 
- Cluster - logical group of resources, it organizes the resources
- Task Definition - blueprint (image, cpu, mem, logs, env vars), the recipe for the app, this is used to launch a task
- Task - actual app running (created from task definition) 
- Service - makes sure that the tasks stay running, ensures a set number of tasks are always running, automatically restarts any crashed task, rolling updates, load balancers
- Container - Docker container 
- Launch Type - how you want to run your containers (fargate, ec2, external)
- Capacity Provider - the component that decides when and where to add more power (scaling)

Steps for ECS:
- Docker container (built & pushed to the ECR - Amazon Elastic Container Registry
- Define Task Definition
- Create ECS Cluster
- Create ECS service
- Expose via ALB (Application Load Balancer) (optional, if needs to be accessed from the internet)
- Watch via CloudWatch (optional)

Security:
- IAM roles for tasks (if need to access AWS resources securely) - ecsTaskExecutionRole
- Secrets Manager or SSM Parameter Store to inject secrets into containers
- Restrict Security Groups & VPC for network isolation

ECS is best for:
- microservices architecture
- API services
- Scheduled jobs
- Long-running apps with scaling
- Lift-and-shift containerized legacy apps (rehosting - moving from one environment to another (from onprem to the cloud) - Containerized the app, Migrated to a Cloud & Deployed)
- Blue/Green deployments using CodeDeploy

ECS is not ideal for:
- Dynamic workloads requiring node autoscaling and more extensibility (EKS is more ideal for this)
- Multi-Cloud, ECS is AWS only

CI/CD Usage (example):
- GitHub Actions:
  - pulls the code
  - builds container
  - pushes to ECR
  - ECS pulls the new image from ECR
- CodePipeline:
  - pulls the code
  - CodeBuild - builds the container
  - CodeDeploy - handles the deployment

Tips & Tricks:
- one container per task
- versioning task definitions - never overwrite (so can be rolled back)
- IAM roles for tasks, not hardcoded secrets
- ECS in private subnets
- CloudWatch logs for each container
- FarGate Spot for cost saving / non critical workloads
- Turn off unused services/tasks














