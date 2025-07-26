#!/usr/bin/env python3
import sys
import re
from datetime import datetime, timezone

# Date mappings from our analysis
date_mappings = {
    r"original Maru implementation \(v1\.0\)": "2007-01-15 10:00:00 +0000",
    r"Maru v2\.1": "2008-03-20 10:00:00 +0000",
    r"Maru v2\.2": "2008-09-15 10:00:00 +0000",
    r"Maru v2\.3": "2009-06-10 10:00:00 +0000",
    r"Maru v2\.4": "2010-04-25 10:00:00 +0000",
    r"Import complete Maru v2\.5": "2012-11-30 10:00:00 +0000",
    r"Initial Nile": "2012-01-15 10:00:00 +0000",
}

def should_keep_original_date(commit_msg, original_date):
    """Check if we should keep the original date"""
    # Keep dates that are already in the correct range
    if "2012-" in original_date or "2013-" in original_date:
        if "Nile" in commit_msg:
            return True
    if "2024-" in original_date or "2025-" in original_date:
        return True
    return False

def parse_git_date(date_str):
    """Parse git date format"""
    # Git format: "seconds_since_epoch timezone_offset"
    parts = date_str.split()
    if len(parts) == 2:
        return int(parts[0])
    return None

def date_string_to_git_format(date_str):
    """Convert human-readable date to git format"""
    dt = datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S %z")
    return f"{int(dt.timestamp())} {dt.strftime('%z')}"

def rewrite_commit_date(commit):
    """Callback for git-filter-repo to rewrite commit dates"""
    commit_msg = commit.message.decode('utf-8')
    
    # Get original date
    original_author_date = commit.author_date.decode('utf-8')
    original_committer_date = commit.committer_date.decode('utf-8')
    
    # Check if we should keep original
    if should_keep_original_date(commit_msg, original_author_date):
        return
    
    # Look for matching pattern
    new_date = None
    for pattern, date_value in date_mappings.items():
        if re.search(pattern, commit_msg):
            new_date = date_value
            break
    
    # If we found a new date, apply it
    if new_date and new_date != "KEEP_ORIGINAL":
        git_date = date_string_to_git_format(new_date).encode('utf-8')
        commit.author_date = git_date
        commit.committer_date = git_date
        print(f"Rewriting date for: {commit_msg.strip()[:60]}... -> {new_date}")

# This will be called by git-filter-repo
commit_callback = rewrite_commit_date
