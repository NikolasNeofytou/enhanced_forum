# Phase 2: Technical Discovery and Audit

## Objective

Inventory and assess the current phpBB installation to de-risk the migration.

## What You Must Inventory

### 1. phpBB Version and Database Engine

#### phpBB Version
- [ ] Check current phpBB version
  - Path: Admin Control Panel → System tab
  - Or check: `includes/constants.php` → `PHPBB_VERSION`
- [ ] Version compatibility check
  - Official importer supports phpBB 3.0 – 3.3
  - Reference: [Discourse phpBB3 importer docs](https://meta.discourse.org/t/importing-from-phpbb3/31201)

**Current Version:** [Record here]

#### Database Engine
- [ ] Database type (MySQL/MariaDB/PostgreSQL)
- [ ] Database version
- [ ] Character encoding (should be UTF-8)
- [ ] Collation settings
- [ ] Database size

**Check with:**
```sql
SELECT VERSION();
SHOW TABLE STATUS;
SELECT 
    table_schema as 'Database',
    SUM(data_length + index_length) / 1024 / 1024 as 'Size (MB)'
FROM information_schema.TABLES 
WHERE table_schema = 'your_phpbb_database'
GROUP BY table_schema;
```

**Database Details:**
- Type: [MySQL/MariaDB/PostgreSQL]
- Version: [X.X.X]
- Character Set: [utf8mb4/utf8]
- Collation: [utf8mb4_unicode_ci]
- Size: [X MB/GB]

---

### 2. User Model Realities

#### User Statistics
- [ ] Total users: [Number from index page: 11,362]
- [ ] Active users (posted in last 12 months): [Query]
- [ ] Inactive users (never posted): [Query]
- [ ] Banned users: [Query]
- [ ] Duplicate email addresses: [Query]

**SQL Queries:**

```sql
-- Total users
SELECT COUNT(*) FROM phpbb_users WHERE user_type != 2; -- Exclude bots

-- Active users (posted in last year)
SELECT COUNT(DISTINCT poster_id) FROM phpbb_posts 
WHERE FROM_UNIXTIME(post_time) > DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- Inactive users (never posted)
SELECT COUNT(*) FROM phpbb_users u 
WHERE NOT EXISTS (SELECT 1 FROM phpbb_posts p WHERE p.poster_id = u.user_id)
AND u.user_type != 2;

-- Banned users
SELECT COUNT(*) FROM phpbb_banlist;

-- Users with duplicate emails
SELECT user_email, COUNT(*) as count 
FROM phpbb_users 
WHERE user_email != '' 
GROUP BY user_email 
HAVING count > 1;
```

#### Username Analysis
- [ ] Usernames with special characters
- [ ] Usernames longer than 20 characters
- [ ] Usernames shorter than 3 characters
- [ ] Usernames with spaces

```sql
-- Special characters
SELECT username FROM phpbb_users 
WHERE username REGEXP '[^a-zA-Z0-9_]';

-- Length issues
SELECT username FROM phpbb_users 
WHERE LENGTH(username) > 20 OR LENGTH(username) < 3;

-- Spaces
SELECT username FROM phpbb_users 
WHERE username LIKE '% %';
```

**Username Issues Count:**
- Special characters: [Count]
- Too long: [Count]
- Too short: [Count]
- With spaces: [Count]

#### Email Validation
- [ ] Users with missing emails
- [ ] Users with invalid email format
- [ ] Users with undeliverable domains
- [ ] Duplicate emails

```sql
-- Missing emails
SELECT COUNT(*) FROM phpbb_users WHERE user_email = '' OR user_email IS NULL;

-- Invalid format (basic check)
SELECT COUNT(*) FROM phpbb_users 
WHERE user_email NOT LIKE '%@%.%' AND user_email != '';

-- Localhost/invalid domains
SELECT COUNT(*) FROM phpbb_users 
WHERE user_email LIKE '%@localhost%' OR user_email LIKE '%@example.%';
```

**Email Issues:**
- Missing: [Count]
- Invalid format: [Count]
- Suspicious domains: [Count]

---

### 3. Content Statistics

#### Posts and Topics
- [ ] Total posts: [Record: 837,201]
- [ ] Total topics: [Record: 21,849]
- [ ] Average posts per topic: [Calculate]
- [ ] Date range (oldest to newest post)

```sql
-- Verify counts
SELECT COUNT(*) FROM phpbb_posts;
SELECT COUNT(*) FROM phpbb_topics;

-- Date range
SELECT 
    FROM_UNIXTIME(MIN(post_time)) as oldest_post,
    FROM_UNIXTIME(MAX(post_time)) as newest_post
FROM phpbb_posts;

-- Posts by year
SELECT 
    YEAR(FROM_UNIXTIME(post_time)) as year,
    COUNT(*) as post_count
FROM phpbb_posts
GROUP BY YEAR(FROM_UNIXTIME(post_time))
ORDER BY year;
```

#### Forum Structure
- [ ] Number of forums/categories
- [ ] Number of subforums
- [ ] Private forums count
- [ ] Post distribution by forum

```sql
-- Forum count
SELECT COUNT(*) FROM phpbb_forums;

-- Forum hierarchy
SELECT forum_id, parent_id, forum_name, forum_type 
FROM phpbb_forums 
ORDER BY parent_id, forum_id;

-- Posts per forum
SELECT f.forum_name, COUNT(p.post_id) as post_count
FROM phpbb_forums f
LEFT JOIN phpbb_posts p ON f.forum_id = p.forum_id
GROUP BY f.forum_id
ORDER BY post_count DESC;
```

**Forum Structure:**
- Total forums: [Count]
- Top-level categories: [Count]
- Subforums: [Count]
- Private forums: [Count]

---

### 4. Attachments Inventory

#### Storage Details
- [ ] Attachment storage location
  - Default: `files/` directory in phpBB root
  - Check: Admin CP → Attachment settings
- [ ] Total attachment count
- [ ] Total storage size
- [ ] File types (MIME types)
- [ ] Largest files

```sql
-- Attachment count and size
SELECT 
    COUNT(*) as total_attachments,
    SUM(filesize) / 1024 / 1024 as total_size_mb
FROM phpbb_attachments;

-- File types
SELECT 
    extension,
    COUNT(*) as count,
    SUM(filesize) / 1024 / 1024 as size_mb
FROM phpbb_attachments
GROUP BY extension
ORDER BY count DESC;

-- Large files (>10MB)
SELECT 
    real_filename,
    filesize / 1024 / 1024 as size_mb,
    mimetype
FROM phpbb_attachments
WHERE filesize > 10485760
ORDER BY filesize DESC
LIMIT 20;
```

**Attachment Details:**
- Total count: [Number]
- Total size: [X GB]
- Storage location: [Path]
- File types: [List common types]
- Largest file: [Size]

#### External Hosting Check
- [ ] Are any attachments hosted externally?
- [ ] Image proxying configured?
- [ ] CDN in use?

**External Hosting:** [Yes/No, details]

---

### 5. Customizations Catalog

#### phpBB Extensions/MODs
- [ ] List installed extensions
  - Path: Admin CP → Customize → Extension Management
- [ ] List enabled MODs (older phpBB versions)
- [ ] Custom BBCode definitions

```sql
-- Extensions
SELECT ext_name FROM phpbb_ext WHERE ext_active = 1;

-- Custom BBCode
SELECT bbcode_tag, bbcode_helpline 
FROM phpbb_bbcodes;
```

**Installed Extensions:**
| Extension Name | Version | Purpose | Critical? |
|----------------|---------|---------|-----------|
| [Name] | [Ver] | [Purpose] | [Y/N] |

**Custom BBCode:**
| Tag | Usage | Migration Strategy |
|-----|-------|--------------------|
| [tag] | [Description] | [Convert to markdown / Plugin / Manual] |

#### Theme Customizations
- [ ] Custom theme/style installed
- [ ] Logo and branding customizations
- [ ] CSS modifications

**Theme Details:**
- Active style: [Name]
- Customizations: [List]
- Logo location: [Path]

#### Permission Customizations
- [ ] Custom user groups
- [ ] Special permissions
- [ ] Private forum access rules

```sql
-- User groups
SELECT group_name, group_type FROM phpbb_groups;

-- Private forums
SELECT forum_name 
FROM phpbb_forums 
WHERE forum_password != '' OR forum_type = 1; -- Type 1 = Private
```

**Custom Groups:**
| Group Name | Members | Purpose | Discourse Mapping |
|------------|---------|---------|-------------------|
| [Name] | [Count] | [Purpose] | [Category/Trust Level] |

---

### 6. Email Configuration

#### Current Email Setup
- [ ] SMTP server/service
- [ ] Sending domain
- [ ] Sender email address
- [ ] Email delivery method (PHP mail / SMTP)

**Check:** Admin CP → General → Email settings

**Current Config:**
- Method: [SMTP/PHP mail/Sendmail]
- SMTP Host: [If applicable]
- Sender: [email address]
- Deliverability status: [Test send email]

#### Discourse Email Requirements
- [ ] SMTP credentials for Discourse
- [ ] SPF record configured
- [ ] DKIM configured
- [ ] DMARC configured
- [ ] Domain reputation check

**Action Items:**
- [ ] Set up Discourse email service (e.g., SendGrid, Mailgun)
- [ ] Verify DNS records
- [ ] Test email deliverability

---

### 7. URL Patterns for SEO

#### Current URL Structure
- [ ] Document current phpBB URL patterns
- [ ] Check .htaccess for URL rewriting
- [ ] List common URL patterns

**phpBB URL Examples:**
```
Topics: /viewtopic.php?t=12345
        /viewtopic.php?f=5&t=12345
        /viewtopic.php?p=67890#p67890 (specific post)

Forums: /viewforum.php?f=5

Users:  /memberlist.php?mode=viewprofile&u=123

Search: /search.php
```

**SEO Considerations:**
- [ ] Current Google indexing status (site:forum.example.com)
- [ ] Number of indexed pages
- [ ] Most linked pages
- [ ] Backlinks to preserve

**Action Items:**
- [ ] Export list of all topic IDs and titles
- [ ] Create redirect mapping plan (see Phase 6)

---

## Deliverable: Data & Risk Report

### Summary Statistics

| Metric | Count | Size (if applicable) |
|--------|-------|---------------------|
| phpBB Version | [Version] | - |
| Database Size | - | [X GB] |
| Users | 11,362 | - |
| Posts | 837,201 | - |
| Topics | 21,849 | - |
| Attachments | [Count] | [X GB] |
| Forums | [Count] | - |
| Extensions | [Count] | - |
| Custom BBCode | [Count] | - |

### Data Quality Issues

| Issue | Count | Severity | Resolution Plan |
|-------|-------|----------|-----------------|
| Invalid emails | [Count] | Medium | [Plan] |
| Duplicate emails | [Count] | Low | [Plan] |
| Username issues | [Count] | Low | [Plan] |
| Large attachments | [Count] | Low | [Plan] |

### Customizations Requiring Special Handling

| Customization | Type | Complexity | Migration Strategy |
|---------------|------|------------|-------------------|
| [Name] | [Extension/BBCode/Theme] | [Low/Med/High] | [Strategy] |

### Migration Risk Register

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Data loss during migration | High | Low | Multiple rehearsals, backups |
| Character encoding issues (Greek) | Medium | Medium | Test encoding in staging |
| Attachment migration failures | Medium | Low | Separate attachment import, verify |
| Email deliverability issues | High | Medium | Test email config before cutover |
| Downtime exceeds window | Medium | Medium | Practice run, measure timings |
| User resistance to change | Medium | High | Communication, training, feedback |
| Username conflicts | Low | Medium | Automated transformation, manual review |
| Custom BBCode not working | Medium | Low | Pre-convert or document workarounds |
| Private forum permissions lost | High | Low | Careful category permission mapping |

---

## Tools and Scripts

See [templates/audit-scripts/](../../templates/audit-scripts/) for:
- Database audit SQL queries
- Username validation script
- Email validation script
- Attachment inventory script

---

## Success Criteria

- [ ] Complete inventory of all data
- [ ] All data quality issues identified
- [ ] Risk register created and reviewed
- [ ] Customizations documented
- [ ] Email configuration validated
- [ ] No surprises remain

---

## Next Steps

Once Phase 2 is complete, proceed to [Phase 3: Target Architecture](../phase3-target-architecture/)
