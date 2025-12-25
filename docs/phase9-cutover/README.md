# Phase 9: Cutover Plan

## Objective

Execute the production move with minimal chaos using a detailed, minute-by-minute runbook.

---

## Prerequisites

Before executing cutover, ensure:

- [ ] All Phase 1-8 deliverables complete
- [ ] 5+ successful rehearsals on staging
- [ ] All critical issues resolved
- [ ] Team trained and ready
- [ ] Communication plan approved
- [ ] Rollback plan tested
- [ ] Backup plan ready
- [ ] Cutover date/time confirmed
- [ ] All stakeholders notified

---

## Cutover Team

### Roles and Responsibilities

| Role | Person | Responsibilities | Contact |
|------|--------|------------------|---------|
| **Cutover Lead** | [Name] | Overall coordination, go/no-go decisions | [Phone/Email] |
| **Technical Lead** | [Name] | Execute migration, troubleshoot issues | [Phone/Email] |
| **Database Admin** | [Name] | Database backup, export, verification | [Phone/Email] |
| **System Admin** | [Name] | Server management, DNS changes | [Phone/Email] |
| **Communications Lead** | [Name] | User communications, status updates | [Phone/Email] |
| **QA Lead** | [Name] | Validation testing, smoke tests | [Phone/Email] |

### Communication Channels

**Internal team:**
- Primary: [Slack/Discord channel]
- Backup: [Group chat/SMS]
- Emergency: [Phone conference line]

**External (users):**
- Status page: [URL]
- Twitter/social: [@handle]
- Email: [announcement list]

---

## Timeline Overview

**Total duration:** 6-8 hours

```
T-24h:  Final preparations
T-2h:   Team assembles, final checks
T-0:    FREEZE begins (phpBB read-only)
T+1h:   Data extraction complete
T+3h:   Import complete
T+4h:   Validation complete
T+5h:   DNS cutover (if applicable)
T+6h:   GO LIVE
T+7h:   Post-launch monitoring
T+24h:  Follow-up check
```

---

## Detailed Cutover Runbook

### T-7 Days: Final Preparation

**Date:** [Insert date]

- [ ] **Review checklist:** All phases complete
- [ ] **Staging final test:** Run one last complete rehearsal
  - Time the process
  - Document any issues
  - Verify fixes
- [ ] **Confirm team availability:** All roles covered
- [ ] **Pre-stage tools:** Scripts, access credentials ready
- [ ] **Backup storage:** Verify sufficient space
- [ ] **Communication templates:** Finalize all messages
- [ ] **Stakeholder briefing:** Present plan to leadership

**Output:** Go/No-Go decision for T-2 days

---

### T-2 Days: Communication Begins

**Date:** [Insert date]

- [ ] **Public announcement:** Send to all users
  ```markdown
  Subject: Forum Upgrade This [Day] - Brief Maintenance
  
  Dear Community,
  
  This [Day], [Date] at [Time], we will upgrade our forum to Discourse.
  
  **What to Expect:**
  - Forum read-only for ~6 hours
  - All content preserved
  - Check email for password reset
  
  **Timeline:**
  - [Time]: Maintenance begins
  - [Time]: Expected completion
  
  Thank you for your patience!
  ```

- [ ] **Moderator briefing:** Special session for mods
  - Walk through new tools
  - Assign day-1 monitoring roles
  - Share internal communication channels

- [ ] **Technical prep:**
  - [ ] Lower DNS TTL to 300 seconds
  - [ ] Verify backup systems
  - [ ] Test email deliverability
  - [ ] Prepare monitoring dashboards

---

### T-24 Hours: Final Checks

**Date:** [Insert date and time]

- [ ] **Team check-in:** Confirm everyone ready
- [ ] **System health check:**
  - [ ] phpBB operational
  - [ ] Staging Discourse ready
  - [ ] Production Discourse ready
  - [ ] All servers accessible
  - [ ] Network connections stable

- [ ] **Backup validation:**
  - [ ] Test backup restoration
  - [ ] Verify backup storage accessible
  - [ ] Document backup locations

- [ ] **Tool verification:**
  - [ ] Migration scripts tested
  - [ ] Database access confirmed
  - [ ] S3/storage access confirmed
  - [ ] All credentials valid

- [ ] **Communication prep:**
  - [ ] Status page URL shared
  - [ ] Social media accounts ready
  - [ ] Email templates loaded

- [ ] **Final go/no-go check:**
  - Weather clear (if on-premise)
  - No competing events
  - Team healthy and ready
  - No last-minute blockers

**Decision:** GO / NO-GO → If NO-GO, reschedule

---

### T-2 Hours: Team Assembly

**Time:** [e.g., 00:00 UTC]

**Location:** [Physical/Virtual meeting room]

#### Checklist

- [ ] **All team members present**
  - Roll call
  - Confirm roles
  - Review communication protocols

- [ ] **Final system check:**
  ```bash
  # phpBB
  - Database accessible: ✓
  - Web server responding: ✓
  - Disk space sufficient: ✓
  
  # Discourse staging
  - Server accessible: ✓
  - Docker running: ✓
  - Disk space sufficient: ✓
  
  # Discourse production  
  - Server accessible: ✓
  - Docker running: ✓
  - Disk space sufficient: ✓
  ```

- [ ] **Communication test:**
  - Internal channels working
  - Status page accessible
  - Email system tested

- [ ] **Scripts ready:**
  - Migration scripts staged
  - SQL patches prepared
  - Post-processing scripts ready

- [ ] **Monitoring setup:**
  - Logs tailing in terminals
  - Dashboard visible
  - Alert system active

**Output:** Final GO / NO-GO decision

---

### T-0: FREEZE Begins

**Time:** [e.g., 02:00 UTC]

#### Step 1: Put phpBB in Read-Only Mode (10 min)

**Assigned to:** System Admin

**Actions:**
```bash
# Option A: Database level (safest)
# Login to MySQL
mysql -u root -p

USE phpbb_database;

# Lock tables to prevent writes
FLUSH TABLES WITH READ LOCK;

# Or Option B: Configuration level
# Edit config.php
# Add: $board_config['board_disable'] = 1;
```

**Verification:**
- [ ] Try to create post (should fail)
- [ ] Try to reply (should fail)
- [ ] Can still read posts ✓
- [ ] Maintenance message showing

**Rollback point:** If verification fails, unlock and abort

---

#### Step 2: Announce Freeze (5 min)

**Assigned to:** Communications Lead

**Actions:**
- [ ] Post to status page: "Upgrade in progress"
- [ ] Tweet: "Forum maintenance started, back soon!"
- [ ] Update homepage banner (if possible)

---

#### Step 3: Final Database Backup (15 min)

**Assigned to:** Database Admin

**Actions:**
```bash
# Full database dump
mysqldump -u username -p \
  --single-transaction \
  --routines \
  --triggers \
  --hex-blob \
  --default-character-set=utf8mb4 \
  phpbb_database > phpbb_final_$(date +%Y%m%d_%H%M%S).sql

# Compress
gzip phpbb_final_*.sql

# Verify
ls -lh phpbb_final_*.sql.gz
zcat phpbb_final_*.sql.gz | head -100  # Quick check
```

**Record:**
- Backup file: `phpbb_final_YYYYMMDD_HHMMSS.sql.gz`
- File size: [XX GB]
- Checksum: `md5sum phpbb_final_*.sql.gz`

**Verification:**
- [ ] File exists
- [ ] File size reasonable (compare to previous)
- [ ] Checksum calculated and recorded

---

#### Step 4: Final Attachments Backup (20 min)

**Assigned to:** System Admin

**Actions:**
```bash
# Archive attachments
cd /path/to/phpbb
tar -czf phpbb_attachments_final_$(date +%Y%m%d_%H%M%S).tar.gz files/

# Verify
ls -lh phpbb_attachments_final_*.tar.gz
tar -tzf phpbb_attachments_final_*.tar.gz | wc -l  # Count files
```

**Record:**
- Archive file: `phpbb_attachments_final_YYYYMMDD_HHMMSS.tar.gz`
- File size: [XX GB]
- File count: [XXXXX files]

---

### T+1 Hour: Data Transfer (45 min)

**Assigned to:** Technical Lead

**Actions:**
```bash
# Transfer to production Discourse server
scp phpbb_final_*.sql.gz root@discourse-prod:/var/discourse/shared/standalone/import/
scp phpbb_attachments_final_*.tar.gz root@discourse-prod:/var/discourse/shared/standalone/import/

# Verify transfer
ssh root@discourse-prod
cd /var/discourse/shared/standalone/import/
ls -lh phpbb_*
md5sum phpbb_final_*.sql.gz  # Compare with original
```

**Verification:**
- [ ] Database dump transferred
- [ ] Attachments transferred
- [ ] Checksums match
- [ ] Files extractable

---

### T+1.5 Hours: Data Preparation (30 min)

**Assigned to:** Database Admin

**Actions:**
```bash
# On Discourse production server
cd /var/discourse/shared/standalone/import/

# Extract files
gunzip phpbb_final_*.sql.gz
mkdir -p phpbb_files
tar -xzf phpbb_attachments_final_*.tar.gz -C phpbb_files/

# Apply any final SQL patches
# (if you have last-minute fixes from rehearsals)
mysql -u root -p phpbb_import < /path/to/patches.sql
```

**Verification:**
- [ ] SQL file extracted
- [ ] Attachments extracted
- [ ] Patches applied (if any)
- [ ] Ready for import

---

### T+2 Hours: Run Import (2-3 hours for 800k posts)

**Assigned to:** Technical Lead

**Start time:** [Record actual time]

**Actions:**
```bash
# Enter Discourse container
cd /var/discourse
./launcher enter app

# Navigate to importer
cd /var/www/discourse/script/import_scripts/phpbb3

# Final config check
cat settings.yml | grep -E "(database|category_mappings)"

# Run import
RAILS_ENV=production ruby phpbb3.rb 2>&1 | tee /shared/import/import_log_$(date +%Y%m%d_%H%M%S).txt

# This will take 2-4 hours, monitor output
```

**Monitoring (parallel terminal):**
```bash
# Watch logs
tail -f /var/www/discourse/log/production.log

# Watch resource usage
htop

# Check progress (in Rails console)
rails c
User.count  # Should increase
Topic.count  # Should increase
Post.count  # Should increase
```

**Record progress every 30 minutes:**

| Time | Users | Topics | Posts | Notes |
|------|-------|--------|-------|-------|
| T+2h | | | | Import started |
| T+2.5h | | | | 25% complete (estimate) |
| T+3h | | | | 50% complete |
| T+3.5h | | | | 75% complete |
| T+4h | | | | Import finished |

**Expected output at completion:**
```
Import complete!
Users imported: 11,362
Topics imported: 21,849
Posts imported: 837,201
Attachments imported: [XXXXX]
Permalinks created: [XXXXX]
Time taken: [XX] hours
```

**Verification:**
- [ ] Import script completed without fatal errors
- [ ] User count matches (within 1%)
- [ ] Topic count matches (within 1%)
- [ ] Post count matches (within 1%)
- [ ] Log shows success

**If import fails:**
- Document error
- Assess severity
- Consult rollback criteria (Phase 1)
- Make GO / ROLLBACK decision

---

### T+5 Hours: Validation (60 min)

**Assigned to:** QA Lead + entire team

**Use validation checklist from Phase 5**

#### Quick Validation (15 min)

- [ ] **Homepage loads**
  ```bash
  curl -I https://forum.example.com
  # Should return HTTP 200
  ```

- [ ] **User counts**
  ```ruby
  rails c
  puts "Users: #{User.count}"  # Expected: ~11,362
  puts "Topics: #{Topic.count}"  # Expected: ~21,849
  puts "Posts: #{Post.count}"  # Expected: ~837,201
  ```

- [ ] **Sample topics load**
  - Oldest topic (ID 1)
  - Newest topic (last ID)
  - Random 5 topics

- [ ] **Search works**
  - Search for common term
  - Verify results returned

#### Smoke Tests (45 min)

**Test accounts (prepared earlier):**
- 5 test users with known credentials

**Test each:**

1. **Login test:**
   - [ ] Can access site
   - [ ] Request password reset
   - [ ] Receive reset email
   - [ ] Set new password
   - [ ] Log in successfully

2. **Posting test:**
   - [ ] Create new topic
   - [ ] Upload image
   - [ ] Reply to topic
   - [ ] Edit post
   - [ ] All works correctly

3. **Content test:**
   - [ ] User's old posts visible
   - [ ] Post history correct
   - [ ] Profile shows correct data

4. **Attachments test:**
   - [ ] Find topic with attachment
   - [ ] Attachment loads/downloads
   - [ ] Image displays inline

5. **Moderation test:**
   - [ ] Moderator can access mod tools
   - [ ] Can pin topic
   - [ ] Can close topic
   - [ ] Can edit post

**Content Sampling:**
- [ ] 20 random topics display correctly
- [ ] Greek text renders properly
- [ ] Code blocks formatted
- [ ] Quotes preserved
- [ ] Links work

**Performance check:**
- [ ] Homepage: < 3 seconds
- [ ] Topic page: < 2 seconds
- [ ] Search: < 2 seconds

**Log check:**
```bash
tail -100 /var/www/discourse/log/production.log | grep -i error
# Should show no critical errors
```

**Decision Point: GO LIVE or ROLLBACK?**

**GO LIVE if:**
- All critical tests pass
- Data completeness >99%
- No data corruption
- Performance acceptable
- Team consensus: GO

**ROLLBACK if:**
- Critical test failures
- Data loss >1%
- Search broken
- Performance unacceptable
- Team consensus: ROLLBACK

---

### T+6 Hours: GO LIVE

**Assigned to:** System Admin

**Only if validation passed!**

#### Step 1: DNS Cutover (if applicable) (15 min)

**If using DNS change strategy:**

```bash
# Update DNS A record
# forum.example.com → [New Discourse IP]

# Verify propagation
dig forum.example.com +short
# Should show new IP

# Test from external network
curl -I https://forum.example.com
# Should hit Discourse, not phpBB
```

**If using reverse proxy:**
- Update proxy config to point to Discourse
- Reload proxy
- Verify

#### Step 2: Enable Discourse Fully (5 min)

```bash
# Ensure Discourse is not in maintenance mode
# Should be live and accepting writes

# Test
# Login → Create post → Verify works
```

#### Step 3: Announce Go-Live (10 min)

**Communications Lead:**

- [ ] Update status page: "Upgrade complete!"
- [ ] Tweet: "New forum is live! 🎉"
- [ ] Send welcome email to all users

**Email template:**
```markdown
Subject: New Forum is Live! Welcome to Discourse

Dear SHMMY Community,

Great news! Our forum upgrade is complete.

🎉 **You can now access the new forum:**
https://forum.example.com

**Getting Started:**
1. Click "Log In" → "Forgot Password"
2. Enter your email: {email}
3. Check email for reset link
4. Set new password
5. Enjoy the new forum!

**What's New:**
- Modern, fast interface
- Better search
- Mobile-friendly
- Real-time updates

**Need Help?**
Visit: /t/migration-faq
Email: support@example.com

Welcome to the new era!

- The Forum Team
```

#### Step 4: Monitor Initial Traffic (60 min)

**All hands monitoring:**

**Watch for:**
- Server load (CPU, memory, disk)
- Error rates in logs
- User login success rate
- Support requests incoming

**Metrics to track:**
- Logins per minute
- Posts created
- Error rate
- Response times

**Be ready to:**
- Answer user questions
- Fix minor issues
- Scale resources if needed

---

### T+7 to T+24 Hours: Post-Launch Monitoring

#### T+7 Hours: Initial Review

**Team debrief:**
- [ ] Review what went well
- [ ] Document issues encountered
- [ ] Update procedures for future
- [ ] Assess rollback likelihood (still possible if major issues)

**Communication:**
- [ ] Post status update (all good!)
- [ ] Thank community for patience

**Technical tasks:**
- [ ] Verify backups running
- [ ] Check monitoring systems
- [ ] Review error logs
- [ ] Document any workarounds applied

#### T+12 Hours: Mid-Day Check

- [ ] Check support queue
- [ ] Review common user issues
- [ ] Update FAQ if new questions
- [ ] Monitor performance

#### T+24 Hours: Day 1 Review

**Meeting with full team:**

**Metrics review:**
- Total users logged in: [X] / [Total]
- Login success rate: [X%]
- Posts created: [X]
- Support tickets: [X]
- Critical issues: [X]

**User feedback:**
- Sentiment analysis
- Common complaints
- Feature requests
- Compliments

**Technical health:**
- Uptime: [X%]
- Performance: [OK/Issues]
- Errors: [Count, types]
- Backups: [Status]

**Action items:**
- [ ] Issues to fix immediately
- [ ] Improvements for week 1
- [ ] FAQ updates needed
- [ ] Communication adjustments

**Decision:**
- Continue forward ✅
- OR: Plan rollback (if catastrophic issues)

---

## Rollback Procedure

**Only if critical issues discovered**

See [rollback-runbook.md](./rollback-runbook.md) for details.

**Quick overview:**

1. **Decision made:** Cutover Lead authorizes rollback
2. **Announce:** "Experiencing issues, reverting to old forum"
3. **Revert DNS** (if changed): forum.example.com → old phpBB
4. **Re-enable phpBB:** Remove read-only mode
5. **Verify:** phpBB accessible and writable
6. **Communicate:** "Old forum restored, all data safe"
7. **Post-mortem:** Analyze what went wrong
8. **Fix and reschedule:** Address issues, plan new cutover date

**Maximum rollback time:** 30 minutes from decision

---

## Communication Templates

See [communication-templates.md](./communication-templates.md) for all templates:
- Pre-cutover announcement
- Freeze notification
- Progress updates
- Go-live announcement
- Welcome email
- FAQ updates
- Rollback announcement (if needed)

---

## Success Criteria

**Cutover is successful if:**
- [ ] All content migrated (>99%)
- [ ] Users can log in (>95% within 24h)
- [ ] No data loss
- [ ] Redirects working (>90%)
- [ ] Performance acceptable
- [ ] No rollback needed
- [ ] Community feedback positive

---

## Lessons Learned Log

**After cutover, document:**

### What Went Well
- [Item 1]
- [Item 2]

### What Could Be Improved
- [Item 1]
- [Item 2]

### Surprises / Unexpected Issues
- [Item 1]
- [Item 2]

### Recommendations for Future
- [Item 1]
- [Item 2]

---

## Next Steps

Once cutover is complete and stable, proceed to [Phase 10: Post-Launch Operations](../phase10-post-launch/)
