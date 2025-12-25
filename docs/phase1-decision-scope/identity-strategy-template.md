# Identity Strategy Template

## Identity Management Approach

### Strategy Options

#### Option A: Import Existing Accounts (Recommended for Cutover)

**Overview:**
- Migrate all existing phpBB user accounts to Discourse
- Users retain their username and post history
- Users must reset passwords via email after migration

**✅ Advantages:**
- Lower complexity and risk
- Smoother cutover experience
- Complete user history preservation
- No account matching issues
- Proven migration path

**❌ Disadvantages:**
- No central identity management
- Users must reset passwords
- Email addresses must be valid for password reset
- Duplicate accounts may exist

**Implementation Requirements:**
- Valid email address for each user
- Username normalization rules
- Password reset email templates
- User communication plan

---

#### Option B: SSO from Day-1 (University Authentication)

**Overview:**
- Implement DiscourseConnect SSO at migration
- Users authenticate via university identity system
- Link existing accounts to university identities

**✅ Advantages:**
- Central identity management
- Single sign-on convenience
- No password management needed
- Consistent with university systems

**❌ Disadvantages:**
- Higher complexity at cutover
- Risk of account matching failures
- Alumni/non-university users excluded
- More testing required
- Potential for login failures

**Implementation Requirements:**
- DiscourseConnect SSO integration
- University identity provider integration
- Account matching algorithm (email-based)
- Fallback for unmatched accounts
- Alumni access strategy

---

#### Option C: Hybrid Approach

**Overview:**
- Import accounts at cutover (Option A)
- Add SSO post-launch after stabilization
- Gradual SSO adoption

**✅ Advantages:**
- Best of both worlds
- Low-risk cutover
- Future-proof architecture
- Time to test SSO properly

**❌ Disadvantages:**
- Two-phase implementation
- Temporary password management

**Implementation Timeline:**
- Phase 1 (Cutover): Import all accounts
- Phase 2 (Month 2-3): Implement and test SSO
- Phase 3 (Month 4): Enable SSO, allow account linking

---

### Selected Strategy

**Decision:** [ ] Option A  [ ] Option B  [ ] Option C

**Rationale:**
[Explain why this option was chosen for your context]

**Timeline:**
[If hybrid, specify timeline for each phase]

---

## Username Mapping Rules

### phpBB to Discourse Username Constraints

Discourse has stricter username requirements than phpBB:

**Discourse Requirements:**
- 3-20 characters (configurable)
- Alphanumeric and underscores only (no spaces)
- No special characters (e.g., ., -, !)
- Case-insensitive (unique lowercase)
- Reserved usernames blocked (admin, support, etc.)

### Mapping Strategy

#### Rule 1: Direct Mapping
- If phpBB username meets Discourse requirements → Keep as-is
- Example: `john_smith` → `john_smith` ✅

#### Rule 2: Character Substitution
- Replace invalid characters with underscores
- Example: `john.smith` → `john_smith`
- Example: `user-123` → `user_123`

#### Rule 3: Space Removal
- Remove spaces
- Example: `John Smith` → `JohnSmith`

#### Rule 4: Length Adjustment
- If < 3 characters, pad with numbers
- If > 20 characters, truncate and add numeric suffix
- Example: `ab` → `ab_1`
- Example: `verylongusernamethatexceeds` → `verylongusername_1`

#### Rule 5: Collision Resolution
- If transformed username already exists, append numbers
- Example: `john_smith` (collision) → `john_smith_2`

#### Rule 6: Manual Review Queue
- Heavily modified usernames flagged for review
- Users notified of username changes
- Option to request username change post-migration

### Implementation

```python
# Pseudocode for username transformation
def transform_username(phpbb_username):
    # Step 1: Convert to lowercase
    username = phpbb_username.lower()
    
    # Step 2: Replace invalid characters
    username = re.sub(r'[^a-z0-9_]', '_', username)
    
    # Step 3: Remove consecutive underscores
    username = re.sub(r'_+', '_', username)
    
    # Step 4: Trim underscores from ends
    username = username.strip('_')
    
    # Step 5: Length check
    if len(username) < 3:
        username = username + '_1'
    elif len(username) > 20:
        username = username[:17] + '_1'
    
    # Step 6: Check for collision and append number if needed
    if username_exists(username):
        counter = 2
        while username_exists(f"{username}_{counter}"):
            counter += 1
        username = f"{username}_{counter}"
    
    return username
```

---

## Email Validation

### Email Requirements

**For Password Reset (Option A):**
- Valid, deliverable email address required
- Email must not bounce

**For SSO (Option B/C):**
- Email used for account matching
- Must match university email format (if applicable)

### Email Validation Strategy

#### Pre-Migration Email Audit
- [ ] Export all user emails from phpBB
- [ ] Check for:
  - Empty email addresses
  - Invalid formats (e.g., `user@localhost`)
  - Duplicate emails
  - Non-deliverable domains
  - Role accounts (e.g., `admin@`, `noreply@`)

#### Email Handling Rules

**Valid Email:**
- Import as-is
- User can reset password

**Invalid/Missing Email:**
- [ ] Option 1: Generate placeholder email (e.g., `user_{id}@forum.placeholder`)
- [ ] Option 2: Flag account, require manual activation
- [ ] Option 3: Exclude from migration (only for spam accounts)

**Duplicate Emails:**
- [ ] Keep first account, flag others
- [ ] Attempt to contact users pre-migration
- [ ] Manual resolution required

**Selected Approach:** [Choice]

### Email Notification Plan

**Pre-Migration:**
- [ ] Email all users with valid addresses (T-2 weeks)
- [ ] Content: Migration announcement, password reset info
- [ ] Track bounces and update email status

**Post-Migration:**
- [ ] Welcome email with password reset instructions
- [ ] Stagger sending to avoid rate limits
- [ ] Monitor deliverability

---

## Duplicate Account Resolution

### Detection Strategy

**Pre-Migration Analysis:**
- [ ] Check for duplicate usernames (case-insensitive)
- [ ] Check for duplicate emails
- [ ] Check for suspicious patterns (sequential IDs, similar names)

### Resolution Options

**Duplicate Usernames:**
- Apply username transformation rules
- Append numbers to duplicates

**Duplicate Emails:**
- [ ] Keep most recent account
- [ ] Keep account with most posts
- [ ] Merge accounts (complex, risky)
- [ ] Flag for manual review

**Selected Approach:** [Choice]

---

## Inactive and Banned Users

### Inactive Users

**Definition:** Users who have never posted or not logged in for [X] years

**Strategy:**
- [ ] Import all users (preserve community history)
- [ ] Import only users with posts
- [ ] Import only users active in last [X] years

**Selected:** [Choice]

**Rationale:** [Explanation]

### Banned Users

**Strategy:**
- [ ] Import as suspended in Discourse
- [ ] Import but exclude from migration (permanent ban)
- [ ] Review bans, decide case-by-case

**Selected:** [Choice]

**Implementation:**
- [ ] Export phpBB banned users list
- [ ] Map to Discourse suspension system
- [ ] Set suspension end dates (if applicable)
- [ ] Document ban reasons

---

## SSO Implementation (If Applicable)

### DiscourseConnect Configuration

**SSO Provider:** [University identity system / Custom]

**Endpoints:**
- SSO URL: [URL]
- SSO Secret: [How managed - e.g., environment variable]

**User Attributes Mapped:**
- External ID: [University ID / Student Number]
- Email: [University email]
- Username: [Derived from email or provided]
- Name: [Full name from directory]

### Account Linking Strategy

**For Existing Users:**
- Match by email address
- User confirms linking on first SSO login
- Option to manually link accounts

**For New Users:**
- Auto-create account on first SSO login

### Fallback Mechanism

**If SSO fails:**
- [ ] Allow local password login (temporary)
- [ ] Display error message with support contact
- [ ] Alert admin team

---

## Communication Plan

### Pre-Migration

**T-4 weeks:**
- Announcement: Migration coming, identity approach
- FAQ: Password reset, username changes

**T-2 weeks:**
- Email: Verify your email address
- Action required: Update email if invalid

**T-1 week:**
- Reminder: Migration date, expect password reset email

### During Migration

- Status updates: Every 2 hours during cutover
- Expected actions: Check email for password reset

### Post-Migration

**Day 1:**
- Welcome email with:
  - Password reset link
  - New username (if changed)
  - Getting started guide
  - Support contact

**Week 1:**
- FAQ update based on common issues
- Follow-up for users who haven't logged in

---

## Success Criteria

- [ ] 95%+ users can log in via password reset
- [ ] All username conflicts resolved
- [ ] Email deliverability > 95%
- [ ] User satisfaction with identity transition (survey)
- [ ] Clear process for users with issues

---

## Support Plan

### Help Resources

**Password Reset Issues:**
- Self-service: Password reset page
- Documentation: FAQ
- Support: [Email/contact]

**Username Changes:**
- Self-service: Profile settings (post-login)
- Request: [Email/form]
- Processing time: [X days]

**Email Address Updates:**
- Self-service: Profile settings
- Verification required: Yes

### Support Team

**Contacts:**
- Identity issues: [Email]
- Technical issues: [Email]
- Response time: [SLA]

---

## Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Technical Lead | | | |
| Community Admin | | | |
| Security/Compliance | | | |

**Version:** 1.0  
**Last Updated:** [Date]
