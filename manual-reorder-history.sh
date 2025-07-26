#!/bin/bash
# Manual Git History Reorganization Script for Maru Language
# This version uses standard git commands without git-filter-repo

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Manual Maru Git History Reorganization ===${NC}"
echo -e "${YELLOW}This script will manually reorganize commits in chronological order${NC}"
echo

# Step 1: Create backup
echo -e "${GREEN}Step 1: Creating backup branch...${NC}"
git branch -f backup-before-reorder HEAD
echo -e "${GREEN}✓ Backup branch created: backup-before-reorder${NC}"

# Step 2: Identify key commits
echo -e "${GREEN}Step 2: Identifying key commits...${NC}"

# Find v1.0 commit
V1_COMMIT=$(git log --all --grep="original Maru implementation (v1.0)" --format="%H" | head -1)
echo "v1.0 commit: $V1_COMMIT"

# Find v2.5 commit
V25_COMMIT=$(git log --all --grep="Maru v2.5 VPRI release" --format="%H" | head -1)
echo "v2.5 commit: $V25_COMMIT"

# Find Nile commits
NILE_BASE=$(git log --all --grep="Initial commit" --grep="Nile" --format="%H" | tail -1)
echo "Nile base: $NILE_BASE"

# Step 3: Create chronological branch
echo -e "${GREEN}Step 3: Creating new chronological branch...${NC}"
git checkout --orphan chronological-history

# Remove all files from the index
git rm -rf . 2>/dev/null || true

# Step 4: Apply commits in chronological order
echo -e "${GREEN}Step 4: Applying commits in chronological order...${NC}"

# Function to cherry-pick with proper date
cherry_pick_with_date() {
    local commit=$1
    local date=$2
    local message=$3
    
    echo -e "${BLUE}Applying: $message${NC}"
    
    # Get the tree from the commit
    TREE=$(git rev-parse ${commit}^{tree})
    
    # Get original author info
    AUTHOR=$(git log -1 --format="%an" $commit)
    AUTHOR_EMAIL=$(git log -1 --format="%ae" $commit)
    
    # Create new commit with specified date
    GIT_AUTHOR_DATE="$date" \
    GIT_COMMITTER_DATE="$date" \
    GIT_AUTHOR_NAME="$AUTHOR" \
    GIT_AUTHOR_EMAIL="$AUTHOR_EMAIL" \
    git commit-tree $TREE -m "$message" | xargs git reset --hard
}

# Apply v1.0 (2007)
if [ -n "$V1_COMMIT" ]; then
    cherry_pick_with_date "$V1_COMMIT" "2007-01-15 10:00:00 +0000" \
        "Maru v1.0 - Original implementation by Ian Piumarta (2007)"
fi

# Apply v2.x series (2008-2010)
# Note: These commits might not exist in your history, adjust as needed
echo -e "${YELLOW}Note: v2.1-v2.4 commits may need manual identification${NC}"

# Apply v2.5 (2012)
if [ -n "$V25_COMMIT" ]; then
    cherry_pick_with_date "$V25_COMMIT" "2012-11-30 10:00:00 +0000" \
        "Import complete Maru v2.5 VPRI release (2012)"
fi

# Apply Nile commits (2012-2013)
echo -e "${GREEN}Applying Nile development commits...${NC}"
# Get Nile commits in order
NILE_COMMITS=$(git log --all --grep="Nile" --reverse --format="%H|%s" | grep -E "2012-|2013-" || true)

if [ -n "$NILE_COMMITS" ]; then
    while IFS='|' read -r commit message; do
        if [ -n "$commit" ]; then
            # Extract original date if it's a 2012/2013 commit
            ORIG_DATE=$(git log -1 --format="%ad" --date=iso $commit)
            if [[ "$ORIG_DATE" =~ 2012|2013 ]]; then
                cherry_pick_with_date "$commit" "$ORIG_DATE" "$message"
            fi
        fi
    done <<< "$NILE_COMMITS"
fi

# Apply recent development (2024-2025)
echo -e "${GREEN}Applying recent development commits...${NC}"

# Get recent commits from the archaeological-timeline branch
RECENT_COMMITS=$(git log archaeological-timeline --reverse --format="%H|%ad|%s" --date=iso | tail -20)

while IFS='|' read -r commit date message; do
    if [ -n "$commit" ] && [[ "$message" != *"v1.0"* ]] && [[ "$message" != *"v2.5"* ]]; then
        cherry_pick_with_date "$commit" "$date" "$message"
    fi
done <<< "$RECENT_COMMITS"

# Step 5: Verify the results
echo -e "${GREEN}Step 5: Verifying chronological order...${NC}"

echo "=== New chronological history (first 20 commits) ==="
git log --oneline --date=short --format="%h %ad %s" | head -20

echo
echo "=== Verification checks ==="

# Check if v1.0 is first
echo -n "v1.0 is first commit: "
FIRST=$(git log --reverse --format="%s" | head -1)
if [[ "$FIRST" == *"v1.0"* ]] || [[ "$FIRST" == *"2007"* ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

# Check chronological order
echo -n "Commits are chronologically ordered: "
DATES=$(git log --format="%at")
if echo "$DATES" | awk '{if(NR>1 && $1>prev){print "FAIL"; exit 1} prev=$1}'; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

# Step 6: Create summary
echo
echo -e "${BLUE}=== Reorganization Summary ===${NC}"
echo
echo "Original branch backed up as: backup-before-reorder"
echo "New chronological history created on: chronological-history"
echo
echo "To make this your new main branch:"
echo "  git branch -m main old-main"
echo "  git branch -m chronological-history main"
echo
echo "To restore original state:"
echo "  git checkout backup-before-reorder"
echo
echo -e "${YELLOW}Review the history carefully before replacing main!${NC}"

# Create a comparison script
cat > compare-histories.sh << 'EOF'
#!/bin/bash
# Compare old and new histories side by side

echo "=== Original History ==="
git log backup-before-reorder --oneline --graph --date=short --format="%h %ad %s" | head -20

echo
echo "=== Reorganized History ==="
git log chronological-history --oneline --graph --date=short --format="%h %ad %s" | head -20

echo
echo "=== Date Distribution ==="
echo "Original:"
git log backup-before-reorder --format="%ad" --date=short | cut -d- -f1 | sort | uniq -c

echo
echo "Reorganized:"
git log chronological-history --format="%ad" --date=short | cut -d- -f1 | sort | uniq -c
EOF

chmod +x compare-histories.sh

echo
echo "Run ./compare-histories.sh to see a side-by-side comparison"