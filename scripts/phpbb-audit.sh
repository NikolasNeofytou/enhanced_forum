#!/bin/bash
# Database Audit Script for phpBB
# Run this script to gather statistics about your phpBB installation

set -e

# Configuration
DB_HOST="localhost"
DB_USER="phpbb_user"
DB_PASS="your_password"
DB_NAME="phpbb_database"
DB_PREFIX="phpbb_"

# Output file
OUTPUT_FILE="phpbb_audit_$(date +%Y%m%d_%H%M%S).txt"

echo "phpBB Database Audit Report" > "$OUTPUT_FILE"
echo "Generated: $(date)" >> "$OUTPUT_FILE"
echo "==================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Function to run SQL query and append to output
run_query() {
    local query=$1
    local title=$2
    
    echo "$title" >> "$OUTPUT_FILE"
    echo "-------------------" >> "$OUTPUT_FILE"
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "$query" >> "$OUTPUT_FILE" 2>&1
    echo "" >> "$OUTPUT_FILE"
}

# Database version and encoding
run_query "SELECT VERSION();" "Database Version"
run_query "SHOW VARIABLES LIKE 'character_set%';" "Character Set Configuration"

# Database size
run_query "SELECT 
    table_schema as 'Database',
    SUM(data_length + index_length) / 1024 / 1024 as 'Size (MB)'
FROM information_schema.TABLES 
WHERE table_schema = '$DB_NAME'
GROUP BY table_schema;" "Database Size"

# User statistics
run_query "SELECT COUNT(*) as total_users FROM ${DB_PREFIX}users WHERE user_type != 2;" "Total Users (excluding bots)"
run_query "SELECT COUNT(DISTINCT poster_id) as active_users FROM ${DB_PREFIX}posts 
WHERE FROM_UNIXTIME(post_time) > DATE_SUB(NOW(), INTERVAL 1 YEAR);" "Active Users (posted in last year)"
run_query "SELECT COUNT(*) as inactive_users FROM ${DB_PREFIX}users u 
WHERE NOT EXISTS (SELECT 1 FROM ${DB_PREFIX}posts p WHERE p.poster_id = u.user_id)
AND u.user_type != 2;" "Inactive Users (never posted)"
run_query "SELECT COUNT(*) as banned_users FROM ${DB_PREFIX}banlist;" "Banned Users"

# Email statistics
run_query "SELECT COUNT(*) as missing_email FROM ${DB_PREFIX}users 
WHERE user_email = '' OR user_email IS NULL;" "Users with Missing Email"
run_query "SELECT COUNT(*) as invalid_email FROM ${DB_PREFIX}users 
WHERE user_email NOT LIKE '%@%.%' AND user_email != '';" "Users with Invalid Email Format"
run_query "SELECT user_email, COUNT(*) as count FROM ${DB_PREFIX}users 
WHERE user_email != '' GROUP BY user_email HAVING count > 1 LIMIT 20;" "Duplicate Emails (top 20)"

# Username statistics
run_query "SELECT COUNT(*) as special_chars FROM ${DB_PREFIX}users 
WHERE username REGEXP '[^a-zA-Z0-9_]';" "Usernames with Special Characters"
run_query "SELECT COUNT(*) as too_long FROM ${DB_PREFIX}users 
WHERE LENGTH(username) > 20;" "Usernames Longer than 20 Characters"
run_query "SELECT COUNT(*) as too_short FROM ${DB_PREFIX}users 
WHERE LENGTH(username) < 3;" "Usernames Shorter than 3 Characters"
run_query "SELECT COUNT(*) as with_spaces FROM ${DB_PREFIX}users 
WHERE username LIKE '% %';" "Usernames with Spaces"

# Content statistics
run_query "SELECT COUNT(*) as total_posts FROM ${DB_PREFIX}posts;" "Total Posts"
run_query "SELECT COUNT(*) as total_topics FROM ${DB_PREFIX}topics;" "Total Topics"
run_query "SELECT 
    FROM_UNIXTIME(MIN(post_time)) as oldest_post,
    FROM_UNIXTIME(MAX(post_time)) as newest_post
FROM ${DB_PREFIX}posts;" "Post Date Range"

# Posts by year
run_query "SELECT 
    YEAR(FROM_UNIXTIME(post_time)) as year,
    COUNT(*) as post_count
FROM ${DB_PREFIX}posts
GROUP BY YEAR(FROM_UNIXTIME(post_time))
ORDER BY year;" "Posts by Year"

# Forum structure
run_query "SELECT COUNT(*) as total_forums FROM ${DB_PREFIX}forums;" "Total Forums"
run_query "SELECT forum_id, parent_id, forum_name, forum_type, forum_posts 
FROM ${DB_PREFIX}forums 
ORDER BY parent_id, forum_id 
LIMIT 50;" "Forum Hierarchy (first 50)"

# Posts per forum (top 20)
run_query "SELECT f.forum_name, COUNT(p.post_id) as post_count
FROM ${DB_PREFIX}forums f
LEFT JOIN ${DB_PREFIX}posts p ON f.forum_id = p.forum_id
GROUP BY f.forum_id
ORDER BY post_count DESC
LIMIT 20;" "Posts per Forum (top 20)"

# Attachment statistics
run_query "SELECT 
    COUNT(*) as total_attachments,
    SUM(filesize) / 1024 / 1024 as total_size_mb
FROM ${DB_PREFIX}attachments;" "Attachment Statistics"

run_query "SELECT 
    extension,
    COUNT(*) as count,
    SUM(filesize) / 1024 / 1024 as size_mb
FROM ${DB_PREFIX}attachments
GROUP BY extension
ORDER BY count DESC
LIMIT 20;" "Attachments by File Type (top 20)"

run_query "SELECT 
    real_filename,
    filesize / 1024 / 1024 as size_mb,
    mimetype
FROM ${DB_PREFIX}attachments
WHERE filesize > 10485760
ORDER BY filesize DESC
LIMIT 10;" "Largest Attachments (>10MB, top 10)"

# Custom BBCode
run_query "SELECT bbcode_tag, bbcode_helpline FROM ${DB_PREFIX}bbcodes;" "Custom BBCode Definitions"

# Extensions (phpBB 3.1+)
run_query "SELECT ext_name, ext_active FROM ${DB_PREFIX}ext 
WHERE ext_active = 1;" "Active Extensions" 2>/dev/null || echo "Extensions table not found (phpBB 3.0)" >> "$OUTPUT_FILE"

# User groups
run_query "SELECT group_name, group_type, COUNT(ug.user_id) as member_count
FROM ${DB_PREFIX}groups g
LEFT JOIN ${DB_PREFIX}user_group ug ON g.group_id = ug.group_id
GROUP BY g.group_id
ORDER BY member_count DESC;" "User Groups and Membership"

echo "Audit complete! Results saved to $OUTPUT_FILE"
echo "Please review the file and share with migration team."
