# Q2 - EC2 Static Website (Nginx)

Launch a Free Tier EC2 (t2.micro) in a public subnet and use a user-data script to install and configure Nginx. The resume HTML is written to /usr/share/nginx/html/index.html and the instance listens on port 80. Apply basic hardening by using Security Groups (allow only SSH and HTTP) and by disabling unused services in user-data if needed.

*Instructions*
1. Update ssh_key_name and ami_id variables in main.tf.
2. terraform init and terraform apply -var='prefix=FirstName_Lastname' -var='ssh_key_name=YourKey'.
3. Visit the output public_ip in your browser to confirm.
4. Capture screenshots: EC2 console, Security Group, Website in browser.
5. Cleanup: terraform destroy -var='prefix=FirstName_Lastname'.