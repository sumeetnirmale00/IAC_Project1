I'm excited to share my latest hands-on project where I used Terraform to provision infrastructure on AWS! This project was a deep dive into Infrastructure as Code (IaC), automation, and secure state management.

🔹 What I Built
Using Terraform, I successfully deployed:
✅ EC2 instances with Apache web servers
✅ A dynamic portfolio webpage on each instance
✅ Secure S3 bucket backend storage for state file management
✅ Properly defined providers, variables, and outputs for modularity

🔍 Key Learnings
📌 Terraform Backend Configuration: I stored the Terraform state file in an S3 bucket (configured in backend.tf) to ensure security, versioning, and collaboration. This avoids local state file corruption and accidental loss.
📌 User Data Automation: Through userdata.sh and userdata1.sh, I automated the installation of Apache, retrieval of instance metadata, and creation of a custom webpage with animated styling. Now, each EC2 instance displays a unique personalized portfolio page.
📌 Infrastructure as Code Best Practices: I followed modular Terraform configurations, making the setup reproducible, scalable, and maintainable.
