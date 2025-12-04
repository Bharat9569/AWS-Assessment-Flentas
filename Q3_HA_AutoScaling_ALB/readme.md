# Q3 - High Availability + Auto Scaling (ALB -> ASG -> Private Instances)

Create a multi-AZ VPC with public and private subnets. Deploy an Internet-facing ALB in public subnets and an Auto Scaling Group (ASG) that launches instances in private subnets. The ALB forwards traffic to a target group attached to ASG instances. NAT Gateway allows private instances to access the internet for package installation. Use Security Groups to restrict access (ALB SG allows 0.0.0.0/0 on 80, instance SG allows ALB SG only).

*Instructions*
1. Update ssh_key_name and ami_id variables.
2. terraform init and terraform apply -var='prefix=FirstName_Lastname'.
3. Capture screenshots: ALB details, Target Group, Auto Scaling Group, EC2 instances (launched by ASG).
4. Cleanup: terraform destroy -var='prefix=FirstName_Lastname' (may require deleting ASG first if instances exist).