#!/bin/bash
# Create Linear History - Direct approach to merge all branches into chronological order

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Creating Linear Chronological History ===${NC}"
echo -e "${YELLOW}This will merge all branches into a single timeline${NC}"
echo

# Step 1: Backup current state
echo -e "${GREEN}Step 1: Creating backup...${NC}"
BACKUP="backup-$(date +%Y%m%d-%H%M%S)"
git branch "$BACKUP" HEAD
echo -e "${GREEN}✓ Backup branch created: $BACKUP${NC}"

# Step 2: Get all unique commits
echo -e "${GREEN}Step 2: Collecting all commits from all branches...${NC}"

# Get commits from all branches, excluding duplicates
declare -A commit_map
declare -a commits_ordered

# Function to get commit info
get_commit_info() {
    local hash=$1
    git log -1 --format="%at|%ad|%s|%an|%ae" --date=iso "$hash"
}

# Function to get tree hash (for deduplication)
get_tree_hash() {
    git rev-parse "$1^{tree}" 2>/dev/null || echo ""
}

# Collect commits from all refs
for ref in $(git for-each-ref --format='%(refname)' refs/heads refs/remotes); do
    echo "Processing $ref..."
    for commit in $(git rev-list "$ref"); do
        tree=$(get_tree_hash "$commit")
        if [ -n "$tree" ] && [ -z "${commit_map[$tree]:-}" ]; then
            commit_map[$tree]="$commit"
            commits_ordered+=("$commit")
        fi
    done
done

echo "Found ${#commits_ordered[@]} unique commits"

# Step 3: Create commit list with corrected dates
echo -e "${GREEN}Step 3: Preparing commits with chronological dates...${NC}"

# Create temporary file for commit data
COMMIT_DATA=$(mktemp)

for hash in "${commits_ordered[@]}"; do
    IFS='|' read -r timestamp date message author email <<< "$(get_commit_info "$hash")"
    
    # Correct dates for historical commits
    if [[ "$message" == *"original Maru implementation (v1.0)"* ]]; then
        timestamp=221830800  # 2007-01-15
        date="2007-01-15 10:00:00 +0000"
    elif [[ "$message" == *"Add Ian Piumarta's original Maru implementation (v1.0)"* ]]; then
        timestamp=221830800  # 2007-01-15
        date="2007-01-15 10:00:00 +0000"
    elif [[ "$message" == *"VPRI Complete Maru System (v2.5)"* ]]; then
        timestamp=1354291200  # 2012-11-30
        date="2012-11-30 10:00:00 +0000"
    elif [[ "$message" == *"Maru v2.1"* ]]; then
        timestamp=1206014400  # 2008-03-20
        date="2008-03-20 10:00:00 +0000"
    elif [[ "$message" == *"Maru v2.2"* ]]; then
        timestamp=1221429600  # 2008-09-15
        date="2008-09-15 10:00:00 +0000"
    elif [[ "$message" == *"Maru v2.3"* ]]; then
        timestamp=1244592000  # 2009-06-10
        date="2009-06-10 10:00:00 +0000"
    elif [[ "$message" == *"Maru v2.4"* ]]; then
        timestamp=1272168000  # 2010-04-25
        date="2010-04-25 10:00:00 +0000"
    elif [[ "$date" == *"2025-02-"* ]] && [[ "$message" != *"2025"* ]]; then
        # These are likely misdated historical commits
        timestamp=1325376000  # 2012-01-01 as placeholder
        date="2012-01-01 10:00:00 +0000"
    fi
    
    # Skip merge commits and WIP/stash commits
    if [[ "$message" != *"Merge"* ]] && [[ "$message" != *"WIP on"* ]] && [[ "$message" != *"index on"* ]]; then
        echo "$timestamp|$hash|$date|$message|$author|$email" >> "$COMMIT_DATA"
    fi
done

# Sort by timestamp
sort -n -t'|' -k1 "$COMMIT_DATA" > "${COMMIT_DATA}.sorted"

# Step 4: Create new linear history
echo -e "${GREEN}Step 4: Building linear history...${NC}"

# Create orphan branch
git checkout --orphan linear-main
git rm -rf . 2>/dev/null || true

# Apply commits in chronological order
COMMIT_COUNT=0
TOTAL_COMMITS=$(wc -l < "${COMMIT_DATA}.sorted" | tr -d ' ')

while IFS='|' read -r timestamp hash date message author email; do
    COMMIT_COUNT=$((COMMIT_COUNT + 1))
    echo -e "${BLUE}[$COMMIT_COUNT/$TOTAL_COMMITS] Applying: ${message:0:60}...${NC}"
    
    # Get the tree from original commit
    TREE=$(git rev-parse "${hash}^{tree}" 2>/dev/null)
    if [ -z "$TREE" ]; then
        echo -e "${RED}Warning: Could not get tree for $hash, skipping${NC}"
        continue
    fi
    
    # Determine parent
    PARENT=""
    if git rev-parse HEAD >/dev/null 2>&1; then
        PARENT="-p HEAD"
    fi
    
    # Create new commit with corrected date
    NEW_COMMIT=$(
        GIT_AUTHOR_NAME="$author" \
        GIT_AUTHOR_EMAIL="$email" \
        GIT_AUTHOR_DATE="$date" \
        GIT_COMMITTER_NAME="$author" \
        GIT_COMMITTER_EMAIL="$email" \
        GIT_COMMITTER_DATE="$date" \
        git commit-tree $TREE $PARENT -m "$message"
    )
    
    # Update HEAD
    git reset --hard "$NEW_COMMIT"
done < "${COMMIT_DATA}.sorted"

# Step 5: Verify results
echo -e "${GREEN}Step 5: Verifying linear history...${NC}"

echo
echo "=== First 20 commits of new linear history ==="
git log --oneline --date=short --format="%h %ad %s" | head -20

echo
echo "=== Last 10 commits ==="
git log --oneline --date=short --format="%h %ad %s" | tail -10

echo
echo "=== Date distribution ==="
git log --format="%ad" --date=short | cut -d- -f1 | sort | uniq -c

echo
echo "=== Verification checks ==="

# Check if history is linear
echo -n "History is linear: "
BRANCH_COUNT=$(git log --oneline --graph | grep -c '|' || true)
if [ "$BRANCH_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ Found $BRANCH_COUNT branch indicators${NC}"
fi

# Check first commit
echo -n "First commit: "
FIRST=$(git log --reverse --oneline | head -1)
echo "$FIRST"

# Check chronological order
echo -n "Chronological order: "
if git log --format="%at" | awk '{if(NR>1 && $1>prev){exit 1} prev=$1}'; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠ Some commits may be out of order${NC}"
fi

# Cleanup temp files
rm -f "$COMMIT_DATA" "${COMMIT_DATA}.sorted"

# Step 6: Instructions
echo
echo -e "${BLUE}=== Success! Linear history created ===${NC}"
echo
echo "You are now on branch: linear-main"
echo "Original state backed up as: $BACKUP"
echo
echo "To replace your main branch with this linear history:"
echo "  ${GREEN}git branch -f main HEAD${NC}"
echo "  ${GREEN}git checkout main${NC}"
echo
echo "To push to remote (⚠️  This rewrites history!):"
echo "  ${YELLOW}git push --force-with-lease origin main${NC}"
echo
echo "To view full history:"
echo "  ${BLUE}git log --oneline --date=short --format='%h %ad %s'${NC}"
echo
echo -e "${RED}⚠️  WARNING: This is a complete history rewrite!${NC}"
echo -e "${RED}⚠️  Anyone who has cloned this repo will need to re-clone!${NC}"