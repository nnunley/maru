#!/bin/bash

# Script to reorder git history to match actual chronology
# WARNING: This will rewrite history!

echo "Creating backup branch..."
git branch backup-before-reorder

echo "Starting interactive rebase to reorder commits..."

# We need to rebase from the merge commit that brought in Nile
# The order should be:
# 1. Original v1.0 (9af80b6)
# 2. VPRI Complete v2.5 (583bc2d) 
# 3. Our development work

# First, let's create a new branch from the Nile merge point
git checkout -b chronological-timeline 9fd3c6d

# Cherry-pick v1.0 commit
echo "Adding v1.0..."
git cherry-pick 9af80b6

# Cherry-pick v2.5 commit
echo "Adding v2.5..."
git cherry-pick 583bc2d

# Now cherry-pick our development commits in order
echo "Adding development commits..."
git cherry-pick d10eb24  # Add comprehensive documentation
git cherry-pick 863f17b  # Fix C IR implementation
git cherry-pick 8f0c8a6  # Code style improvements
git cherry-pick 54f3177  # Checkpoint 1.1
git cherry-pick a339195  # Checkpoint 1.2
git cherry-pick 132faf1  # Phase 1 Complete
git cherry-pick c87b1c0  # ARM64 support
git cherry-pick 2a7a644  # Reorganize codebase
git cherry-pick ef60a8a  # Fix path references
git cherry-pick f9613e5  # Revert emit.l
git cherry-pick a7679b1  # Multi-method evaluator
git cherry-pick a2f3f63  # Unify threaded C
git cherry-pick 41f77dd  # MARU_TARGET_ARCH
git cherry-pick 081eedb  # Complete codebase cleanup
git cherry-pick d5dcfdd  # Integrate Nile
git cherry-pick 6cbe91f  # Clean up project structure

echo "Reordering complete!"
echo "Review the new history with: git log --oneline --graph"
echo "If satisfied, you can delete the old branch and rename this one."