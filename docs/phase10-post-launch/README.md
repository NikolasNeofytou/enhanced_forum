# Phase 10: Post-Launch Operations

## Objective

Ensure the platform survives and thrives post-launch through proper operations, monitoring, and continuous improvement.

---

## Daily Operations (Week 1-4)

### Day 1-7: Intensive Monitoring

**Daily tasks:**

#### Morning Check (9:00 AM)

**System health:**
```bash
# Check Discourse status
cd /var/discourse
./launcher logs app --tail 100

# Check system resources
htop  # Look for CPU, memory, disk usage

# Check disk space
df -h
# Concern if >80% full
```

**Metrics review:**
- Users logged in today: [Check Admin → Dashboard]
- New posts today: [Dashboard]
- Error rate: [Check logs]
- Page load times: [Check monitoring]

**Support queue:**
- Open tickets: [Count]
- Urgent issues: [Count]
- Common issues: [List]

**Actions:**
- [ ] Respond to urgent issues
- [ ] Update FAQ if new patterns emerge
- [ ] Report status to team

#### Mid-Day Check (2:00 PM)

- [ ] Check support queue again
- [ ] Review any new error patterns
- [ ] Monitor user activity levels
- [ ] Check email deliverability (bounces, complaints)

#### Evening Check (6:00 PM)

- [ ] Final support queue review
- [ ] Check that night backups will run
- [ ] Review day's activity
- [ ] Document any issues

**Metrics to track daily:**

| Date | Active Users | New Posts | Login Success % | Errors | Tickets | Notes |
|------|--------------|-----------|-----------------|--------|---------|-------|
| Day 1 | | | | | | |
| Day 2 | | | | | | |
| Day 3 | | | | | | |
| Day 4 | | | | | | |
| Day 5 | | | | | | |
| Day 6 | | | | | | |
| Day 7 | | | | | | |

### Week 2-4: Regular Monitoring

**Daily check (once per day):**
- [ ] System health check (5 min)
- [ ] Support queue (10 min)
- [ ] Error log review (5 min)

**Weekly tasks:**
- [ ] Performance review
- [ ] Backup restoration test
- [ ] Security update check
- [ ] User feedback review
- [ ] Team meeting (30 min)

---

## Automated Backups

### Backup Configuration

**Verify automated backups are running:**

```bash
# Check backup settings
cd /var/discourse
./launcher enter app
rails c

# Check backup schedule
puts SiteSetting.backup_frequency  # Should be: 1 (daily)
puts SiteSetting.maximum_backups  # Should be: 7 or more
puts SiteSetting.backup_location  # s3 or local

# Check recent backups
Backup.all.order(created_at: :desc).limit(7).each do |backup|
  puts "#{backup.filename} - #{backup.created_at} - #{backup.size} bytes"
end
```

**Backup schedule:**
- **Frequency:** Daily (3:00 AM local time)
- **Retention:** 7 days local, 30 days remote (if S3)
- **Location:** 
  - Local: `/var/discourse/shared/standalone/backups/default/`
  - Remote: S3 bucket (recommended)

### Backup Monitoring

**Daily backup verification:**

```bash
# Check last backup
cd /var/discourse/shared/standalone/backups/default/
ls -lht | head -5

# Should see backup from last night with reasonable size
# Example: discourse-2024-01-15-030000-v20240115030000.tar.gz (2.5 GB)
```

**Alert if:**
- No backup from last 24 hours
- Backup size drastically different from previous (±50%)
- Backup failed (check logs)

### Restore Testing

**Monthly restore test:**

**Purpose:** Verify backups actually work!

**Process:**

1. **Download recent backup:**
   ```bash
   # From production
   cd /var/discourse/shared/standalone/backups/default/
   # Copy to local machine for testing
   ```

2. **Restore to test environment:**
   - Use a separate server or staging
   - Admin → Backups → Upload → Select backup
   - Click "Restore"
   - Wait for completion (30-60 min)

3. **Validate restored data:**
   - [ ] Can access forum
   - [ ] Recent posts visible
   - [ ] Users can log in
   - [ ] Attachments load
   - [ ] Search works

4. **Document results:**
   ```
   Date: [YYYY-MM-DD]
   Backup file: [filename]
   Restore time: [XX minutes]
   Validation: [PASS/FAIL]
   Issues: [None or describe]
   ```

**Schedule:** First of each month

---

## Monitoring and Alerting

### Built-in Discourse Monitoring

**Admin Dashboard:**

Visit: `https://forum.example.com/admin/dashboard`

**Key metrics:**
- Active users (daily, weekly, monthly)
- New users
- Topics created
- Posts created
- Page views
- Response time (should be <1000ms median)
- Background jobs (should be ~0 failed)

**Review frequency:** Daily (week 1), Weekly (after)

### Infrastructure Monitoring

**Recommended: Set up external monitoring**

#### Option 1: UptimeRobot (Free/Cheap)

**Setup:**
1. Create account at uptimerobot.com
2. Add monitor: HTTP(S), URL: `https://forum.example.com`
3. Check interval: 5 minutes
4. Alert contacts: Email + SMS (optional)

**What it monitors:**
- Site up/down
- Response time
- SSL certificate expiry

#### Option 2: Custom Script

```bash
#!/bin/bash
# /usr/local/bin/check-discourse-health.sh

FORUM_URL="https://forum.example.com"
ALERT_EMAIL="admin@example.com"

# Check if forum is responding
response=$(curl -s -o /dev/null -w "%{http_code}" $FORUM_URL)

if [ "$response" != "200" ]; then
    echo "ALERT: Forum returned HTTP $response" | mail -s "Forum Down!" $ALERT_EMAIL
    exit 1
fi

# Check response time
response_time=$(curl -s -o /dev/null -w "%{time_total}" $FORUM_URL)
if (( $(echo "$response_time > 5.0" | bc -l) )); then
    echo "ALERT: Slow response time: ${response_time}s" | mail -s "Forum Slow!" $ALERT_EMAIL
fi

# Check disk space
disk_usage=$(df -h /var/discourse | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$disk_usage" -gt 80 ]; then
    echo "ALERT: Disk usage at ${disk_usage}%" | mail -s "Disk Space Warning!" $ALERT_EMAIL
fi

echo "Health check passed at $(date)"
```

**Install:**
```bash
# Create script
sudo nano /usr/local/bin/check-discourse-health.sh
# Paste above content

# Make executable
sudo chmod +x /usr/local/bin/check-discourse-health.sh

# Add to cron (run every 5 minutes)
crontab -e
# Add: */5 * * * * /usr/local/bin/check-discourse-health.sh >> /var/log/discourse-health.log 2>&1
```

### Log Monitoring

**Key logs to watch:**

```bash
# Application logs
/var/discourse/shared/standalone/log/rails/production.log

# Web server logs
/var/discourse/shared/standalone/log/var-log/nginx/access.log
/var/discourse/shared/standalone/log/var-log/nginx/error.log
```

**Look for:**
- 5xx errors (server errors)
- 4xx errors in unusual volumes
- Slow query warnings
- Background job failures
- Email delivery failures

**Weekly log review:**
```bash
# Count errors by type
cd /var/discourse
./launcher logs app | grep -i error | sort | uniq -c | sort -rn | head -20
```

### Email Deliverability Monitoring

**Check daily:**

Admin → Email → Sent/Bounced/Rejected tabs

**Healthy metrics:**
- Bounces: <2%
- Rejected: <1%
- Delivered: >95%

**If issues:**
- Check SMTP credentials
- Verify SPF/DKIM/DMARC records
- Review bounce messages
- Consider switching email provider

---

## Moderation Playbook

### Daily Moderation Tasks

**Review queue:**

Admin → Review → Flags

**Types of flags:**
- Spam
- Inappropriate
- Off-topic
- Other

**Process:**
1. Read flagged content
2. Review context
3. Make decision:
   - Agree (hide/delete post)
   - Disagree (keep post)
   - Ignore (defer)
4. Take action if needed

**Time commitment:** 10-30 min/day (depends on volume)

### Spam Handling

**Discourse has good anti-spam built-in:**
- Akismet integration
- Rate limiting
- Trust level restrictions
- Suspicious IP detection

**If spam bursts occur:**

1. **Identify pattern:**
   - Similar usernames?
   - Similar content?
   - Same IP range?

2. **Take action:**
   ```ruby
   # In Rails console
   ./launcher enter app
   rails c
   
   # Find spam users
   User.where("created_at > ?", 1.hour.ago).where("trust_level = 0").each do |user|
     puts "#{user.username} - #{user.email} - #{user.ip_address}"
   end
   
   # Delete spam users (careful!)
   # User.find(123).destroy
   ```

3. **Block IP range:**
   - Admin → Settings → Security
   - Add to screened_ip_addresses

4. **Adjust settings temporarily:**
   ```yaml
   min_trust_to_create_topic: 1  # Restrict new user posting
   must_approve_users: true  # Manual approval required
   ```

### User Suspension Process

**When to suspend:**
- Repeated rule violations
- Harassment
- Spam
- Illegal content

**Process:**

1. **Warning first** (unless severe violation)
   - Send PM to user
   - Explain violation
   - Link to guidelines
   - State consequences

2. **Temporary suspension:**
   - Admin → Users → [Username] → Suspend
   - Duration: 1-7 days (escalate for repeats)
   - Reason: [Public/Private message]

3. **Permanent ban:**
   - Only for severe or repeated violations
   - Admin → Users → [Username] → Suspend Indefinitely
   - Option: Delete posts if spam

4. **Document:**
   - Keep record of suspensions
   - Note reasoning
   - Track repeat offenders

### Moderation Guidelines Document

**Create at: `/t/moderation-guidelines` (staff-only)**

**Contents:**
- What constitutes rule violation
- Warning → Suspension → Ban escalation
- How to handle edge cases
- Moderator code of conduct
- Internal communication protocol

---

## Trust Level Tuning

### Monitor Trust Level Promotions

**Weekly check:**

```ruby
rails c

# TL distribution
User.group(:trust_level).count

# Recent promotions to TL3
User.where(trust_level: 3).where("trust_level_locked_at > ?", 1.week.ago).count
```

**Healthy distribution (after stabilization):**
- TL0: 5-10% (new users)
- TL1: 30-40% (occasional users)
- TL2: 40-50% (regular users)
- TL3: 5-10% (power users)
- TL4: <1% (leaders, manual)

### Adjust Requirements if Needed

**If too many TL3 users (>15%):**
```yaml
# Admin → Settings → Trust
# Make TL3 harder to achieve
tl3_requires_topics_viewed: 100  # Increase
tl3_requires_posts_read: 1000  # Increase
```

**If too few TL3 users (<3%):**
```yaml
# Make easier
tl3_requires_topics_viewed: 25  # Decrease
tl3_requires_posts_read: 500  # Decrease
```

### Manual TL4 Promotion

**For exceptional users:**

1. **Criteria for TL4:**
   - Long-term member (6+ months)
   - Consistently helpful
   - Trusted by community
   - Good judgment
   - Willing to help moderate

2. **Process:**
   - Team discussion
   - Consensus required
   - Admin → Users → [Username] → Grant Trust Level 4
   - Send PM explaining privileges and responsibilities

---

## Security Maintenance

### Weekly Security Tasks

- [ ] **Check for Discourse updates:**
  ```bash
  cd /var/discourse
  git pull
  # If updates available:
  ./launcher rebuild app
  ```

- [ ] **Review security logs:**
  - Failed login attempts
  - Suspicious IP access patterns
  - Rate limit violations

- [ ] **SSL certificate check:**
  ```bash
  # Certificate should auto-renew via Let's Encrypt
  # Verify:
  openssl s_client -connect forum.example.com:443 -servername forum.example.com < /dev/null 2>/dev/null | openssl x509 -noout -dates
  # Check expiration date
  ```

### Monthly Security Tasks

- [ ] **Security audit:**
  - Review admin users (any unauthorized?)
  - Review API keys (any unused?)
  - Review plugins (all from trusted sources?)

- [ ] **Update underlying OS:**
  ```bash
  sudo apt-get update
  sudo apt-get upgrade
  sudo apt-get dist-upgrade
  # Reboot if kernel updated
  ```

- [ ] **Review Discourse security announcements:**
  - Subscribe to: https://meta.discourse.org/c/security
  - Check for critical updates

### Quarterly Security Tasks

- [ ] **Rotate secrets:**
  - Discourse secret_key_base
  - SSO shared secret (if applicable)
  - Database passwords
  - API keys

- [ ] **Backup restoration drill:**
  - Full restore test
  - Document time and issues

- [ ] **Penetration test (optional):**
  - Manual security review
  - Or use automated tools (OWASP ZAP)

---

## Performance Optimization

### Performance Metrics to Track

**Target performance:**
- Homepage: <1 second
- Topic page: <800ms
- Search: <1 second
- Admin: <2 seconds

**Check regularly:**

```ruby
rails c

# Recent slow queries
DB.query("SELECT query, mean_exec_time, calls 
          FROM pg_stat_statements 
          ORDER BY mean_exec_time DESC 
          LIMIT 10")

# Cache hit rate (should be >95%)
stats = DB.query_single("SELECT sum(blks_hit)*100.0/sum(blks_hit+blks_read) as hit_ratio FROM pg_stat_database")[0]
puts "Cache hit ratio: #{stats}%"
```

### Optimization Actions

**If performance degrades:**

1. **Check server resources:**
   ```bash
   htop  # CPU/Memory
   iostat  # Disk I/O
   ```

2. **Rebuild for optimization:**
   ```bash
   cd /var/discourse
   ./launcher rebuild app
   # Rebuilds assets, clears caches
   ```

3. **Database maintenance:**
   ```bash
   ./launcher enter app
   rails c
   
   # Vacuum database
   DB.exec("VACUUM ANALYZE")
   
   # Reindex
   DB.exec("REINDEX DATABASE discourse")
   ```

4. **Consider scaling:**
   - Upgrade server (more CPU/RAM)
   - Enable CDN for assets
   - Add Redis cache tuning

---

## User Feedback Loop

### Collecting Feedback

**Week 1: Active collection**
- Create #feedback category
- Post daily "How's it going?" topics
- Monitor responses

**Week 2-4: Structured feedback**
- Create survey (Google Forms, Typeform)
- Questions:
  - How do you rate the new forum? (1-5)
  - What do you like most?
  - What needs improvement?
  - Any features you miss from old forum?
  - Any bugs encountered?

**Ongoing: Passive feedback**
- Monitor #feedback category
- Track common support issues
- Review flags and complaints

### Acting on Feedback

**Weekly review meeting:**
1. Compile feedback summary
2. Categorize issues:
   - Quick wins (can fix in <1 hour)
   - Bugs (need fixing)
   - Feature requests (evaluate)
   - User education needed (update docs)
3. Prioritize
4. Assign ownership
5. Implement and communicate

**Communication:**
- Post updates in #announcements
- "What we've improved this week"
- Thank users for feedback

---

## Operations Handbook

### Admin Handbook

**Create comprehensive documentation:**

**Contents:**

1. **Getting Started**
   - Admin panel overview
   - Common tasks
   - Where to find things

2. **User Management**
   - Creating users
   - Resetting passwords
   - Suspending/unsuspending
   - Merging duplicate accounts
   - Deleting spam accounts

3. **Content Management**
   - Creating categories
   - Managing tags
   - Pinning topics
   - Closing topics
   - Moving topics between categories
   - Bulk operations

4. **Moderation**
   - Handling flags
   - Dealing with spam
   - Suspension process
   - Escalation procedures

5. **Technical Maintenance**
   - Updating Discourse
   - Backup and restore
   - Installing plugins
   - Changing settings
   - Reading logs

6. **Troubleshooting**
   - Common issues and solutions
   - When to restart
   - Emergency procedures
   - Who to contact

**Store at:** Private wiki or Google Docs (admin access only)

### Runbooks

**Create runbooks for common tasks:**

**Examples:**
- How to update Discourse
- How to restore from backup
- How to handle spam burst
- How to add a new admin
- How to install a plugin
- Emergency shutdown procedure

**Format:**
```markdown
# Runbook: [Task Name]

**When to use:** [Situation]
**Prerequisites:** [What you need]
**Time required:** [Estimate]
**Risk level:** [Low/Medium/High]

## Steps

1. **[Step 1]**
   ```bash
   [Commands]
   ```
   **Verification:** [How to verify this step worked]

2. **[Step 2]**
   ...

## Rollback

If something goes wrong:
[Rollback steps]

## Verification

After completion:
- [ ] [Check 1]
- [ ] [Check 2]

## Troubleshooting

**Issue:** [Common problem]
**Solution:** [Fix]
```

---

## Handoff and Knowledge Transfer

**Goal:** Platform is maintainable beyond the migration team

### Documentation Checklist

- [ ] Admin handbook complete
- [ ] Runbooks written
- [ ] All credentials documented (securely!)
- [ ] Architecture diagram updated
- [ ] Monitoring setup documented
- [ ] Backup process documented
- [ ] Emergency contacts list
- [ ] Vendor accounts documented (hosting, email, etc.)

### Training Sessions

**Schedule training for:**

1. **Administrators** (4 hours)
   - Full platform overview
   - Admin panel deep dive
   - Technical maintenance
   - Troubleshooting
   - Emergency procedures

2. **Moderators** (2 hours)
   - Moderation tools
   - Flag handling
   - Community guidelines enforcement
   - Escalation procedures

3. **Support Staff** (1 hour)
   - Common user issues
   - Password resets
   - Account recovery
   - When to escalate

### Transition Period

**Week 1-2:** Migration team fully available

**Week 3-4:** Migration team on-call, permanent team primary

**Month 2:** Migration team consulted as needed

**Month 3+:** Permanent team fully independent

---

## First Month Monitoring Checklist

### Week 1

- [ ] Daily system health checks
- [ ] Daily support queue review
- [ ] Daily backup verification
- [ ] Daily performance check
- [ ] Daily user feedback review
- [ ] End-of-week team meeting

### Week 2

- [ ] All week 1 tasks
- [ ] Mid-week performance review
- [ ] Security update check
- [ ] User satisfaction survey launched

### Week 3

- [ ] Transition to weekly monitoring cadence
- [ ] Review survey results
- [ ] Plan improvements
- [ ] Update documentation based on learnings

### Week 4

- [ ] Monthly backup restore test
- [ ] Security audit
- [ ] Performance optimization review
- [ ] End-of-month retrospective

---

## Success Metrics

### Platform Health

**Month 1 targets:**
- Uptime: >99.5%
- Response time: <1s median
- Error rate: <0.1%
- Backup success rate: 100%

### User Adoption

**Month 1 targets:**
- Login rate: >70% of historical active users
- Daily active users: Match or exceed phpBB baseline
- New posts/day: Match or exceed phpBB baseline
- User satisfaction: >3.5/5 average

### Support Load

**Month 1:**
- Expect high support volume
- Target: Response within 24 hours
- Resolve >80% of issues

**Month 2+:**
- Support volume decreases
- Target: Response within 48 hours
- Self-service resolution >50%

---

## Deliverables

- [ ] **Operations handbook** - Complete admin guide
- [ ] **Runbooks** - Common tasks documented
- [ ] **Monitoring setup** - Alerts and dashboards configured
- [ ] **Backup verification** - Tested and documented
- [ ] **First month checklist** - Daily/weekly tasks defined
- [ ] **Training materials** - For admins and moderators
- [ ] **Handoff complete** - Knowledge transferred to permanent team

---

## Success Criteria

- [ ] Platform stable (no major outages)
- [ ] Backups running and tested
- [ ] Monitoring in place and working
- [ ] Moderation running smoothly
- [ ] User satisfaction positive (>3.5/5)
- [ ] Support load manageable
- [ ] Permanent team trained and confident
- [ ] Documentation complete

---

## Congratulations!

If you've reached this point with all success criteria met, your migration is complete! 🎉

The forum is now on a modern, maintainable platform that will serve the community well for years to come.

**Remember:**
- Keep monitoring
- Keep improving
- Keep listening to users
- Keep documentation updated

**The platform is alive - nurture it!**
