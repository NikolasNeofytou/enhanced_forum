# Cutover Rules Template

## Freeze Window Definition

### Duration

**Recommended:** 4-8 hours  
**Selected:** [X hours]

**Rationale:**
- Time needed for final DB export: [estimate]
- Time needed for final import: [estimate]
- Time for validation: [estimate]
- Buffer for issues: [estimate]

### Timing

**Proposed Date:** [YYYY-MM-DD]  
**Proposed Time:** [HH:MM - HH:MM UTC]

**Selection Rationale:**
- [ ] Low-traffic period (check analytics)
- [ ] Weekend vs. weekday: [Choice and why]
- [ ] Academic calendar consideration: [e.g., not during exams]
- [ ] Holiday avoidance: [Check dates]
- [ ] Staff availability: [Confirm]

**Alternative Dates:**
1. [Date/Time] - [Why suitable]
2. [Date/Time] - [Why suitable]

---

## Read-Only Freeze Protocol

### Actions at Freeze Start

**T-0 (Freeze begins):**
- [ ] Put phpBB into read-only mode
  - Method: [Database config / Plugin / Server config]
  - Verification: Test post creation (should fail)
- [ ] Display maintenance message
  - Message: "Forum is being upgraded. Read-only until [time]."
- [ ] Disable email notifications from phpBB
- [ ] Stop any scheduled jobs

**Verification Checklist:**
- [ ] Cannot create new topics
- [ ] Cannot reply to existing topics
- [ ] Cannot send private messages
- [ ] Can still read all content
- [ ] Search still works
- [ ] Maintenance message visible

### During Freeze

**Activities:**
1. Final database backup (full)
2. Final attachments backup (full)
3. Database export for migration
4. Run Discourse import script
5. Validation checks
6. DNS cutover (if applicable)
7. Final smoke tests

**Status Updates:**
- Update status page every [X minutes]
- Communication channel: [Discord/Email/Twitter]

---

## Rollback Posture

### Rollback Criteria

**Automatic Rollback (Critical Issues):**
- Data loss > 1% of posts/users
- Attachments not accessible
- Import fails completely
- Database corruption detected
- Security vulnerability discovered

**Considered Rollback (Major Issues):**
- URL redirects fail for >10% of links
- Login failure rate >20%
- Performance degradation (>5s page load)
- Major feature broken (search, attachments)

**Acceptable Issues (No Rollback):**
- Minor formatting issues (<5% of posts)
- Individual user login problems (<5%)
- Non-critical feature issues
- Cosmetic problems

### Rollback Decision Process

**Decision Authority:**
- Lead Admin: Primary decision maker
- Technical Admin: Technical feasibility assessment
- Community Admin: User impact assessment

**Decision Timeline:**
- Issues detected: Immediate assessment
- Decision deadline: [X hours] after go-live
- After deadline: Forward-fix only (no rollback)

**Communication:**
- Internal: Notify all admins immediately
- External: Prepare rollback announcement template

### Rollback Procedure

**If rollback is triggered:**

**Step 1: Freeze New System (5 minutes)**
- [ ] Put Discourse into read-only mode
- [ ] Display "Experiencing issues, reverting" message

**Step 2: Restore Old System (15 minutes)**
- [ ] Revert DNS to phpBB (if changed)
- [ ] Re-enable phpBB read-write mode
- [ ] Verify phpBB accessibility
- [ ] Test post creation

**Step 3: Communication (Immediate)**
- [ ] Announce rollback to users
- [ ] Explain reason (high-level)
- [ ] Provide timeline for next attempt
- [ ] Apologize for inconvenience

**Step 4: Post-Rollback Analysis (24 hours)**
- [ ] Document what went wrong
- [ ] Update migration plan
- [ ] Fix identified issues
- [ ] Schedule next attempt

**Maximum Rollback Time:** [30 minutes] from decision to phpBB back online

---

## Old Forum Status Post-Cutover

### Immediate Post-Cutover (First 24-48 hours)

**Strategy Options:**

#### Option A: Immediate Redirect
- [ ] All phpBB URLs redirect to Discourse immediately
- [ ] phpBB site offline
- ✅ Clean cutover
- ❌ No fallback for users with issues

#### Option B: Read-Only Grace Period
- [ ] phpBB remains accessible (read-only)
- [ ] Prominent banner: "Forum has moved to [new URL]"
- [ ] Duration: [24-48 hours]
- ✅ Users can still access old site if needed
- ✅ Reference for validation
- ❌ Confusion about which site to use

#### Option C: Gradual Redirect
- [ ] phpBB accessible but with redirect timer
- [ ] "Redirecting to new forum in 10 seconds... [Skip]"
- [ ] Duration: [1 week]
- ✅ Smooth transition
- ❌ Maintains two sites temporarily

**Selected Option:** [A/B/C]

**Rationale:** [Explanation]

---

### Long-Term Archive Strategy (30+ days post-cutover)

**Strategy Options:**

#### Option 1: Full Shutdown
- phpBB completely offline
- All URLs redirect to Discourse
- Old server decommissioned

#### Option 2: Static Archive
- phpBB converted to static HTML
- Read-only, no search
- Available at archive.forum.example.com
- Maintained for [X years]

#### Option 3: Parallel Read-Only
- phpBB kept online indefinitely (read-only)
- Separate subdomain: old.forum.example.com
- No new content, just historical reference

**Selected Option:** [1/2/3]

**Timeline:**
- T+30 days: [Action]
- T+90 days: [Action]
- T+1 year: [Final status]

---

## Redirect Strategy

### URL Redirection Rules

**Critical URLs (Must redirect):**
- Topic URLs: `viewtopic.php?t={id}` → `/t/{slug}/{id}`
- Forum URLs: `viewforum.php?f={id}` → `/c/{category}/{id}`
- User profiles: `memberlist.php?u={id}` → `/u/{username}`
- Search: `search.php` → `/search`

**Implementation:**
- [ ] Use Discourse's built-in permalink system
- [ ] Nginx/Apache redirect rules
- [ ] Test with sample URLs

**See:** [Phase 6: Link Preservation](../phase6-link-preservation/) for full redirect strategy

---

## DNS and Infrastructure Cutover

### DNS Change Strategy

**Option A: DNS Cutover**
- Change A record for forum.example.com
- TTL: [Lower to 300s before migration]
- Propagation time: Up to 24 hours

**Option B: Reverse Proxy**
- Keep DNS same
- Change backend server
- Instant cutover

**Option C: New Subdomain**
- Launch at discourse.forum.example.com
- Redirect from old domain
- Gradual migration

**Selected:** [Option]

### SSL/TLS Certificates

- [ ] New certificate provisioned for Discourse
- [ ] Verify HTTPS working
- [ ] Test certificate chain

---

## Smoke Test Checklist

**Before declaring "Go Live":**

### Core Functionality
- [ ] Homepage loads
- [ ] Can log in (test 5 different user accounts)
- [ ] Can create new topic
- [ ] Can reply to topic
- [ ] Can upload image
- [ ] Can search
- [ ] Email notifications sending

### Content Verification
- [ ] Spot check 20 random topics (content intact)
- [ ] Spot check 20 random users (profile data correct)
- [ ] Check oldest topic (1st post ever)
- [ ] Check newest topic (last before freeze)
- [ ] Verify attachments load (10 random)

### Redirects
- [ ] Test 10 old phpBB URLs (should redirect)
- [ ] Test non-existent URL (should 404)

### Performance
- [ ] Page load time < [X seconds]
- [ ] Search responds in < [X seconds]
- [ ] Server resources within limits (CPU, memory)

### Critical Features
- [ ] Markdown formatting works
- [ ] Code blocks render correctly
- [ ] Greek characters display properly
- [ ] Trust level system functioning
- [ ] Moderation tools accessible

**Go/No-Go Decision:**
- All critical items: PASS
- <2 major issues: PASS with notes
- ≥2 major issues: Consider rollback

---

## Communication Templates

### Pre-Freeze Announcement (T-24 hours)

**Subject:** Forum Upgrade Tomorrow - Brief Maintenance

**Body:**
```
Dear SHMMY Community,

Tomorrow [DATE] at [TIME UTC], we will be upgrading our forum to a modern platform (Discourse). 

During the upgrade (approximately [X] hours):
- Forum will be READ-ONLY (you can browse but not post)
- We'll migrate all posts, topics, and user accounts
- Your content and history will be preserved

After the upgrade:
- Check your email for a password reset link
- Enjoy a faster, more modern forum experience
- Mobile experience significantly improved

Questions? See our FAQ: [LINK]

Thank you for your patience!
- The Admin Team
```

---

### During Freeze Status Update

**Update every 2 hours:**

```
Migration Status Update [HH:MM UTC]

✅ Database exported
✅ Import running: [X%] complete
⏳ Estimated completion: [HH:MM UTC]

Stay tuned for the next update!
```

---

### Go-Live Announcement

**Subject:** Forum Upgrade Complete - Welcome to the New Platform!

**Body:**
```
Dear SHMMY Community,

Great news! Our forum upgrade is complete. 

🚀 New forum: [URL]

Getting Started:
1. Click "Forgot Password" and enter your email
2. Check your email for the password reset link
3. Set your new password and log in
4. Explore the new features!

What's New:
- Modern, responsive design
- Better mobile experience
- Improved search
- Real-time updates
- [Other key features]

Your username: [List if changed]

Need help? Visit our FAQ: [LINK] or contact: [EMAIL]

Welcome to the new era of our community!

- The Admin Team
```

---

### Rollback Announcement (If Needed)

**Subject:** Forum Upgrade - Technical Issues, Reverting to Previous Version

**Body:**
```
Dear SHMMY Community,

We encountered technical issues during today's forum upgrade and have decided to revert to the previous phpBB version to ensure no data is lost.

Status:
- Old forum is back online at [URL]
- All data is intact
- You can post as normal

Next Steps:
- We're analyzing the issues
- We'll fix them before attempting again
- New migration date: [TBD - will announce soon]

We apologize for the inconvenience and appreciate your patience.

- The Admin Team
```

---

## Success Criteria

**Cutover is successful if:**
- [ ] All content migrated (>99%)
- [ ] Users can log in (>95% success rate within 24h)
- [ ] No data loss
- [ ] Redirects working (>90%)
- [ ] Performance acceptable
- [ ] No rollback needed
- [ ] Community feedback positive

---

## Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Technical Lead | | | |
| Lead Admin | | | |
| Community Admin | | | |

**Version:** 1.0  
**Last Updated:** [Date]
