#!/bin/bash

# Deploy HiPop Places Server to Google Cloud Run
# Make sure you have gcloud CLI installed and authenticated

echo "🚀 Deploying HiPop Places Server to Google Cloud Run..."

# Build and deploy to Cloud Run
gcloud run deploy hipop-places-server \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --cpu 1 \
  --max-instances 10 \
  --set-env-vars="PORT=8080" \
  --quiet

echo "✅ Deployment complete!"
echo "📝 Don't forget to:"
echo "   1. Set GOOGLE_MAPS_API_KEY environment variable"
echo "   2. Update Flutter app with the deployed URL"
echo ""
echo "🔧 To set the API key:"
echo "   gcloud run services update hipop-places-server --set-env-vars=GOOGLE_MAPS_API_KEY=your-api-key --region=us-central1"