#!/bin/bash

# HiPop Staging to Production Merge Script
# This script safely merges changes from staging to production

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 HiPop: Staging to Production Merge${NC}"
echo "=================================================="

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Not in a git repository${NC}"
    exit 1
fi

# Ensure we're on the main branch initially
echo -e "${YELLOW}📍 Checking current branch...${NC}"
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

# Fetch latest changes
echo -e "${YELLOW}📥 Fetching latest changes...${NC}"
git fetch origin

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo -e "${RED}❌ Error: You have uncommitted changes. Please commit or stash them first.${NC}"
    git status --short
    exit 1
fi

# Function to checkout branch safely
checkout_branch() {
    local branch=$1
    echo -e "${YELLOW}🔄 Switching to $branch branch...${NC}"
    git checkout $branch
    git pull origin $branch
}

# Checkout staging and get latest
checkout_branch "staging"

# Show recent staging commits
echo -e "${BLUE}📋 Recent commits in staging:${NC}"
git log --oneline -10

# Confirm merge
echo ""
echo -e "${YELLOW}⚠️  Ready to merge staging into production.${NC}"
echo -e "${YELLOW}   This will deploy the above changes to production.${NC}"
echo ""
read -p "Do you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Merge cancelled by user${NC}"
    exit 1
fi

# Checkout production and merge
checkout_branch "production"

echo -e "${YELLOW}🔀 Merging staging into production...${NC}"
if git merge staging --no-ff -m "Deploy staging to production

🚀 Production deployment $(date '+%Y-%m-%d %H:%M:%S')

Merging latest changes from staging branch to production.
"; then
    echo -e "${GREEN}✅ Merge successful!${NC}"
else
    echo -e "${RED}❌ Merge failed! Please resolve conflicts manually.${NC}"
    exit 1
fi

# Push to production
echo -e "${YELLOW}📤 Pushing to production...${NC}"
if git push origin production; then
    echo -e "${GREEN}✅ Successfully pushed to production!${NC}"
else
    echo -e "${RED}❌ Failed to push to production${NC}"
    exit 1
fi

# Show deployment summary
echo ""
echo -e "${GREEN}🎉 DEPLOYMENT COMPLETE!${NC}"
echo "=================================================="
echo -e "${BLUE}Branch:${NC} staging → production"
echo -e "${BLUE}Time:${NC} $(date)"
echo -e "${BLUE}Commit:${NC} $(git rev-parse HEAD)"
echo ""
echo -e "${BLUE}📋 Deployed changes:${NC}"
git log --oneline production^..production

# Return to original branch
if [ "$CURRENT_BRANCH" != "production" ]; then
    echo -e "${YELLOW}🔄 Returning to $CURRENT_BRANCH branch...${NC}"
    git checkout $CURRENT_BRANCH
fi

echo ""
echo -e "${GREEN}✨ Ready for production! Monitor your deployment and test thoroughly.${NC}"