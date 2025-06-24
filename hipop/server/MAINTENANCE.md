# HiPop Places Server Maintenance Guide

## Service Information
- **Service Name:** hipop-places-server
- **Region:** us-central1
- **Project:** hiipop-markets
- **URL:** https://hipop-places-server-rstsk67vja-uc.a.run.app

## Daily Maintenance

### Health Check
```bash
curl https://hipop-places-server-rstsk67vja-uc.a.run.app/health
```

### View Logs
```bash
gcloud run services logs read hipop-places-server --region=us-central1 --limit=50
```

### Check Service Status
```bash
gcloud run services describe hipop-places-server --region=us-central1
```

## Updates

### Deploy Code Changes
```bash
./update-server.sh
```

### Update Environment Variables
```bash
gcloud run services update hipop-places-server \
  --region=us-central1 \
  --set-env-vars="GOOGLE_MAPS_API_KEY=your-new-key"
```

### Scale Resources
```bash
gcloud run services update hipop-places-server \
  --region=us-central1 \
  --memory=256Mi \
  --cpu=0.5 \
  --max-instances=5
```

## Monitoring

### View Metrics
```bash
gcloud run services describe hipop-places-server --region=us-central1 --format="table(status.traffic[].latestRevision, status.traffic[].percent)"
```

### Traffic Split (for rolling updates)
```bash
gcloud run services update-traffic hipop-places-server \
  --region=us-central1 \
  --to-latest
```

## Cost Management

### Current Usage
```bash
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=hipop-places-server" --limit=10 --format="table(timestamp, httpRequest.requestMethod, httpRequest.status)"
```

### Set Budget Alert (in Console)
1. Go to Google Cloud Console > Billing
2. Set budget alerts for the project
3. Monitor Cloud Run costs specifically

## Troubleshooting

### Service Not Responding
1. Check logs: `gcloud run services logs read hipop-places-server --region=us-central1`
2. Check service status: `gcloud run services describe hipop-places-server --region=us-central1`
3. Redeploy if needed: `./update-server.sh`

### API Key Issues
1. Verify API key is set: `gcloud run services describe hipop-places-server --region=us-central1 | grep GOOGLE_MAPS_API_KEY`
2. Update if needed: `gcloud run services update hipop-places-server --region=us-central1 --set-env-vars="GOOGLE_MAPS_API_KEY=new-key"`

### CORS Issues
- CORS is configured in `index.js` for common localhost ports and your Firebase domains
- Update the origins array if you add new domains

## Security

### Rotate API Key
1. Generate new Google Maps API key in Google Cloud Console
2. Update service: `gcloud run services update hipop-places-server --region=us-central1 --set-env-vars="GOOGLE_MAPS_API_KEY=new-key"`
3. Test endpoints after update

### Monitor Usage
- Check Google Maps API usage in Google Cloud Console
- Set up quota alerts to prevent unexpected charges