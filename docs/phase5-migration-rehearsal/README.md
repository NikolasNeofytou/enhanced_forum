# Phase 5: Migration Rehearsal Loop

## Objective

Run multiple import iterations until the output is correct and validated.

## Overview

**You will NOT get migration right on the first try.** Plan for 5-10 rehearsal runs before production cutover.

**Each iteration:**
1. Extract source data (phpBB)
2. Run importer on staging Discourse
3. Validate results
4. Document issues
5. Fix issues (patch scripts)
6. Destroy staging data
7. Repeat

**Stop when:** All validation checks pass, team is confident

---

## The Official phpBB3 Importer

### Documentation

**Primary resource:** [Importing from phpBB3 - Discourse Meta](https://meta.discourse.org/t/importing-from-phpbb3/31201)

**Importer source code:** [discourse/script/import_scripts/phpbb3](https://github.com/discourse/discourse/tree/main/script/import_scripts/phpbb3)

### What It Migrates

**Included:**
- ✅ Users (username, email, join date, post count)
- ✅ Categories (forums → categories)
- ✅ Topics (threads)
- ✅ Posts (replies)
- ✅ Attachments (files)
- ✅ Private messages (optional)
- ✅ Polls (basic support)
- ✅ Sticky/announcement status
- ✅ Closed/locked topics

**Not included (requires custom work):**
- ❌ BBCode beyond standard (custom BBCode)
- ❌ phpBB-specific extensions
- ❌ Custom user fields (may require custom import)
- ❌ Complex permissions (need manual setup)

---

## 5.1: Extract and Stage Source Data

### Prerequisites

**On phpBB server:**
- [ ] Database access (MySQL/MariaDB)
- [ ] File system access (attachments)
- [ ] Sufficient disk space for exports

**On migration workstation:**
- [ ] Database dump file
- [ ] Attachments archive
- [ ] Network access to Discourse staging

### Step 1: Database Backup

**Create full database dump:**

```bash
# On phpBB server or database server
mysqldump -u username -p \
  --single-transaction \
  --routines \
  --triggers \
  database_name > phpbb_backup_$(date +%Y%m%d).sql

# Compress for transfer
gzip phpbb_backup_$(date +%Y%m%d).sql
```

**Verify dump:**
```bash
# Check file size
ls -lh phpbb_backup_*.sql.gz

# Quick check of content
zcat phpbb_backup_*.sql.gz | head -100
```

### Step 2: Attachments Backup

**Locate attachments:**
- Default location: `phpBB_root/files/`
- Check: Admin CP → Attachment settings → Upload directory

**Create archive:**

```bash
# On phpBB server
cd /path/to/phpbb
tar -czf phpbb_attachments_$(date +%Y%m%d).tar.gz files/

# Alternative: just the files directory
tar -czf phpbb_attachments_$(date +%Y%m%d).tar.gz -C files .
```

**Verify archive:**
```bash
# Check file count
tar -tzf phpbb_attachments_*.tar.gz | wc -l

# Check size
ls -lh phpbb_attachments_*.tar.gz
```

### Step 3: Transfer to Migration Environment

**Copy files to Discourse staging server:**

```bash
# Using scp
scp phpbb_backup_*.sql.gz root@staging-discourse:/var/discourse/shared/standalone/import/
scp phpbb_attachments_*.tar.gz root@staging-discourse:/var/discourse/shared/standalone/import/

# Or using rsync
rsync -avz --progress phpbb_backup_*.sql.gz root@staging-discourse:/var/discourse/shared/standalone/import/
```

### Step 4: Extract Files on Staging

**On Discourse staging server:**

```bash
cd /var/discourse/shared/standalone/import/

# Extract database dump
gunzip phpbb_backup_*.sql.gz

# Extract attachments
mkdir -p phpbb_files
tar -xzf phpbb_attachments_*.tar.gz -C phpbb_files/
```

### Step 5: Restore Database to Temporary DB

**Create import database:**

```bash
# Enter Discourse container
cd /var/discourse
./launcher enter app

# Inside container, create database
sudo -u postgres createdb phpbb_import

# Import data
sudo -u postgres psql phpbb_import < /shared/import/phpbb_backup_*.sql

# Or if dump is MySQL format:
# You may need to use MySQL client or convert to PostgreSQL
# Most phpBB uses MySQL, but Discourse uses PostgreSQL
# Importer can connect directly to MySQL database
```

**Note:** The importer can connect directly to the original MySQL database or a MySQL dump restored to a temporary MySQL instance.

### Character Encoding Verification

**Critical for Greek content:**

```sql
-- Check phpBB database encoding
SHOW VARIABLES LIKE 'character_set%';

-- Check a sample post for Greek characters
SELECT post_text FROM phpbb_posts WHERE post_id = 1;
```

**If encoding issues:**
- Ensure dump was created with `--default-character-set=utf8mb4`
- Verify phpBB database is UTF-8
- May need to convert: `iconv -f ISO-8859-7 -t UTF-8`

---

## 5.2: Run the Importer in Staging

### Importer Setup

**On staging Discourse server:**

```bash
# Enter Discourse container
cd /var/discourse
./launcher enter app

# Navigate to import scripts
cd /var/www/discourse/script/import_scripts
```

### Configure Importer

**Create settings file:**

```bash
cd /var/www/discourse/script/import_scripts/phpbb3
cp settings.yml.example settings.yml
nano settings.yml
```

**settings.yml template:**

```yaml
database:
  type: mysql  # or postgresql if you converted
  host: localhost  # or remote MySQL server IP
  port: 3306
  username: root
  password: your_password
  database: phpbb_import  # or your phpBB database name
  prefix: phpbb_  # phpBB table prefix, usually phpbb_

import:
  # Categories: Map phpBB forum IDs to Discourse category IDs
  # Create categories in Discourse first, note their IDs
  category_mappings:
    1: 5   # phpBB forum 1 → Discourse category 5
    2: 6   # phpBB forum 2 → Discourse category 6
    # Add all your mappings from Phase 4

  # Attachments
  attachment_directory: /shared/import/phpbb_files

  # Import options
  import_private_messages: true
  import_polls: true
  import_avatars: true

  # User handling
  # If a user's email is invalid or missing, what to do?
  # Options: skip, placeholder, generate
  invalid_email_strategy: placeholder  # user_123@forum.invalid

  # Performance
  batch_size: 1000  # Adjust based on server resources

# Advanced settings
fix_quotes: true  # Convert phpBB quotes to Discourse format
markdown_linkify: true  # Convert URLs to markdown links
```

### Pre-Flight Checks

**Before running importer:**

- [ ] Database connection works (test with mysql client)
- [ ] Attachments directory accessible
- [ ] Discourse categories created (from Phase 4)
- [ ] Sufficient disk space (3x data size recommended)
- [ ] Staging Discourse is empty (fresh install or restored backup)

### Run the Importer

**Execute import:**

```bash
cd /var/www/discourse/script/import_scripts/phpbb3

# Dry run mode (recommended first)
# Checks data, reports issues, doesn't import
RAILS_ENV=production ruby phpbb3.rb --dry-run

# Review output for errors

# Actual import
RAILS_ENV=production ruby phpbb3.rb

# This will take time:
# - Small forum (<10k posts): 10-30 minutes
# - Medium forum (100k posts): 1-2 hours
# - Large forum (800k posts like SHMMY): 4-8 hours
```

**Monitor progress:**
```bash
# Importer outputs progress
# Watch for errors or warnings

# In another terminal, monitor:
tail -f /var/www/discourse/log/production.log
```

### Import Output

**Successful import shows:**
```
Starting phpBB3 import...
Importing users... 11362 users imported
Importing categories... 25 categories imported
Importing topics... 21849 topics imported
Importing posts... 837201 posts imported
Importing attachments... 15234 attachments imported
Importing private messages... 3421 messages imported
Creating permalinks... done
Import complete!
```

**Common warnings (usually OK):**
- "Username xxx contains invalid characters, transforming to yyy"
- "Email for user xxx is invalid, using placeholder"
- "BBCode [custom] not recognized, leaving as-is"

**Errors to investigate:**
- Database connection failures
- Out of memory errors
- Attachment file not found
- Category mapping errors

---

## 5.3: Validation and Fix-Forward

### Validation Checklist

**Use this template for every rehearsal:**

#### Data Completeness

- [ ] **User count matches**
  - phpBB: [Expected count]
  - Discourse: [Actual count] (Admin → Dashboard → Users)
  - Difference: [Explain if any]

- [ ] **Topic count matches**
  - phpBB: [Expected: 21,849]
  - Discourse: [Actual count] (Admin → Dashboard)
  - Difference: [Explain if any]

- [ ] **Post count matches**
  - phpBB: [Expected: 837,201]
  - Discourse: [Actual count] (Admin → Dashboard)
  - Difference: [Explain if any]

- [ ] **Attachment count matches**
  - phpBB: [Expected count from Phase 2]
  - Discourse: [Actual count]
  - Difference: [Explain if any]

#### Content Quality

**Sample 50 random topics, check:**

- [ ] **Topic titles preserved**
  - All characters correct (including Greek)
  - No mojibake (�� characters)

- [ ] **Post content correct**
  - Paragraphs preserved
  - Greek text displays correctly
  - Line breaks maintained

- [ ] **BBCode conversion**
  - `[b]text[/b]` → **text** ✅
  - `[i]text[/i]` → *text* ✅
  - `[url]link[/url]` → [link](url) ✅
  - `[quote]text[/quote]` → quote block ✅
  - `[code]code[/code]` → code block ✅
  - Custom BBCode: [Document status]

- [ ] **Images display**
  - Inline images load
  - Attachments downloadable
  - Image links work

- [ ] **Links work**
  - Internal links (to other topics)
  - External links
  - Attachments links

#### User Data

**Sample 20 random users, check:**

- [ ] **Username correct**
  - Matches phpBB (or documented transformation)
  - No duplicates

- [ ] **Email preserved**
  - Valid emails transferred
  - Placeholders for invalid (if strategy used)

- [ ] **Post count correct**
  - Discourse shows correct post count per user

- [ ] **Join date preserved**
  - Matches phpBB registration date

- [ ] **Avatar migrated** (if applicable)

#### Structure and Organization

- [ ] **Categories match design**
  - All categories created
  - Topics in correct categories
  - Hierarchy correct

- [ ] **Tags applied** (if configured)
  - Topics have expected tags
  - Tag groups work

- [ ] **Pinned topics preserved**
  - Sticky topics → Pinned
  - Announcements → Pinned/Banner

- [ ] **Closed topics preserved**
  - Locked topics are closed in Discourse

#### Permissions

- [ ] **Public categories accessible**
  - All users can see/post

- [ ] **Private categories restricted**
  - Only authorized users can access

- [ ] **Moderator assignments**
  - Category moderators assigned

#### Technical

- [ ] **Search works**
  - Basic keyword search returns results
  - Greek text searchable
  - Posts are indexed

- [ ] **Performance acceptable**
  - Homepage loads in <3 seconds
  - Topic page loads in <2 seconds
  - Search responds in <2 seconds

- [ ] **No errors in logs**
  ```bash
  tail -500 /var/www/discourse/log/production.log | grep ERROR
  ```

### Detailed Content Sampling

**Create a test matrix:**

| Test Case | phpBB URL | Discourse URL | Status | Notes |
|-----------|-----------|---------------|--------|-------|
| Oldest topic | [URL] | [URL] | ✅ | Content matches |
| Newest topic | [URL] | [URL] | ✅ | Content matches |
| Topic with images | [URL] | [URL] | ❌ | Images broken - fix |
| Topic with quotes | [URL] | [URL] | ✅ | Quotes render correctly |
| Topic with code | [URL] | [URL] | ⚠️ | Code preserved but not highlighted |
| Long topic (100+ posts) | [URL] | [URL] | ✅ | All posts imported |
| Topic with attachments | [URL] | [URL] | ❌ | Attachments not found |
| Greek text heavy topic | [URL] | [URL] | ✅ | Greek displays correctly |
| Private forum topic | [URL] | [URL] | ✅ | Permissions correct |
| Pinned topic | [URL] | [URL] | ✅ | Shows as pinned |

---

## 5.4: Build Migration Patch List

**Document all issues found during validation:**

### Issue Template

```markdown
## Issue #1: Image Links Broken

**Category:** Content Quality
**Severity:** High
**Affects:** ~500 topics (estimated)

**Description:**
Images linked with `[img]http://old-forum/image.jpg[/img]` are not converted correctly. They show as broken markdown image syntax.

**Example:**
- phpBB: `[img]http://forum.example.com/images/test.png[/img]`
- Discourse (current): `![](http://forum.example.com/images/test.png)` (broken)
- Discourse (expected): Working image

**Root Cause:**
Old forum URL changed, absolute URLs in old posts point to defunct server.

**Solution:**
1. Pre-process database: Update image URLs before import
2. Add to import script: URL rewriting logic

**SQL patch:**
```sql
UPDATE phpbb_posts 
SET post_text = REPLACE(post_text, 
  'http://old-forum.example.com/images/', 
  'http://current-forum.example.com/images/');
```

**Status:** [ ] Identified  [x] Solution designed  [ ] Implemented  [ ] Tested
```

### Common Issues and Patches

#### 1. Custom BBCode Not Converting

**Problem:** phpBB has custom BBCode (e.g., `[spoiler]`, `[youtube]`)

**Solution:** Pre-process or post-process

**Pre-process (recommended):**
```sql
-- Convert [spoiler]text[/spoiler] to [details]text[/details]
UPDATE phpbb_posts 
SET post_text = REPLACE(post_text, '[spoiler]', '[details]');
SET post_text = REPLACE(post_text, '[/spoiler]', '[/details]');

-- Convert [youtube]ID[/youtube] to URL
UPDATE phpbb_posts 
SET post_text = REGEXP_REPLACE(
  post_text, 
  '\[youtube\]([a-zA-Z0-9_-]+)\[/youtube\]', 
  'https://www.youtube.com/watch?v=\1'
);
```

**Post-process (if needed):**
```ruby
# In Rails console on Discourse
Post.find_each do |post|
  post.raw = post.raw.gsub(/\[spoiler\](.*?)\[\/spoiler\]/m, '[details]\1[/details]')
  post.save(validate: false)
end
```

#### 2. Username Transformation Issues

**Problem:** Many usernames have invalid characters

**Solution:** Customize transformation logic in importer

**Edit importer script:**
```ruby
# In phpbb3.rb
def transform_username(username)
  # Custom logic beyond default
  username = username.downcase
  username = username.gsub(/[^a-z0-9_]/, '_')
  username = username.gsub(/_+/, '_')
  username = username[0..19]  # Max 20 chars
  # Check for reserved names
  username = "#{username}_user" if RESERVED_NAMES.include?(username)
  username
end
```

#### 3. Attachment Path Issues

**Problem:** Attachments not found during import

**Solution:** Verify path configuration

```yaml
# In settings.yml
attachment_directory: /shared/import/phpbb_files  # Absolute path
```

**Verify structure:**
```bash
ls -la /shared/import/phpbb_files/
# Should show numbered subdirectories: 0/, 1/, 2/, ...
# phpBB stores attachments in: files/[hash_subdir]/[physical_filename]
```

#### 4. Email Validation Issues

**Problem:** Thousands of users with invalid emails

**Solution:** Pre-process email addresses

```sql
-- Fix common issues
UPDATE phpbb_users 
SET user_email = CONCAT('user_', user_id, '@forum.placeholder')
WHERE user_email = '' OR user_email IS NULL OR user_email NOT LIKE '%@%.%';

-- Fix localhost emails
UPDATE phpbb_users 
SET user_email = CONCAT('user_', user_id, '@forum.placeholder')
WHERE user_email LIKE '%@localhost%';
```

#### 5. Greek Character Encoding

**Problem:** Greek characters show as ??? or ��

**Solution:** Fix character encoding before import

```bash
# Check encoding of dump
file phpbb_backup.sql

# Convert if needed
iconv -f ISO-8859-7 -t UTF-8 phpbb_backup.sql > phpbb_backup_utf8.sql
```

**In MySQL:**
```sql
-- Ensure correct charset
ALTER DATABASE phpbb_import CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Convert tables
ALTER TABLE phpbb_posts CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

---

## 5.5: Iteration Process

### Workflow for Each Rehearsal

**Iteration N workflow:**

1. **Apply patches** (from previous iteration findings)
   - Update SQL scripts
   - Modify importer configuration
   - Add pre/post-processing scripts

2. **Reset staging Discourse**
   ```bash
   cd /var/discourse
   ./launcher rebuild app
   # Creates fresh Discourse install
   ```

3. **Prepare source data**
   - Apply SQL patches to database dump
   - Re-extract if needed
   - Verify patches applied

4. **Run import**
   - Execute importer
   - Monitor for new errors
   - Time the process (document duration)

5. **Validate**
   - Run through validation checklist
   - Sample different content than last time
   - Document new issues

6. **Review with team**
   - Show results to admins/moderators
   - Gather feedback
   - Identify deal-breakers vs. acceptable issues

7. **Update patch list**
   - Add new issues
   - Mark resolved issues
   - Prioritize remaining work

8. **Decision:**
   - Ready for production? → Proceed to Phase 6
   - Need another iteration? → Repeat

### Tracking Iterations

**Create iteration log:**

| Iteration | Date | Duration | Issues Found | Issues Fixed | Pass Rate | Notes |
|-----------|------|----------|--------------|--------------|-----------|-------|
| 1 | 2024-01-15 | 5h | 15 | 0 | 60% | First run, many issues |
| 2 | 2024-01-18 | 5.5h | 8 | 10 | 75% | Fixed encoding, BBCode |
| 3 | 2024-01-22 | 5h | 3 | 6 | 90% | Attachments working |
| 4 | 2024-01-25 | 5h | 1 | 3 | 95% | Minor formatting issues |
| 5 | 2024-01-29 | 5h | 0 | 1 | 100% | Ready for production |

---

## Deliverables

### 1. Repeatable Migration Scripts

**Package:**
```
migration-kit/
├── README.md (this guide)
├── scripts/
│   ├── 1-extract-phpbb-data.sh
│   ├── 2-apply-sql-patches.sql
│   ├── 3-transfer-files.sh
│   ├── 4-run-import.sh
│   └── 5-post-import-fixes.rb
├── config/
│   ├── settings.yml (importer config)
│   └── category-mappings.yml
└── validation/
    └── validation-checklist.md
```

See [/scripts/migration-kit/](../../scripts/migration-kit/) for templates

### 2. Staging Validation Checklist

**Comprehensive checklist with pass/fail criteria**

See [/docs/phase5-migration-rehearsal/validation-checklist.md](./validation-checklist.md)

### 3. Migration Patch List

**Documented list of all transformations and fixes**

See [/docs/phase5-migration-rehearsal/patch-list.md](./patch-list.md)

---

## Success Criteria

- [ ] 5+ rehearsal iterations completed
- [ ] All critical issues resolved
- [ ] 95%+ data completeness
- [ ] 99%+ content quality (sample check)
- [ ] Team confident in process
- [ ] Migration time fits in cutover window
- [ ] Rollback tested and works
- [ ] Documentation complete

---

## Next Steps

Once Phase 5 is complete, proceed to [Phase 6: Link Preservation and Redirects](../phase6-link-preservation/)
