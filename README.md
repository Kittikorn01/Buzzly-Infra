# 🐝 Buzzly Infrastructure

> **Terraform** สำหรับสร้าง AWS EC2 Instance แล้ว Deploy **Buzzly Web Project** ขึ้นไปให้อัตโนมัติ

---

## 🚀 Quick Start (สำหรับอาจารย์ / ผู้ตรวจงาน)

หากต้องการให้ระบบทำงานได้ทันทีโดยไม่ต้องตั้งค่า Database เอง:

1. **ตั้งค่า AWS CLI:** รัน `aws configure` (ใส่ Access Key ที่มีสิทธิ์สร้าง EC2)
2. **Setup Variables:** 
   - `cp terraform.tfvars.example terraform.tfvars`
   - ใส่ข้อมูลใน `terraform.tfvars` (**ใช้ค่าโครงการ Supabase ที่ผมเตรียมไว้ให้แล้วได้เลยครับ**)
3. **Deploy:**
   ```bash
   terraform init
   terraform apply -auto-approve
   ```
4. **Done:** รอประมาณ 3-5 นาที ให้ระบบรัน Docker จนเสร็จ แล้วเปิด `web_url` ที่แสดงใน Output ครับ! 🎉

---

## 📖 สารบัญ
...

1. [สิ่งที่ต้องเตรียมก่อน (Prerequisites)](#-สิ่งที่ต้องเตรียมก่อน-prerequisites)
2. [ติดตั้ง Tools ที่จำเป็น](#-ติดตั้ง-tools-ที่จำเป็น)
3. [ตั้งค่า AWS CLI (Login)](#-ตั้งค่า-aws-cli-login)
4. [สร้าง SSH Key Pair บน AWS](#-สร้าง-ssh-key-pair-บน-aws)
5. [เตรียม Supabase Credentials](#-เตรียม-supabase-credentials)
6. [Clone Repo นี้ & ตั้งค่า](#-clone-repo-นี้--ตั้งค่า)
7. [Deploy ด้วย Terraform](#-deploy-ด้วย-terraform)
8. [เปิดเว็บ! 🎉](#-เปิดเว็บ-)
9. [Troubleshooting (แก้ปัญหา)](#-troubleshooting-แก้ปัญหา)
10. [อัปเดตโค้ด (Re-deploy)](#-อัปเดตโค้ด-re-deploy)
11. [ลบทรัพยากรทั้งหมด (Cleanup)](#-ลบทรัพยากรทั้งหมด-cleanup)
12. [สรุป Architecture](#-สรุป-architecture)

---

## 📦 สิ่งที่ต้องเตรียมก่อน (Prerequisites)

| # | รายการ | รายละเอียด |
|---|--------|-----------|
| 1 | **AWS Account** | สมัครที่ [aws.amazon.com](https://aws.amazon.com/) (Free Tier ใช้ได้ 12 เดือน) |
| 2 | **Buzzly App Repo (Repo 2)** | โค้ดของ Buzzly Web ต้อง push ขึ้น GitHub เป็น **Public repo** แล้ว |
| 3 | **Supabase Project** | สร้างที่ [supabase.com](https://supabase.com/) แล้วเตรียม credentials ไว้ |

---

## 🔧 ติดตั้ง Tools ที่จำเป็น

ต้องติดตั้ง 2 ตัวนี้ในเครื่องก่อน:

### 1. ติดตั้ง AWS CLI

AWS CLI ใช้สำหรับ login เข้า AWS จาก Terminal

**Windows:**
```powershell
# ดาวน์โหลดตัวติดตั้งจาก https://aws.amazon.com/cli/
# หรือใช้ winget:
winget install Amazon.AWSCLI
```

**macOS:**
```bash
brew install awscli
```

**Linux (Ubuntu/Debian):**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**ตรวจสอบว่าติดตั้งสำเร็จ:**
```bash
aws --version
# ต้องได้ผลลัพธ์ประมาณ: aws-cli/2.x.x Python/3.x.x ...
```

### 2. ติดตั้ง Terraform

Terraform ใช้สำหรับสร้าง Infrastructure บน AWS อัตโนมัติ

**Windows:**
```powershell
# ดาวน์โหลดจาก https://developer.hashicorp.com/terraform/install
# หรือใช้ winget:
winget install Hashicorp.Terraform
```

**macOS:**
```bash
brew install terraform
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install terraform
```

**ตรวจสอบว่าติดตั้งสำเร็จ:**
```bash
terraform -version
# ต้องได้ผลลัพธ์ประมาณ: Terraform v1.x.x
```

---

## 🔑 ตั้งค่า AWS CLI (Login)

### Step 1: สร้าง Access Key จาก AWS Console

1. เข้า [AWS Console](https://console.aws.amazon.com/) → Login ด้วย AWS Account
2. คลิกชื่อ User ที่มุมขวาบน → เลือก **Security credentials**
3. เลื่อนลงมาหา **Access keys** → กด **Create access key**
4. เลือก **Command Line Interface (CLI)** → ติ๊กยอมรับ → กด **Create access key**
5. **⚠️ สำคัญ!** จด **Access Key ID** และ **Secret Access Key** ไว้ (จะแสดงครั้งเดียว!)

### Step 2: Configure AWS CLI ในเครื่อง

เปิด Terminal แล้วรัน:

```bash
aws configure
```

ระบบจะถามทีละบรรทัด ใส่ค่าตามนี้:

```
AWS Access Key ID [None]: AKIA................    ← ใส่ Access Key ID ที่จดไว้
AWS Secret Access Key [None]: xxxxxxxxxxxxxxx    ← ใส่ Secret Access Key ที่จดไว้
Default region name [None]: ap-southeast-1       ← ใส่ Region (ap-southeast-1 = Singapore)
Default output format [None]: json               ← ใส่ json
```

> 💡 **หมายเหตุ Region:** ใน project นี้ default เป็น `ap-southeast-1` (Singapore)  
> ถ้าอยากเปลี่ยน region สามารถแก้ได้ใน `terraform.tfvars` ภายหลัง

### Step 3: ทดสอบว่า Login สำเร็จ

```bash
aws sts get-caller-identity
```

ถ้าสำเร็จจะได้ผลลัพธ์แบบนี้:
```json
{
    "UserId": "AIDA...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-username"
}
```

> ❌ ถ้าได้ error แปลว่า Access Key ผิด → กลับไปทำ Step 1 ใหม่

---

## 🗝️ สร้าง SSH Key Pair บน AWS

SSH Key ใช้สำหรับ remote เข้า EC2 Instance (เพื่อดู log หรือ debug)

### วิธีสร้างผ่าน AWS Console:

1. เข้า [AWS EC2 Console](https://console.aws.amazon.com/ec2/)
2. **⚠️ ตรวจสอบ Region** ที่มุมขวาบนให้ตรงกับที่จะ deploy (เช่น `ap-southeast-1`)
3. เมนูซ้าย → **Network & Security** → **Key Pairs**
4. กด **Create key pair**
5. ตั้งค่า:
   - **Name:** ตั้งชื่อ เช่น `buzzly-key` (จำชื่อนี้ไว้ ต้องใช้ตอนตั้งค่า!)
   - **Key pair type:** RSA
   - **Private key file format:** `.pem` (macOS/Linux) หรือ `.ppk` (Windows ที่ใช้ PuTTY)
6. กด **Create key pair** → ไฟล์ `.pem` จะโหลดลงเครื่องอัตโนมัติ

### ⚠️ สำคัญ: เก็บไฟล์ .pem ให้ดี

```bash
# macOS/Linux: ย้ายไฟล์ไป ~/.ssh และตั้ง permission
mv ~/Downloads/buzzly-key.pem ~/.ssh/
chmod 400 ~/.ssh/buzzly-key.pem

# Windows: เก็บไฟล์ไว้ในที่ปลอดภัย เช่น C:\Users\USERNAME\.ssh\
```

> 🔒 ไฟล์ `.pem` นี้จะดาวน์โหลดได้ **ครั้งเดียว** ถ้าหายต้องสร้าง Key Pair ใหม่

---

## 🟢 เตรียม Supabase Credentials

1. เข้า [Supabase Dashboard](https://supabase.com/dashboard)
2. เลือก Project ของคุณ (หรือสร้างใหม่)
3. ไปที่ **Settings** → **API**
4. จดค่าเหล่านี้ไว้:

| ค่า | หาจากตรงไหน |
|-----|-------------|
| `SUPABASE_URL` | Project URL (เช่น `https://xxxxx.supabase.co`) |
| `SUPABASE_ANON_KEY` | Project API Keys → `anon` `public` |
| `SUPABASE_SERVICE_ROLE_KEY` | Project API Keys → `service_role` (กด Reveal เพื่อดู) |

---

## 📂 Clone Repo นี้ & ตั้งค่า

### Step 1: Clone Repository

```bash
git clone https://github.com/Kittikorn01/Buzzly-Infra.git
cd Buzzly-Infra
```

### Step 2: สร้างไฟล์ตั้งค่า

```bash
cp terraform.tfvars.example terraform.tfvars
```

### Step 3: แก้ไข `terraform.tfvars`

เปิดไฟล์ `terraform.tfvars` ด้วย editor ที่ถนัด แล้วใส่ค่าของจริง:

```hcl
# 1. ชื่อ SSH Key Pair (ที่สร้างไว้ในขั้นตอนก่อนหน้า)
ssh_key_name    = "buzzly-key"

# 2. URL ของ Buzzly App repo (Repo 2) - ต้องเป็น Public repo
github_repo_url = "https://github.com/your-username/BuzzlyDev.git"

# 3. Supabase Credentials
supabase_url              = "https://your-project-id.supabase.co"
supabase_anon_key         = "eyJhbGci..."
supabase_service_role_key = "eyJhbGci..."
```

> ⚠️ **สำคัญ:** ไฟล์ `terraform.tfvars` อยู่ใน `.gitignore` แล้ว จะไม่ถูก push ขึ้น GitHub  
> ห้าม commit ไฟล์นี้เด็ดขาด เพราะมี credentials สำคัญ!

---

## 🚀 Deploy ด้วย Terraform

เปิด Terminal ที่โฟลเดอร์ `Buzzly-Infra` แล้วรันทีละคำสั่ง:

### Step 1: Initialize Terraform

```bash
terraform init
```
> ดาวน์โหลด AWS Provider และเตรียมพร้อม (ครั้งแรกครั้งเดียว)

ผลลัพธ์ที่ถูกต้อง:
```
Terraform has been successfully initialized!
```

### Step 2: ตรวจสอบแผนก่อน Deploy (Preview)

```bash
terraform plan
```
> แสดงรายการทรัพยากรที่จะสร้าง ให้ตรวจดูว่าถูกต้อง

ผลลัพธ์จะแสดงประมาณ:
```
Plan: 2 to add, 0 to change, 0 to destroy.
```
(จะสร้าง Security Group 1 ตัว + EC2 Instance 1 ตัว)

### Step 3: สร้าง Infrastructure จริง!

```bash
terraform apply -auto-approve
```
> ⏱️ รอประมาณ 1-2 นาที จนสร้างเครื่องเสร็จ

ผลลัพธ์ที่สำเร็จจะแสดง:
```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

api_url     = "http://xx.xx.xx.xx:3001"
public_ip   = "xx.xx.xx.xx"
ssh_command = "ssh -i YOUR_KEY.pem ubuntu@xx.xx.xx.xx"
web_url     = "http://xx.xx.xx.xx"
```

---

## 🌐 เปิดเว็บ! 🎉

หลังจาก `terraform apply` เสร็จแล้ว:

> ⏱️ **รอประมาณ 3-5 นาที** ให้ EC2 ติดตั้ง Docker และ Build แอปให้เสร็จก่อน

จากนั้นเปิด Browser แล้วไปที่:

| บริการ | URL | พอร์ต |
|--------|-----|-------|
| **🖥️ หน้าเว็บ (Frontend)** | `http://<PUBLIC_IP>` | 80 |
| **⚡ API (Mock API)** | `http://<PUBLIC_IP>:3001` | 3001 |

> 💡 `<PUBLIC_IP>` ดูได้จาก output ของ `terraform apply` หรือรัน:
> ```bash
> terraform output public_ip
> ```

### ยังเปิดเว็บไม่ได้?

ถ้ารอ 5 นาทีแล้วยังเข้าไม่ได้ → ดูส่วน [Troubleshooting](#-troubleshooting-แก้ปัญหา) ด้านล่าง

---

## 🛠️ Troubleshooting (แก้ปัญหา)

### ปัญหา: เปิดเว็บไม่ได้ / หน้าเว็บ Error

**วิธี SSH เข้าไปดู log:**

```bash
# macOS/Linux
ssh -i ~/.ssh/buzzly-key.pem ubuntu@<PUBLIC_IP>

# Windows (PowerShell)
ssh -i C:\Users\USERNAME\.ssh\buzzly-key.pem ubuntu@<PUBLIC_IP>
```

**เช็ค Deployment Log:**
```bash
# ดู log ว่า setup script ทำงานถึงไหนแล้ว
tail -f /var/log/cloud-init-output.log

# ดูสถานะ Docker containers
sudo docker ps

# ดู log ของ containers
sudo docker compose -f /home/ubuntu/Buzzly-App/docker-compose.yml logs
```

### ปัญหา: `terraform apply` error — Invalid credentials

```
Error: error configuring Terraform AWS Provider: no valid credential sources found
```
→ แก้ไข: รัน `aws configure` ใหม่ แล้วใส่ Access Key ที่ถูกต้อง

### ปัญหา: `terraform apply` error — Key Pair not found

```
Error: error launching source instance: InvalidKeyPair.NotFound
```
→ แก้ไข: ตรวจสอบว่า:
1. ชื่อ Key Pair ใน `terraform.tfvars` ตรงกับชื่อบน AWS Console
2. Key Pair อยู่ใน **Region เดียวกัน** ที่จะ deploy

### ปัญหา: `terraform apply` error — AMI not found

```
Error: no matching AMI found
```
→ แก้ไข: บาง region อาจไม่มี AMI ที่ต้องการ ลองเปลี่ยน region ใน `terraform.tfvars`

### ปัญหา: SSH — Permission denied

```bash
# macOS/Linux: ตั้ง permission ไฟล์ .pem
chmod 400 ~/.ssh/buzzly-key.pem
```

---

## 🔄 อัปเดตโค้ด (Re-deploy)

ถ้า push โค้ดใหม่ไปที่ Repo 2 แล้วอยาก deploy ตามให้:

```bash
# 1. SSH เข้าเครื่อง
ssh -i ~/.ssh/buzzly-key.pem ubuntu@<PUBLIC_IP>

# 2. เข้าโฟลเดอร์แอป
cd Buzzly-App

# 3. ดึงโค้ดใหม่
git pull

# 4. Build & Deploy ใหม่
sudo docker compose up -d --build
```

---

## 🗑️ ลบทรัพยากรทั้งหมด (Cleanup)

เมื่อไม่ใช้งานแล้ว **ต้องลบทิ้ง** เพื่อไม่ให้เสียค่าใช้จ่าย:

```bash
terraform destroy -auto-approve
```

ผลลัพธ์:
```
Destroy complete! Resources: 2 destroyed.
```

> ⚠️ หลังจาก destroy แล้ว เว็บจะเข้าไม่ได้อีก ถ้าอยาก deploy ใหม่ให้รัน `terraform apply -auto-approve` อีกครั้ง

---

## 📐 สรุป Architecture

```
┌──────────────────────────────────────────────────────┐
│                    AWS Cloud                          │
│                                                      │
│  ┌────────────────────────────────────────────────┐  │
│  │          Security Group (buzzly-web-sg)         │  │
│  │  ┌──────────────────────────────────────────┐  │  │
│  │  │        EC2 Instance (t2.micro)           │  │  │
│  │  │        Ubuntu 22.04 LTS                  │  │  │
│  │  │                                          │  │  │
│  │  │  ┌──────────────┐  ┌──────────────────┐  │  │  │
│  │  │  │  Frontend    │  │  Mock API        │  │  │  │
│  │  │  │  (Port 80)   │  │  (Port 3001)     │  │  │  │
│  │  │  │  Vite + React│  │  Express.js      │  │  │  │
│  │  │  └──────────────┘  └──────────────────┘  │  │  │
│  │  │           Docker Compose                 │  │  │
│  │  └──────────────────────────────────────────┘  │  │
│  │                                                │  │
│  │  Allowed Ports: 22 (SSH), 80 (HTTP), 3001 (API)│  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  Supabase (External) ◄── API connects to Supabase   │
└──────────────────────────────────────────────────────┘
```

### ไฟล์ในโปรเจกต์นี้

| ไฟล์ | หน้าที่ |
|------|---------|
| `provider.tf` | กำหนดว่าใช้ AWS Provider + Region |
| `variables.tf` | ประกาศตัวแปรที่ใช้ (key name, repo URL, Supabase creds) |
| `terraform.tfvars` | ค่าจริงของตัวแปร **(ห้าม commit!)** |
| `terraform.tfvars.example` | ตัวอย่างไฟล์ tfvars สำหรับ copy ไปแก้ |
| `main.tf` | สร้าง Security Group + EC2 Instance |
| `outputs.tf` | แสดง IP, URL, SSH Command หลัง deploy |
| `scripts/setup.tftpl` | สคริปต์อัตโนมัติที่รันบน EC2 (ติดตั้ง Docker, Clone repo, Deploy) |

---

## 📝 สรุปขั้นตอนทั้งหมด (Quick Checklist)

```
✅ 1. สมัคร AWS Account
✅ 2. ติดตั้ง AWS CLI + Terraform
✅ 3. สร้าง Access Key → รัน aws configure
✅ 4. สร้าง SSH Key Pair บน AWS Console
✅ 5. เตรียม Supabase Credentials
✅ 6. Clone repo → cp terraform.tfvars.example terraform.tfvars → แก้ค่า
✅ 7. terraform init → terraform plan → terraform apply -auto-approve
✅ 8. รอ 3-5 นาที แล้วเปิด http://<PUBLIC_IP> 🎉
✅ 9. เสร็จแล้วอย่าลืม terraform destroy -auto-approve
```
