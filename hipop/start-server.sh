#!/bin/bash

# HiPop Server Startup Script
echo "🚀 Starting HiPop Server..."

# Check if we're in the right directory
if [ ! -d "server" ]; then
    echo "❌ Server directory not found. Please run this script from the hipop root directory."
    exit 1
fi

# Navigate to server directory
cd server

# Check if dependencies are installed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚠️  Creating .env file from example..."
    cp .env.example .env
    echo "📝 Please edit server/.env with your Google Maps API key"
    echo "   Then run this script again."
    exit 1
fi

# Check if API key is set
if ! grep -q "GOOGLE_MAPS_API_KEY=AIzaSy" .env; then
    echo "⚠️  Google Maps API key not found in .env"
    echo "📝 Please edit server/.env with your API key"
    echo "   Current .env content:"
    cat .env
    exit 1
fi

# Start the server
echo "🌟 Starting server..."
echo "📊 Dashboard available at: file://$(pwd)/dashboard.html"
echo "🔗 API available at: http://localhost:3000"
echo "📝 Press Ctrl+C to stop"
echo ""

# Start with enhanced logging
node enhanced-server.js