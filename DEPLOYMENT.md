# Deployment Guide: Patient Appointment App

This guide walks you through deploying the Dockerized Vite + Express backend application to Google Cloud Run, and how to update it later.

---

## 1. Prerequisites

Before deploying, ensure you have the following:

*   **Google Cloud SDK (`gcloud`)** installed and authenticated.
*   **Docker** installed and running.
*   **Proper IAM Permissions** on Google Cloud to push to Artifact Registry or GCR, and to manage Cloud Run services.
*   **A configured database**. The app expects a MySQL database. Ensure your Cloud Run instance will have network access to this database (e.g., via Serverless VPC Access if the DB is on Cloud SQL).

---

## 2. Building and Pushing the Image

We have a dedicated script to streamline this process. 

1. Ensure your terminal is authenticated with Google Cloud:
   ```bash
   gcloud auth login
   gcloud config set project prj-sbx-polarisai-160925
   ```

2. Run the deployment script. It will build the Docker image locally and push it to both Google Artifact Registry and Google Container Registry (gcr.io):
   ```bash
   bash scripts/deploy.sh
   ```

   *The script pushes the image using the `latest` tag by default. If you want to version your images (recommended for production), edit `scripts/deploy.sh` and change the `TAG` variable before running.*

---

## 3. Initial Deployment to Cloud Run (Via Command Line)

Once the image is pushed, you can perform the initial deployment using the `gcloud` CLI. 

Run the following command, replacing the database values and your Gemini API key:

```bash
gcloud run deploy patient-appointment \
  --image us-central1-docker.pkg.dev/prj-sbx-polarisai-160925/patient-appointment-repo/patient-appointment:latest \
  --region us-central1 \
  --set-env-vars GEMINI_API_KEY="your_actual_gemini_key",MYSQL_HOST="your_db_host",MYSQL_USER="your_db_user",MYSQL_PASSWORD="your_db_password",MYSQL_DATABASE="patientappointment" \
  --allow-unauthenticated \
  --port 8080
```

*Note: You can also use the GCR image path if you prefer: `gcr.io/prj-sbx-polarisai-160925/patient-appointment:latest`.*

---

## 4. How to Update the Image Version (Via Cloud Run GUI)

When you make changes to your code, you will need to build a new image, push it, and then update your Cloud Run service to use it.

### Step 4.1: Build and Push the New Image
1. Modify your code.
2. (Optional but recommended) Update the `TAG` variable in `scripts/deploy.sh` (e.g., from `latest` to `v1.1`, `v1.2`, or use the Git commit hash).
3. Run `bash scripts/deploy.sh` to push the new image.

### Step 4.2: Deploy the New Image via Google Cloud Console
1. Open your web browser and navigate to the **[Google Cloud Console](https://console.cloud.google.com/)**.
2. Make sure you have the correct project selected (`prj-sbx-polarisai-160925`) in the top drop-down menu.
3. In the search bar at the top, type **"Cloud Run"** and select the Cloud Run service.
4. Click on your service name (**`patient-appointment`**) from the list.
5. Near the top of the service details page, click the **"EDIT & DEPLOY NEW REVISION"** button.
6. In the resulting form, look for the **"Container image URL"** field.
7. Click the **"SELECT"** button next to it.
8. Navigate through the Artifact Registry or Container Registry folders to find the new image tag you just pushed (e.g., `v1.1` or the new `latest` if you overwrote it). Select that image.
9. (Optional) If you need to update any environment variables (like changing the DB password or Gemini key), switch to the **"Variables & Secrets"** tab and update them there.
10. Scroll to the bottom and click the blue **"DEPLOY"** button.
11. A new revision will be created, and Cloud Run will automatically start routing traffic to your updated application!
