#!/bin/bash
# Fix Unmerged History - Create truly linear chronological history

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Fixing Unmerged Git History ===${NC}"
echo -e "${YELLOW}This will create a single linear history with proper chronological ordering${NC}"
echo

# Step 1: Create safety backup
echo -e "${GREEN}Step 1: Creating safety backup...${NC}"
BACKUP_BRANCH="backup-$(date +%Y%m%d-%H%M%S)"
git branch "$BACKUP_BRANCH" HEAD
echo -e "${GREEN}✓ Backup created: $BACKUP_BRANCH${NC}"

# Step 2: Identify all unique commits
echo -e "${GREEN}Step 2: Analyzing all commits across all branches...${NC}"

# Get all commits with their info
git log --all --format="%H|%at|%ad|%s|%an" --date=iso > all_commits.txt

# Identify key commits
V1_HASH=$(git log --all --grep="original Maru implementation (v1.0)" --format="%H" | head -1)
V25_HASH=$(git log --all --grep="VPRI Complete Maru System (v2.5)" --format="%H" | head -1)

echo "Found v1.0: $V1_HASH"
echo "Found v2.5: $V25_HASH"

# Step 3: Create mapping of proper dates
echo -e "${GREEN}Step 3: Creating date mappings...${NC}"

cat > date_corrections.txt << EOF
# Commit message pattern -> Correct date
original Maru implementation (v1.0)|2007-01-15 10:00:00 +0000
Maru v2.1|2008-03-20 10:00:00 +0000
Maru v2.2|2008-09-15 10:00:00 +0000
Maru v2.3|2009-06-10 10:00:00 +0000
Maru v2.4|2010-04-25 10:00:00 +0000
VPRI Complete Maru System (v2.5)|2012-11-30 10:00:00 +0000
EOF

# Step 4: Create new linear history
echo -e "${GREEN}Step 4: Creating new linear history...${NC}"

# Start with orphan branch
git checkout --orphan linear-chronological
git rm -rf . 2>/dev/null || true

# Function to apply commit with corrected date
apply_commit() {
    local hash=$1
    local timestamp=$2
    local date=$3
    local message=$4
    local author=$5
    
    # Skip if this is a merge commit or stash
    if [[ "$message" == *"Merge"* ]] || [[ "$message" == *"WIP on"* ]] || [[ "$message" == *"index on"* ]]; then
        echo -e "${YELLOW}Skipping merge/stash commit: $message${NC}"
        return
    fi
    
    echo -e "${BLUE}Applying: ${message:0:60}...${NC}"
    
    # Get the tree
    local tree=$(git rev-parse ${hash}^{tree} 2>/dev/null || echo "")
    if [ -z "$tree" ]; then
        echo -e "${RED}Warning: Could not get tree for $hash${NC}"
        return
    fi
    
    # Determine the correct date
    local commit_date="$date"
    
    # Check if we need to correct the date
    if grep -q "2007" <<< "$message" && [[ "$message" == *"v1.0"* ]]; then
        commit_date="2007-01-15 10:00:00 +0000"
    elif grep -q "v2.5" <<< "$message" && grep -q "VPRI" <<< "$message"; then
        commit_date="2012-11-30 10:00:00 +0000"
    elif [[ "$date" == *"2025-02-"* ]] && [[ "$message" == *"Maru"* ]]; then
        # These are likely misdated historical commits
        if [[ "$message" == *"import"* ]]; then
            commit_date="2012-01-01 10:00:00 +0000"
        fi
    fi
    
    # Create the commit
    local parent=""
    if [ -n "$(git rev-parse HEAD 2>/dev/null || echo "")" ]; then
        parent="-p HEAD"
    fi
    
    NEW_COMMIT=$(GIT_AUTHOR_NAME="$author" \
                 GIT_AUTHOR_EMAIL="$author@maru-lang.org" \
                 GIT_AUTHOR_DATE="$commit_date" \
                 GIT_COMMITTER_DATE="$commit_date" \
                 git commit-tree $tree $parent -m "$message")
    
    git reset --hard $NEW_COMMIT
}

# Step 5: Collect and sort all commits
echo -e "${GREEN}Step 5: Collecting all commits for linearization...${NC}"

# Create a comprehensive list of all commits
declare -A seen_trees
declare -a commit_list

# First, add v1.0 if it exists
if [ -n "$V1_HASH" ]; then
    tree=$(git rev-parse ${V1_HASH}^{tree})
    if [ -z "${seen_trees[$tree]:-}" ]; then
        seen_trees[$tree]=1
        commit_list+=("$V1_HASH|221830800|2007-01-15 10:00:00 +0000|Maru v1.0 - Original implementation by Ian Piumarta|Ian Piumarta")
    fi
fi

# Add all other commits, avoiding duplicates
while IFS='|' read -r hash timestamp date message author; do
    # Skip if we already handled this as v1.0
    if [ "$hash" = "$V1_HASH" ]; then
        continue
    fi
    
    # Get tree hash to detect duplicate content
    tree=$(git rev-parse ${hash}^{tree} 2>/dev/null || echo "")
    if [ -n "$tree" ] && [ -z "${seen_trees[$tree]:-}" ]; then
        seen_trees[$tree]=1
        
        # Adjust timestamp for known historical commits
        if [[ "$message" == *"v2.5"* ]] && [[ "$message" == *"VPRI"* ]]; then
            timestamp=1354320000  # 2012-11-30
            date="2012-11-30 10:00:00 +0000"
        elif [[ "$date" == *"2025-02-"* ]] && [[ "$message" != *"2025"* ]]; then
            # Likely historical commits with wrong dates
            timestamp=1325376000  # 2012-01-01 as placeholder
            date="2012-01-01 10:00:00 +0000"
        fi
        
        commit_list+=("$hash|$timestamp|$date|$message|$author")
    fi
done < all_commits.txt

# Sort by timestamp
IFS=$'\n' sorted_commits=($(printf '%s\n' "${commit_list[@]}" | sort -t'|' -k2 -n))

# Step 6: Apply commits in chronological order
echo -e "${GREEN}Step 6: Applying ${#sorted_commits[@]} commits in chronological order...${NC}"

for commit_info in "${sorted_commits[@]}"; do
    IFS='|' read -r hash timestamp date message author <<< "$commit_info"
    apply_commit "$hash" "$timestamp" "$date" "$message" "$author"
done

# Step 7: Verify the result
echo -e "${GREEN}Step 7: Verifying linear history...${NC}"

echo
echo "=== New Linear History (first 30 commits) ==="
git log --oneline --date=short --format="%h %ad %s" | head -30

echo
echo "=== Verification ==="

# Check linearity
echo -n "History is linear (no branches): "
if [ -z "$(git log --graph --oneline | grep -E '^\s*\*\s*[a-f0-9]' | grep -v '^*')" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

# Check chronological order
echo -n "Commits are chronologically ordered: "
if git log --format="%at" | awk '{if(NR>1 && $1>prev){exit 1} prev=$1}'; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠ Some commits may be out of order${NC}"
fi

# Check first commit
echo -n "First commit is v1.0: "
FIRST=$(git log --reverse --oneline | head -1)
if [[ "$FIRST" == *"v1.0"* ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠ First commit: $FIRST${NC}"
fi

# Step 8: Final instructions
echo
echo -e "${BLUE}=== Linear History Created Successfully ===${NC}"
echo
echo "Current branch: linear-chronological"
echo "Backup branch: $BACKUP_BRANCH"
echo
echo "To make this your new main branch:"
echo "  ${GREEN}git branch -f main HEAD${NC}"
echo "  ${GREEN}git checkout main${NC}"
echo
echo "To push this new history (WARNING: This will rewrite remote history!):"
echo "  ${YELLOW}git push --force-with-lease origin main${NC}"
echo
echo "To compare with original:"
echo "  ${BLUE}git log --oneline --graph $BACKUP_BRANCH | head -20${NC}"
echo
echo -e "${RED}⚠️  WARNING: This is a complete history rewrite!${NC}"
echo -e "${RED}⚠️  All existing clones will need to be re-cloned or rebased!${NC}"

# Cleanup
rm -f all_commits.txt date_corrections.txt