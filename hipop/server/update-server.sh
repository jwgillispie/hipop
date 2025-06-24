#!/bin/bash

# HiPop Places Server Update Script
# Usage: ./update-server.sh

echo "🔄 Updating HiPop Places Server..."

# Build and deploy updated server
gcloud run deploy hipop-places-server \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 3000 \
  --memory 512Mi \
  --cpu 1 \
  --max-instances 10 \
  --set-env-vars="GOOGLE_MAPS_API_KEY=AIzaSyDp17RxIsSydQqKZGBRsYtJkmGdwqnHZ84" \
  --quiet

echo "✅ Server update complete!"
echo "🔗 Service URL: https://hipop-places-server-rstsk67vja-uc.a.run.app"