variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 instance type (Free Tier eligible)"
  type        = string
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "Name of the existing AWS Key Pair (SSH Key)"
  type        = string
  default     = "buzzly-key" #แก้ไขชื่อ Key Pair
}

variable "github_repo_url" {
  description = "Public GitHub repository URL (Repo 2)"
  type        = string
  default     = "https://github.com/Kittikorn01/Buzzly-DevOps.git" # <--- แก้ไข URL GitHub 
}

# Supabase Credentials (จะถูกส่งไปที่ EC2 เพื่อสร้าง .env)
# ค่าเหล่านี้แนะนำให้ใส่ในไฟล์ terraform.tfvars (ที่ผมจะสร้างตัวอย่างไว้ให้)
variable "supabase_url" {
  description = "Supabase project URL"
  type        = string
}

variable "supabase_anon_key" {
  description = "Supabase Anon Key (Publishable)"
  type        = string
}

variable "supabase_service_role_key" {
  description = "Supabase Service Role Key"
  type        = string
  sensitive   = true
}
