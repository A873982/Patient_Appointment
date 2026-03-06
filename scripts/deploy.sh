#!/bin/bash
# Script to build and push the Docker image to Google Artifact Registry

# Change to the parent directory to ensure build context is correct
cd "$(dirname "$0")/.."

PROJECT_ID="prj-sbx-polarisai-160925"
REGION="us-central1"
REPO="patient-appointment-repo"
IMAGE_NAME="patient-appointment"
TAG="latest" # Or use $(git rev-parse --short HEAD)

IMAGE_URI="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${IMAGE_NAME}:${TAG}"
# If the user's provided path was the exact image URI, we use it directly:
# "us-central1-docker.pkg.dev/prj-sbx-polarisai-160925/patient-appointment-repo/patient-appointment"
IMAGE_URI_USER="us-central1-docker.pkg.dev/prj-sbx-polarisai-160925/patient-appointment-repo/patient-appointment"

echo "Building Docker image ${IMAGE_URI_USER}..."
docker build -t ${IMAGE_URI_USER} .

echo "Configuring Docker to authenticate with Artifact Registry..."
# Configure docker to use gcloud credentials
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

echo "Pushing image to Artifact Registry (${IMAGE_URI_USER})..."
docker push ${IMAGE_URI_USER}

# Tag and push for GCR
GCR_IMAGE_URI="gcr.io/${PROJECT_ID}/${IMAGE_NAME}:${TAG}"
echo "Tagging image for GCR (${GCR_IMAGE_URI})..."
docker tag ${IMAGE_URI_USER} ${GCR_IMAGE_URI}

echo "Configuring Docker to authenticate with GCR..."
gcloud auth configure-docker gcr.io --quiet

echo "Pushing image to GCR (${GCR_IMAGE_URI})..."
docker push ${GCR_IMAGE_URI}

echo "Done! The image can now be deployed to Cloud Run."
echo "Deployment example:"
echo "gcloud run deploy patient-appointment --image ${IMAGE_URI_USER} \\"
echo "  --region ${REGION} \\"
echo "  --set-env-vars GEMINI_API_KEY=your_key_here,MYSQL_HOST=localhost,MYSQL_USER=root,MYSQL_PASSWORD=password,MYSQL_DATABASE=patientappointment \\"
echo "  --allow-unauthenticated"
