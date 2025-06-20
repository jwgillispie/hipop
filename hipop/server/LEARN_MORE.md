# 🎓 Complete Server Guide for HiPop

## 📚 Table of Contents
1. [Understanding Your Server](#understanding-your-server)
2. [Management Commands](#management-commands)  
3. [Monitoring & Debugging](#monitoring--debugging)
4. [API Endpoints](#api-endpoints)
5. [Architecture Deep Dive](#architecture-deep-dive)
6. [Security Considerations](#security-considerations)
7. [Scaling & Production](#scaling--production)
8. [Troubleshooting](#troubleshooting)

## Understanding Your Server

### What Does It Do?
Your server is a **middleware layer** that:
- 🔐 **Protects your API keys** from client exposure
- 🚀 **Proxies requests** to Google Places API
- 📊 **Monitors usage** and performance
- 🛡️ **Validates requests** before forwarding
- 📝 **Logs activity** for debugging

### Architecture Flow
```
Flutter App → Your Server → Google Places API → Your Server → Flutter App
```

## Management Commands

### Basic Commands
```bash
# Start production server
npm start

# Start development server (auto-reload)
npm run dev

# Check server status
npm run status

# Test API endpoints
npm run test

# View recent logs
npm run logs

# Monitor server in real-time
npm run monitor

# Show help for management tool
npm run manage help
```

### Advanced Management
```bash
# Use the enhanced server with full monitoring
node enhanced-server.js

# Custom management tasks
node manage.js <command>
```

## Monitoring & Debugging

### 1. Real-time Dashboard
Open `dashboard.html` in your browser for a visual monitoring interface:
- Server status and uptime
- Request statistics
- Error tracking
- System metrics
- Live logs

### 2. Log Analysis
```bash
# View logs in real-time
tail -f server.log

# Search for errors
grep "ERROR" server.log

# Count requests by type
grep "autocomplete" server.log | wc -l
```

### 3. Performance Monitoring
Check these key metrics:
- **Response times**: Should be < 1000ms
- **Error rates**: Should be < 5%
- **Memory usage**: Monitor for leaks
- **Request volume**: Plan for scaling

## API Endpoints

### 1. Health Check
```bash
GET /health
```
**Response:**
```json
{
  "status": "OK",
  "timestamp": "2025-06-18T01:00:00.000Z",
  "uptime": { "human": "2h 30m 15s" },
  "stats": { "requests": {...}, "errors": {...} },
  "server": { "memory": {...}, "version": "v18.0.0" }
}
```

### 2. Places Autocomplete
```bash
GET /api/places/autocomplete?input=atlanta
```
**Response:**
```json
{
  "predictions": [
    {
      "place_id": "ChIJjQmTaV0E9YgRC2MLmS_e_mY",
      "description": "Atlanta, GA, USA",
      "structured_formatting": {
        "main_text": "Atlanta",
        "secondary_text": "GA, USA"
      }
    }
  ]
}
```

### 3. Place Details
```bash
GET /api/places/details?place_id=ChIJjQmTaV0E9YgRC2MLmS_e_mY
```
**Response:**
```json
{
  "result": {
    "place_id": "ChIJjQmTaV0E9YgRC2MLmS_e_mY",
    "name": "Atlanta",
    "formatted_address": "Atlanta, GA, USA",
    "geometry": {
      "location": { "lat": 33.7489954, "lng": -84.3879824 }
    }
  }
}
```

### 4. Statistics (Enhanced Server)
```bash
GET /api/stats
```

### 5. Logs (Enhanced Server)
```bash
GET /api/logs
```

## Architecture Deep Dive

### Request Flow
1. **Flutter app** sends request to server
2. **Server validates** request parameters
3. **Server adds API key** and forwards to Google
4. **Google responds** with data
5. **Server filters/transforms** response
6. **Server logs** the transaction
7. **Server returns** data to Flutter app

### Key Components

#### Express.js Framework
```javascript
const app = express();          // Create web server
app.use(cors());               // Enable cross-origin requests
app.use(express.json());       // Parse JSON requests
```

#### Environment Variables
```javascript
require('dotenv').config();    // Load .env file
const apiKey = process.env.GOOGLE_MAPS_API_KEY;
```

#### HTTP Client (Axios)
```javascript
const response = await axios.get(googleUrl);  // Make API call
```

#### Error Handling
```javascript
try {
  // API call
} catch (error) {
  logger.error('Request failed', { error: error.message });
  res.status(500).json({ error: 'Internal server error' });
}
```

## Security Considerations

### 🔐 API Key Protection
- ✅ **Server-side only**: API key never exposed to client
- ✅ **Environment variables**: Stored in `.env` file
- ✅ **Git ignored**: `.env` not committed to repository

### 🛡️ Request Validation
```javascript
// Input validation
if (!input || input.length < 3) {
  return res.json({ predictions: [] });
}

// Required parameters
if (!place_id) {
  return res.status(400).json({ error: 'place_id is required' });
}
```

### 🚧 CORS Configuration
```javascript
app.use(cors());  // Currently allows all origins
// For production, specify allowed origins:
app.use(cors({ origin: ['http://localhost:3000', 'https://yourdomain.com'] }));
```

### 📝 Logging & Monitoring
- All requests logged with timestamps
- Error tracking with stack traces
- Performance metrics collected
- Security events monitored

## Scaling & Production

### Performance Optimization

#### 1. Add Caching
```javascript
const cache = new Map();
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

// Check cache before API call
const cacheKey = `autocomplete:${input}`;
const cached = cache.get(cacheKey);
if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
  return res.json(cached.data);
}
```

#### 2. Rate Limiting
```bash
npm install express-rate-limit
```
```javascript
const rateLimit = require('express-rate-limit');
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use('/api/', limiter);
```

#### 3. Request Compression
```bash
npm install compression
```
```javascript
const compression = require('compression');
app.use(compression());
```

### Deployment Options

#### 1. Local Development
```bash
npm run dev  # Development with auto-reload
```

#### 2. Production VPS/Cloud
```bash
# Install PM2 for process management
npm install -g pm2

# Start with PM2
pm2 start index.js --name hipop-server

# Monitor
pm2 status
pm2 logs hipop-server
```

#### 3. Docker Deployment
Create `Dockerfile`:
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

## Troubleshooting

### Common Issues

#### ❌ Server Won't Start
```bash
# Check if port is in use
lsof -i :3000

# Kill process using port
kill -9 $(lsof -t -i:3000)
```

#### ❌ API Key Errors
```bash
# Verify .env file exists
ls -la .env

# Check API key is set
echo $GOOGLE_MAPS_API_KEY
```

#### ❌ CORS Errors
Browser console shows CORS errors:
```javascript
// Add specific origin to CORS
app.use(cors({ origin: 'http://localhost:8080' }));
```

#### ❌ Memory Leaks
```bash
# Monitor memory usage
node --inspect enhanced-server.js
# Open chrome://inspect in Chrome
```

### Debugging Tools

#### 1. Node.js Inspector
```bash
node --inspect-brk index.js
# Open chrome://inspect in Chrome
```

#### 2. Request Tracing
```javascript
// Add detailed logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.url}`);
  next();
});
```

#### 3. Health Monitoring
```bash
# Continuous health checks
watch -n 5 'curl -s http://localhost:3000/health | jq .'
```

### Performance Tuning

#### Monitor These Metrics:
- **Response Time**: < 500ms ideal
- **Memory Usage**: < 512MB for basic server
- **Error Rate**: < 1% in production
- **CPU Usage**: < 70% average

#### Optimization Strategies:
1. **Connection Pooling**: Reuse HTTP connections
2. **Caching**: Store frequent requests
3. **Compression**: Reduce response size
4. **Load Balancing**: Multiple server instances

## Next Steps

### Immediate Improvements
1. **Add caching** for frequently requested places
2. **Implement rate limiting** to prevent abuse
3. **Add authentication** for API access
4. **Set up proper logging** with log rotation

### Advanced Features
1. **Analytics dashboard** for usage insights
2. **A/B testing** for different API configurations
3. **Automated backups** of logs and configuration
4. **Health checks** and automatic restart

### Monitoring Setup
1. **Set up alerts** for high error rates
2. **Monitor API quota** usage
3. **Track performance** trends
4. **Set up uptime monitoring**

---

## 🎯 Quick Reference

### Start Server
```bash
cd server && npm start
```

### View Dashboard
Open `dashboard.html` in browser

### Test API
```bash
curl http://localhost:3000/health
```

### Monitor Logs
```bash
npm run logs
```

### Emergency Stop
```bash
pkill -f "node index.js"
```

This comprehensive guide should help you understand, manage, and optimize your server effectively! 🚀