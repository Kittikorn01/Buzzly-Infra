# Buzzly Infrastructure (Repo 1)

This repository contains the **Terraform** configuration to provision an AWS EC2 instance and automatically deploy the **Buzzly Web Project** (Repo 2).

## 📋 Prerequisites

1. **AWS CLI**: Authenticated with your AWS account.
2. **Key Pair**: An existing SSH Key Pair in the **ap-southeast-7 (Bangkok)** region.
3. **GitHub Repo**: The `BuzzlyDev` (Repo 2) project must be pushed to a public GitHub repository.

---

## 🚀 How to Run

### Step 1: Configuration
Copy the example variables file and fill in your real values:
```bash
cp terraform.tfvars.example terraform.tfvars
```
Edit `terraform.tfvars` and set:
- `ssh_key_name`: The name of your SSH key in AWS Console.
- `github_repo_url`: URL of your Repo 2 (e.g., `https://github.com/user/BuzzlyDev.git`).
- `supabase_url`, `supabase_anon_key`, `supabase_service_role_key`: Credentials from your Supabase Project.

### Step 2: Initialize & Provision
Run the following commands to deploy:

```bash
# 1. Initialize Terraform
terraform init

# 2. Review the execution plan
terraform plan

# 3. Create infrastructure and deploy app
terraform apply -auto-approve
```

### Step 3: Accessing the App
After `apply` finishes, Terraform will output the **Public IP**:
- **Frontend**: `http://<PUBLIC_IP>` (Port 80)
- **API**: `http://<PUBLIC_IP>:3001`

---

## 🛠️ Troubleshooting

- **Deployment Logs**: If the app isn't running, SSH into the instance and check the logs:
  ```bash
  ssh -i YOUR_KEY.pem ubuntu@<PUBLIC_IP>
  tail -f /var/log/cloud-init-output.log
  ```
- **Re-deploy**: If you push changes to Repo 2, you can SSH into the instance and run:
  ```bash
  cd Buzzly-App
  git pull
  sudo docker compose up -d --build
  ```

---

## 🗑️ Cleanup
To avoid costs, destroy the infrastructure when finished:
```bash
terraform destroy -auto-approve
```
