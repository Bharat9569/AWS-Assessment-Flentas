# Q5 - AWS Architecture Diagram (draw.io)

For handling 10,000 concurrent users we use an Internet-facing ALB to distribute incoming traffic across an Auto Scaling Group of application servers located in private subnets across multiple AZs. A scalable RDS/Aurora cluster on private subnets handles relational data while ElastiCache (Redis) reduces DB load and accelerates read-heavy operations. Security Groups and NACLs limit traffic; WAF can protect against common web attacks. Observability is handled using CloudWatch metrics and logs, and optional services such as S3 for static content and SQS for background jobs improve resilience.

