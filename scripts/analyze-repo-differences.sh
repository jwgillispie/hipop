#!/bin/bash

# HiPop Repository Difference Analysis Script
# Safely analyzes differences between hipop/ and hipop-staging/ with backup system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PRODUCTION_DIR="hipop"
STAGING_DIR="hipop-staging"
BACKUP_DIR="repo-analysis-backup-$(date +%Y%m%d-%H%M%S)"
REPORT_FILE="repo-analysis-report-$(date +%Y%m%d-%H%M%S).md"

echo -e "${BLUE}🔍 HiPop Repository Difference Analysis${NC}"
echo "==========================================="
echo -e "${CYAN}Production:${NC} $PRODUCTION_DIR"
echo -e "${CYAN}Staging:${NC} $STAGING_DIR"
echo -e "${CYAN}Backup:${NC} $BACKUP_DIR"
echo -e "${CYAN}Report:${NC} $REPORT_FILE"
echo ""

# Check if directories exist
check_directories() {
    if [ ! -d "$PRODUCTION_DIR" ]; then
        echo -e "${RED}❌ Production directory '$PRODUCTION_DIR' not found${NC}"
        exit 1
    fi
    
    if [ ! -d "$STAGING_DIR" ]; then
        echo -e "${RED}❌ Staging directory '$STAGING_DIR' not found${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Both directories found${NC}"
}

# Create backup directory
create_backup_structure() {
    echo -e "${YELLOW}📁 Creating backup structure...${NC}"
    mkdir -p "$BACKUP_DIR"/{production,staging,merged}
    echo -e "${GREEN}✅ Backup directory created: $BACKUP_DIR${NC}"
}

# Initialize report
init_report() {
    cat > "$REPORT_FILE" << EOF
# HiPop Repository Analysis Report
Generated: $(date)

## Summary
- **Production Directory:** $PRODUCTION_DIR
- **Staging Directory:** $STAGING_DIR  
- **Backup Directory:** $BACKUP_DIR

## Analysis Results

EOF
}

# Function to get file count and size
get_directory_stats() {
    local dir=$1
    local label=$2
    
    if [ -d "$dir" ]; then
        local file_count=$(find "$dir" -type f | wc -l | tr -d ' ')
        local dir_size=$(du -sh "$dir" 2>/dev/null | cut -f1)
        echo -e "${CYAN}$label:${NC} $file_count files, $dir_size"
        
        echo "### $label Directory Stats" >> "$REPORT_FILE"
        echo "- Files: $file_count" >> "$REPORT_FILE"
        echo "- Size: $dir_size" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
    fi
}

# Compare directory structures
analyze_structure() {
    echo -e "${YELLOW}🏗️  Analyzing directory structures...${NC}"
    
    get_directory_stats "$PRODUCTION_DIR" "Production"
    get_directory_stats "$STAGING_DIR" "Staging"
    
    echo "## Directory Structure Differences" >> "$REPORT_FILE"
    
    # Files only in production
    echo -e "${PURPLE}📄 Files only in production:${NC}"
    echo "### Files Only in Production" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
    diff -r --brief "$PRODUCTION_DIR" "$STAGING_DIR" 2>/dev/null | grep "Only in $PRODUCTION_DIR" | tee -a "$REPORT_FILE" | head -20
    echo '```' >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # Files only in staging
    echo -e "${PURPLE}📄 Files only in staging:${NC}"
    echo "### Files Only in Staging" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
    diff -r --brief "$PRODUCTION_DIR" "$STAGING_DIR" 2>/dev/null | grep "Only in $STAGING_DIR" | tee -a "$REPORT_FILE" | head -20
    echo '```' >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
}

# Analyze lib folder specifically
analyze_lib_folder() {
    echo -e "${YELLOW}📚 Analyzing lib folder differences...${NC}"
    
    local prod_lib="$PRODUCTION_DIR/lib"
    local staging_lib="$STAGING_DIR/lib"
    
    echo "## Lib Folder Analysis" >> "$REPORT_FILE"
    
    if [ -d "$prod_lib" ] && [ -d "$staging_lib" ]; then
        echo -e "${CYAN}Comparing lib folders...${NC}"
        
        # Get lib-specific stats
        local prod_dart_files=$(find "$prod_lib" -name "*.dart" | wc -l | tr -d ' ')
        local staging_dart_files=$(find "$staging_lib" -name "*.dart" | wc -l | tr -d ' ')
        
        echo -e "${CYAN}Production lib:${NC} $prod_dart_files Dart files"
        echo -e "${CYAN}Staging lib:${NC} $staging_dart_files Dart files"
        
        echo "- Production lib: $prod_dart_files Dart files" >> "$REPORT_FILE"
        echo "- Staging lib: $staging_dart_files Dart files" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        
        # Find different files in lib
        echo "### Modified Files in lib/" >> "$REPORT_FILE"
        echo '```' >> "$REPORT_FILE"
        diff -r --brief "$prod_lib" "$staging_lib" 2>/dev/null | grep "differ" | while read line; do
            echo "$line" | tee -a "$REPORT_FILE"
            
            # Extract file paths
            prod_file=$(echo "$line" | awk '{print $2}')
            staging_file=$(echo "$line" | awk '{print $4}')
            
            # Create backups of different files
            if [ -f "$prod_file" ]; then
                local rel_path=${prod_file#$PRODUCTION_DIR/}
                local backup_prod_file="$BACKUP_DIR/production/$rel_path"
                mkdir -p "$(dirname "$backup_prod_file")"
                cp "$prod_file" "$backup_prod_file"
            fi
            
            if [ -f "$staging_file" ]; then
                local rel_path=${staging_file#$STAGING_DIR/}
                local backup_staging_file="$BACKUP_DIR/staging/$rel_path"
                mkdir -p "$(dirname "$backup_staging_file")"
                cp "$staging_file" "$backup_staging_file"
            fi
        done
        echo '```' >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        
        # New files in staging lib
        echo "### New Files in Staging lib/" >> "$REPORT_FILE"
        echo '```' >> "$REPORT_FILE"
        find "$staging_lib" -name "*.dart" | while read staging_file; do
            local rel_path=${staging_file#$STAGING_DIR/}
            local prod_file="$PRODUCTION_DIR/$rel_path"
            
            if [ ! -f "$prod_file" ]; then
                echo "NEW: $rel_path" | tee -a "$REPORT_FILE"
                
                # Backup new file
                local backup_file="$BACKUP_DIR/staging/$rel_path"
                mkdir -p "$(dirname "$backup_file")"
                cp "$staging_file" "$backup_file"
            fi
        done
        echo '```' >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        
    else
        echo -e "${RED}❌ One or both lib directories not found${NC}"
        echo "❌ One or both lib directories not found" >> "$REPORT_FILE"
    fi
}

# Analyze specific critical files
analyze_critical_files() {
    echo -e "${YELLOW}⚠️  Analyzing critical files...${NC}"
    
    local critical_files=(
        "pubspec.yaml"
        "lib/main.dart"
        "lib/firebase_options.dart"
        "android/app/build.gradle.kts"
        "ios/Runner/Info.plist"
        "firebase.json"
        ".firebaserc"
    )
    
    echo "## Critical Files Analysis" >> "$REPORT_FILE"
    
    for file in "${critical_files[@]}"; do
        local prod_file="$PRODUCTION_DIR/$file"
        local staging_file="$STAGING_DIR/$file"
        
        echo -e "${CYAN}Checking: $file${NC}"
        
        if [ -f "$prod_file" ] && [ -f "$staging_file" ]; then
            if ! diff -q "$prod_file" "$staging_file" >/dev/null 2>&1; then
                echo -e "${YELLOW}  ⚠️  DIFFERENT${NC}"
                echo "### $file - DIFFERENT" >> "$REPORT_FILE"
                
                # Create backups
                mkdir -p "$BACKUP_DIR/production/$(dirname "$file")"
                mkdir -p "$BACKUP_DIR/staging/$(dirname "$file")"
                cp "$prod_file" "$BACKUP_DIR/production/$file"
                cp "$staging_file" "$BACKUP_DIR/staging/$file"
                
                # Show diff preview
                echo '```diff' >> "$REPORT_FILE"
                diff -u "$prod_file" "$staging_file" | head -20 >> "$REPORT_FILE" 2>/dev/null || echo "Binary file or diff error" >> "$REPORT_FILE"
                echo '```' >> "$REPORT_FILE"
                echo "" >> "$REPORT_FILE"
            else
                echo -e "${GREEN}  ✅ IDENTICAL${NC}"
                echo "### $file - IDENTICAL" >> "$REPORT_FILE"
                echo "" >> "$REPORT_FILE"
            fi
        elif [ -f "$prod_file" ]; then
            echo -e "${RED}  ❌ ONLY IN PRODUCTION${NC}"
            echo "### $file - ONLY IN PRODUCTION" >> "$REPORT_FILE"
            cp "$prod_file" "$BACKUP_DIR/production/$file"
        elif [ -f "$staging_file" ]; then
            echo -e "${BLUE}  ➕ ONLY IN STAGING${NC}"
            echo "### $file - ONLY IN STAGING" >> "$REPORT_FILE"
            cp "$staging_file" "$BACKUP_DIR/staging/$file"
        else
            echo -e "${PURPLE}  ❓ NOT FOUND IN EITHER${NC}"
            echo "### $file - NOT FOUND" >> "$REPORT_FILE"
        fi
        echo "" >> "$REPORT_FILE"
    done
}

# Generate merge recommendations
generate_recommendations() {
    echo -e "${YELLOW}💡 Generating merge recommendations...${NC}"
    
    cat >> "$REPORT_FILE" << EOF

## Merge Recommendations

### ⚠️ IMPORTANT: Always backup before merging!

### Files to Review Carefully:
1. **lib/main.dart** - Core application entry point
2. **lib/firebase_options.dart** - Firebase configuration
3. **pubspec.yaml** - Dependencies and app configuration
4. **android/app/build.gradle.kts** - Android build configuration

### Recommended Merge Strategy:
1. **Backup Current State** (✅ Done - see $BACKUP_DIR)
2. **Review Each Different File** individually
3. **Test Critical Paths** after each merge
4. **Merge Non-Breaking Changes** first
5. **Handle Breaking Changes** in separate commits

### Safe Merge Commands:
\`\`\`bash
# To merge specific files from staging:
cp $STAGING_DIR/path/to/file $PRODUCTION_DIR/path/to/file

# To restore from backup if needed:
cp $BACKUP_DIR/production/path/to/file $PRODUCTION_DIR/path/to/file
cp $BACKUP_DIR/staging/path/to/file $STAGING_DIR/path/to/file
\`\`\`

### Next Steps:
1. Review this report carefully
2. Test the application in both environments
3. Use the backup files to safely merge changes
4. Commit changes incrementally with good commit messages

EOF
}

# Create interactive merge helper
create_merge_helper() {
    local helper_script="$BACKUP_DIR/interactive-merge-helper.sh"
    
    cat > "$helper_script" << 'EOF'
#!/bin/bash

# Interactive Merge Helper - Generated by analyze-repo-differences.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔀 Interactive Merge Helper${NC}"
echo "================================"

# Get the backup directory (current directory)
BACKUP_DIR="$(pwd)"
PRODUCTION_DIR="../../hipop"
STAGING_DIR="../../hipop-staging"

show_file_diff() {
    local file=$1
    local prod_file="production/$file"
    local staging_file="staging/$file"
    
    echo -e "${YELLOW}📄 File: $file${NC}"
    
    if [ -f "$prod_file" ] && [ -f "$staging_file" ]; then
        echo -e "${CYAN}Differences:${NC}"
        diff -u "$prod_file" "$staging_file" | head -30
    elif [ -f "$prod_file" ]; then
        echo -e "${RED}Only in production${NC}"
    elif [ -f "$staging_file" ]; then
        echo -e "${BLUE}Only in staging${NC}"
    fi
    
    echo ""
    echo "Options:"
    echo "1. Use production version"
    echo "2. Use staging version" 
    echo "3. Skip this file"
    echo "4. Open both files for manual merge"
    echo ""
    
    read -p "Choose (1-4): " choice
    
    case $choice in
        1)
            if [ -f "$prod_file" ]; then
                cp "$prod_file" "$PRODUCTION_DIR/$file"
                echo -e "${GREEN}✅ Used production version${NC}"
            fi
            ;;
        2)
            if [ -f "$staging_file" ]; then
                cp "$staging_file" "$PRODUCTION_DIR/$file"
                echo -e "${GREEN}✅ Used staging version${NC}"
            fi
            ;;
        3)
            echo -e "${YELLOW}⏭️ Skipped${NC}"
            ;;
        4)
            if command -v code >/dev/null 2>&1; then
                code "$prod_file" "$staging_file"
            elif command -v nano >/dev/null 2>&1; then
                nano "$prod_file"
                nano "$staging_file"
            else
                echo "Please manually compare:"
                echo "Production: $BACKUP_DIR/$prod_file"
                echo "Staging: $BACKUP_DIR/$staging_file"
            fi
            ;;
    esac
    
    echo ""
}

# Find all different files
find production -type f -name "*.dart" | while read prod_file; do
    rel_path=${prod_file#production/}
    staging_file="staging/$rel_path"
    
    if [ -f "$staging_file" ]; then
        if ! diff -q "$prod_file" "$staging_file" >/dev/null 2>&1; then
            show_file_diff "$rel_path"
        fi
    fi
done

echo -e "${GREEN}🎉 Interactive merge complete!${NC}"
echo "Don't forget to test your application and commit your changes."
EOF

    chmod +x "$helper_script"
    echo -e "${GREEN}✅ Created interactive merge helper: $helper_script${NC}"
}

# Main execution
main() {
    check_directories
    create_backup_structure
    init_report
    
    echo -e "${BLUE}Starting comprehensive analysis...${NC}"
    echo ""
    
    analyze_structure
    analyze_lib_folder
    analyze_critical_files
    generate_recommendations
    create_merge_helper
    
    echo ""
    echo -e "${GREEN}🎉 Analysis Complete!${NC}"
    echo "==========================================="
    echo -e "${CYAN}📊 Report:${NC} $REPORT_FILE"
    echo -e "${CYAN}💾 Backups:${NC} $BACKUP_DIR"
    echo -e "${CYAN}🔀 Helper:${NC} $BACKUP_DIR/interactive-merge-helper.sh"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Review the analysis report"
    echo "2. Check the backup files"
    echo "3. Use the interactive merge helper for safe merging"
    echo ""
    echo -e "${RED}⚠️  ALWAYS test your application after merging!${NC}"
}

# Run main function
main