#!/bin/bash

# Simple HiPop Environment Difference Checker
# Shows differences between production (hipop/) and staging (hipop-staging/)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

PRODUCTION_DIR="hipop"
STAGING_DIR="hipop-staging"

echo -e "${BLUE}🔍 HiPop Environment Differences${NC}"
echo "================================="
echo -e "${CYAN}Production:${NC} $PRODUCTION_DIR"
echo -e "${CYAN}Staging:${NC} $STAGING_DIR"
echo ""

# Check if directories exist
if [ ! -d "$PRODUCTION_DIR" ] || [ ! -d "$STAGING_DIR" ]; then
    echo -e "${RED}❌ One or both directories not found${NC}"
    exit 1
fi

# Get basic stats
echo -e "${YELLOW}📊 Directory Stats:${NC}"
prod_files=$(find "$PRODUCTION_DIR" -type f | wc -l | tr -d ' ')
staging_files=$(find "$STAGING_DIR" -type f | wc -l | tr -d ' ')
prod_size=$(du -sh "$PRODUCTION_DIR" 2>/dev/null | cut -f1)
staging_size=$(du -sh "$STAGING_DIR" 2>/dev/null | cut -f1)

echo -e "  Production: $prod_files files ($prod_size)"
echo -e "  Staging: $staging_files files ($staging_size)"
echo ""

# Show lib folder specific differences
echo -e "${YELLOW}📚 Dart Files in lib/ Folder:${NC}"
if [ -d "$PRODUCTION_DIR/lib" ] && [ -d "$STAGING_DIR/lib" ]; then
    prod_dart=$(find "$PRODUCTION_DIR/lib" -name "*.dart" | wc -l | tr -d ' ')
    staging_dart=$(find "$STAGING_DIR/lib" -name "*.dart" | wc -l | tr -d ' ')
    echo -e "  Production: $prod_dart Dart files"
    echo -e "  Staging: $staging_dart Dart files"
    echo ""
    
    # Show different Dart files
    echo -e "${PURPLE}🔄 Different Dart Files in lib/:${NC}"
    diff -r --brief "$PRODUCTION_DIR/lib" "$STAGING_DIR/lib" 2>/dev/null | grep "\.dart" | grep "differ" | while read line; do
        file_path=$(echo "$line" | awk '{print $2}' | sed "s|$PRODUCTION_DIR/||")
        echo -e "  ${YELLOW}📄${NC} $file_path"
    done
    echo ""
fi

# Check critical files
echo -e "${YELLOW}⚠️  Critical Files Status:${NC}"
critical_files=("pubspec.yaml" "lib/main.dart" "lib/firebase_options.dart" "android/app/build.gradle.kts" "firebase.json" ".firebaserc")

for file in "${critical_files[@]}"; do
    prod_file="$PRODUCTION_DIR/$file"
    staging_file="$STAGING_DIR/$file"
    
    if [ -f "$prod_file" ] && [ -f "$staging_file" ]; then
        if ! diff -q "$prod_file" "$staging_file" >/dev/null 2>&1; then
            echo -e "  ${RED}❌${NC} $file - DIFFERENT"
        else
            echo -e "  ${GREEN}✅${NC} $file - IDENTICAL"
        fi
    elif [ -f "$prod_file" ]; then
        echo -e "  ${YELLOW}⚠️${NC} $file - ONLY IN PRODUCTION"
    elif [ -f "$staging_file" ]; then
        echo -e "  ${BLUE}➕${NC} $file - ONLY IN STAGING"
    else
        echo -e "  ${PURPLE}❓${NC} $file - NOT FOUND"
    fi
done
echo ""

# Show files only in staging (new features)
echo -e "${YELLOW}➕ New Files in Staging:${NC}"
new_count=0
find "$STAGING_DIR" -name "*.dart" | while read staging_file; do
    rel_path=${staging_file#$STAGING_DIR/}
    prod_file="$PRODUCTION_DIR/$rel_path"
    
    if [ ! -f "$prod_file" ]; then
        echo -e "  ${GREEN}+${NC} $rel_path"
        new_count=$((new_count + 1))
    fi
done

if [ $new_count -eq 0 ]; then
    echo -e "  ${CYAN}No new Dart files found${NC}"
fi
echo ""

# Show files only in production (removed from staging)
echo -e "${YELLOW}➖ Files Removed from Staging:${NC}"
removed_count=0
find "$PRODUCTION_DIR" -name "*.dart" | while read prod_file; do
    rel_path=${prod_file#$PRODUCTION_DIR/}
    staging_file="$STAGING_DIR/$rel_path"
    
    if [ ! -f "$staging_file" ]; then
        echo -e "  ${RED}-${NC} $rel_path"
        removed_count=$((removed_count + 1))
    fi
done

if [ $removed_count -eq 0 ]; then
    echo -e "  ${CYAN}No files removed from staging${NC}"
fi
echo ""

# Quick summary
different_files=$(diff -r --brief "$PRODUCTION_DIR" "$STAGING_DIR" 2>/dev/null | grep -c "differ" || echo "0")
echo -e "${BLUE}📋 Summary:${NC}"
echo -e "  ${CYAN}Different files:${NC} $different_files"
echo -e "  ${CYAN}Focus areas:${NC} lib/ folder, critical config files"
echo ""
echo -e "${GREEN}💡 Next steps:${NC}"
echo -e "  1. Review different critical files first"
echo -e "  2. Check lib/ folder changes for new features"
echo -e "  3. Use GitHub workflow or manual sync as needed"
echo -e "  4. Test thoroughly after any changes"