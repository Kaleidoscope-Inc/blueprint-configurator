# Kaleidoscope GCP Blueprint Setup

## Overview

This tutorial walks you through configuring your GCP project for Kaleidoscope crawling. It creates a read-only service account with the required IAM roles and outputs the credentials needed for the Kaleidoscope platform.

**Estimated time**: 5 minutes

---

## Step 1: Set your project

Set the GCP project you want Kaleidoscope to crawl:

```bash
gcloud config set project YOUR_PROJECT_ID
```

Replace `YOUR_PROJECT_ID` with your actual GCP project ID.

---

## Step 2: Enable required APIs

```bash
gcloud services enable \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com
```

---

## Step 3: Initialize Terraform

```bash
cd gcp
terraform init
```

---

## Step 4: Deploy

Run Terraform with your project ID:

```bash
terraform apply -var="project_id=$(gcloud config get-value project)"
```

Review the plan and type `yes` to confirm.

---

## Step 5: Retrieve credentials

After deployment, retrieve the service account key:

```bash
terraform output -raw service_account_key_json | base64 -d > kscope-crawl-key.json
```

Extract the values needed for Kaleidoscope:

```bash
echo "Project ID:     $(terraform output -raw project_id)"
echo "Client Email:   $(terraform output -raw client_email)"
echo "Client ID:      $(terraform output -raw client_id)"
echo ""
echo "Private Key ID and Private Key are in kscope-crawl-key.json"
cat kscope-crawl-key.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'Private Key ID: {d[\"private_key_id\"]}')"
```

---

## Step 6: Configure in Kaleidoscope

1. Go to the Kaleidoscope platform
2. Add a new GCP Blueprint account
3. Enter the values from Step 5:
   - **GCP Project ID**
   - **Client ID**
   - **Client Email**
   - **Private Key ID** (from the JSON file)
   - **Private Key** (from the JSON file)
4. Select the regions to crawl

---

## Cleanup

To remove the service account and all role bindings:

```bash
terraform destroy -var="project_id=$(gcloud config get-value project)"
```

---

## What was created

- A service account (`kscope-crawl@YOUR_PROJECT.iam.gserviceaccount.com`)
- 20 read-only IAM role bindings (see [README.md](./README.md) for the full list)
- A service account key for authentication

All roles are **read-only**. No write or admin access is granted.
