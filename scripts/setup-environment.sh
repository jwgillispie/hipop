#!/bin/bash

# HiPop Environment Setup Script
# This script helps set up the development environment and migrate between staging/production

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏗️  HiPop Environment Setup${NC}"
echo "============================================"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check required tools
check_requirements() {
    echo -e "${YELLOW}🔍 Checking requirements...${NC}"
    
    local missing_tools=()
    
    if ! command_exists git; then
        missing_tools+=("git")
    fi
    
    if ! command_exists flutter; then
        missing_tools+=("flutter")
    fi
    
    if ! command_exists node; then
        missing_tools+=("node")
    fi
    
    if ! command_exists npm; then
        missing_tools+=("npm")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo -e "${RED}❌ Missing required tools: ${missing_tools[*]}${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All required tools are installed${NC}"
}

# Setup Flutter project
setup_flutter() {
    echo -e "${YELLOW}📱 Setting up Flutter project...${NC}"
    
    cd hipop
    
    echo "Getting Flutter dependencies..."
    flutter pub get
    
    echo "Running Flutter doctor..."
    flutter doctor
    
    cd ..
    echo -e "${GREEN}✅ Flutter setup complete${NC}"
}

# Setup website project
setup_website() {
    echo -e "${YELLOW}🌐 Setting up website project...${NC}"
    
    cd hipop-website
    
    echo "Installing npm dependencies..."
    npm install
    
    echo "Building website..."
    npm run build
    
    cd ..
    echo -e "${GREEN}✅ Website setup complete${NC}"
}

# Migrate between environments
migrate_environment() {
    local source_env=$1
    local target_env=$2
    
    echo -e "${YELLOW}🔄 Migrating from $source_env to $target_env...${NC}"
    
    # Validate branches exist
    if ! git show-ref --verify --quiet refs/heads/$source_env; then
        echo -e "${RED}❌ Source branch '$source_env' does not exist${NC}"
        exit 1
    fi
    
    if ! git show-ref --verify --quiet refs/heads/$target_env; then
        echo -e "${RED}❌ Target branch '$target_env' does not exist${NC}"
        exit 1
    fi
    
    # Save current branch
    local current_branch=$(git branch --show-current)
    
    # Fetch latest changes
    git fetch origin
    
    # Checkout target branch and merge
    git checkout $target_env
    git pull origin $target_env
    
    echo -e "${BLUE}📋 Changes to be merged from $source_env:${NC}"
    git log --oneline $target_env..$source_env
    
    echo ""
    read -p "Continue with merge? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git merge $source_env --no-ff -m "Migrate $source_env to $target_env

🔄 Environment migration $(date '+%Y-%m-%d %H:%M:%S')
        
Merging changes from $source_env branch to $target_env.
"
        git push origin $target_env
        echo -e "${GREEN}✅ Migration complete!${NC}"
    else
        echo -e "${YELLOW}❌ Migration cancelled${NC}"
    fi
    
    # Return to original branch
    git checkout $current_branch
}

# Main menu
show_menu() {
    echo ""
    echo -e "${BLUE}📋 What would you like to do?${NC}"
    echo "1. Check requirements"
    echo "2. Setup Flutter project"
    echo "3. Setup website project"
    echo "4. Setup both projects"
    echo "5. Migrate staging → production"
    echo "6. Show current git status"
    echo "7. Exit"
    echo ""
}

# Main execution
main() {
    while true; do
        show_menu
        read -p "Choose an option (1-7): " choice
        
        case $choice in
            1)
                check_requirements
                ;;
            2)
                setup_flutter
                ;;
            3)
                setup_website
                ;;
            4)
                check_requirements
                setup_flutter
                setup_website
                ;;
            5)
                migrate_environment "staging" "production"
                ;;
            6)
                git status
                git branch -a
                ;;
            7)
                echo -e "${GREEN}👋 Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Invalid option. Please choose 1-7.${NC}"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main function
main