# Q1 - Networking & Subnetting (VPC + 2 Public + 2 Private + IGW + NAT)
*Approach (4-6 lines)*
I create a custom VPC with /16 CIDR to allow room to expand. Two public and two private /24 subnets are created in separate AZs for HA. An Internet Gateway provides internet access for public subnets while a NAT Gateway in a public subnet provides outbound internet for private instances. Route tables are associated to ensure correct traffic flow.

*CIDRs used*
- VPC: 10.0.0.0/16
- Public1: 10.0.1.0/24
- Public2: 10.0.2.0/24
- Private1: 10.0.3.0/24
- Private2: 10.0.4.0/24

*Instructions*
1. Set prefix variable in main.tf or pass with -var='prefix=FirstName_Lastname'.
2. terraform init then terraform apply -var='prefix=FirstName_Lastname'.
3. Capture console screenshots: VPC, Subnets, Route Tables, NAT Gateway + IGW.
4. Cleanup: terraform destroy -var='prefix=FirstName_Lastname'.