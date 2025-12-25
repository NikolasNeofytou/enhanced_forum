# Phase 7: Authentication Strategy

## Objective

Define and implement user authentication approach.

## Overview

This phase is closely tied to the Identity Strategy defined in Phase 1. Here we implement the technical aspects of the chosen approach.

---

## Option A: Import-Only (Password Reset)

**Best for initial cutover** - Low risk, proven approach

### How It Works

1. **During migration:**
   - Import all user accounts from phpBB
   - Passwords are NOT migrated (security best practice)
   - Email addresses preserved (if valid)

2. **Post-migration:**
   - Users click "Forgot Password"
   - Receive password reset email
   - Set new password
   - Log in normally

### Implementation

**No special configuration needed** - Discourse standard behavior

**Email templates to customize:**

```ruby
# Admin → Customize → Email Templates → Password Reset

Subject: Reset Your Password for New Forum

Body:
Welcome to our upgraded forum!

As part of the migration to our new platform, you'll need to reset your password.

Click the link below to set a new password:
%{reset_password_url}

Your username: %{username}
This link expires in 24 hours.

Questions? Reply to this email or visit /t/migration-faq

Thanks!
The Forum Team
```

### User Communication

**Email to all users on Day 1:**

```markdown
Subject: Forum Upgraded - Please Reset Your Password

Dear SHMMY Community Member,

Great news! Our forum has been upgraded to a modern platform (Discourse).

**Getting Started:**

1. Visit: https://forum.example.com
2. Click "Log In" → "Forgot Password"
3. Enter your email: [user.email]
4. Check your email for reset link
5. Set a new password

**Your Information:**
- Username: [user.username]
- Email: [user.email]
- All your posts and history are preserved!

**Need Help?**
- Visit: /t/migration-help
- Email: support@example.com

Welcome to the new forum!

- The Admin Team
```

### Troubleshooting Setup

**Common user issues:**

1. **"I didn't receive reset email"**
   - Check spam folder
   - Verify email address is correct
   - Admin can manually activate: Admin → Users → [User] → Send Password Reset Email

2. **"I don't remember my email"**
   - User contacts support
   - Admin verifies identity (security questions, old posts, etc.)
   - Admin updates email: Admin → Users → [User] → Edit
   - Send reset email

3. **"My email is no longer valid"**
   - User contacts support with proof of identity
   - Admin updates email address
   - Send reset email

**Support workflow:**
```
User Request → Verify Identity → Update Email (if needed) → Send Reset → Confirm Login
```

---

## Option B: DiscourseConnect SSO (University Integration)

**Best for long-term** - Centralized identity management

### Overview

**DiscourseConnect** (formerly Discourse SSO) is the official SSO mechanism.

**Official docs:** [DiscourseConnect](https://meta.discourse.org/t/discourseconnect-official-single-sign-on-for-discourse-sso/13045)

### Architecture

```
User → University SSO Server → DiscourseConnect → Discourse
                               (HMAC signed payload)
```

**Flow:**
1. User clicks "Log In" on Discourse
2. Redirected to university SSO server
3. User authenticates (university credentials)
4. SSO server redirects back to Discourse with signed payload
5. Discourse validates signature, creates/updates user account
6. User is logged in

### Implementation Requirements

**On University SSO side:**
- Endpoint to receive login requests from Discourse
- Authenticate user (university credentials)
- Return signed payload with user info

**On Discourse side:**
- Configure DiscourseConnect settings
- Shared secret with SSO server
- User attribute mapping

### Discourse Configuration

**Admin → Settings → Login:**

```yaml
enable_discourse_connect: true
discourse_connect_url: https://sso.university.edu/discourse-login
discourse_connect_secret: [generate strong random secret]
discourse_connect_overrides_email: true
discourse_connect_overrides_username: true
discourse_connect_overrides_name: true
```

**Or via app.yml:**

```yaml
env:
  DISCOURSE_ENABLE_DISCOURSE_CONNECT: true
  DISCOURSE_DISCOURSE_CONNECT_URL: "https://sso.university.edu/discourse-login"
  DISCOURSE_DISCOURSE_CONNECT_SECRET: "your-secret-key-keep-this-safe"
  DISCOURSE_DISCOURSE_CONNECT_OVERRIDES_EMAIL: true
  DISCOURSE_DISCOURSE_CONNECT_OVERRIDES_USERNAME: true
```

### SSO Server Implementation

**Example SSO endpoint (Ruby/Sinatra):**

```ruby
require 'sinatra'
require 'openssl'
require 'base64'

# Configuration
DISCOURSE_URL = 'https://forum.example.com'
DISCOURSE_SECRET = ENV['DISCOURSE_CONNECT_SECRET']

get '/discourse-login' do
  # 1. Validate request from Discourse
  sso = params['sso']
  sig = params['sig']
  
  # Verify signature
  expected_sig = OpenSSL::HMAC.hexdigest('SHA256', DISCOURSE_SECRET, sso)
  halt 403, 'Invalid signature' unless sig == expected_sig
  
  # 2. Decode payload
  decoded = Base64.decode64(sso)
  sso_params = CGI.parse(decoded)
  nonce = sso_params['nonce'].first
  return_sso_url = sso_params['return_sso_url'].first
  
  # 3. Authenticate user (university authentication)
  # ... your authentication logic ...
  # For example, check if user is logged into university system
  
  unless user_authenticated?
    # Redirect to university login, then come back here
    session[:return_to] = request.url
    redirect '/university-login'
  end
  
  # 4. Get user info from university system
  university_user = get_current_university_user
  
  # 5. Build response payload
  payload = {
    'nonce' => nonce,
    'email' => university_user.email,
    'external_id' => university_user.student_id,  # Unique university ID
    'username' => generate_username(university_user),  # From email or name
    'name' => university_user.full_name,
    'avatar_url' => university_user.photo_url,  # Optional
    'groups' => university_user.groups.join(','),  # Optional: auto-add to groups
    # Optional fields:
    # 'admin' => 'true',  # Make user admin
    # 'moderator' => 'true',  # Make user moderator
    # 'bio' => university_user.bio,
  }
  
  # 6. Encode and sign response
  response_payload = URI.encode_www_form(payload)
  encoded_payload = Base64.strict_encode64(response_payload)
  response_sig = OpenSSL::HMAC.hexdigest('SHA256', DISCOURSE_SECRET, encoded_payload)
  
  # 7. Redirect back to Discourse
  redirect "#{return_sso_url}?sso=#{CGI.escape(encoded_payload)}&sig=#{response_sig}"
end

def generate_username(university_user)
  # Extract from email: john.doe@university.edu → johndoe
  email_local = university_user.email.split('@').first
  email_local.gsub(/[^a-z0-9]/, '').downcase[0..19]
end
```

### Account Linking (Migrated Users)

**Challenge:** Existing users from phpBB need to link to SSO

**Solution 1: Email-based matching (automatic)**
- When SSO user logs in, match by email
- If email exists in Discourse, link accounts
- Update external_id to university ID

```ruby
# In Discourse plugin or console
# This happens automatically if emails match
# But you can force it:

User.find_each do |user|
  # Skip if already has external_id (already linked)
  next if user.single_sign_on_record
  
  # Match by email to university system
  university_user = UniversityAPI.find_by_email(user.email)
  
  if university_user
    user.create_single_sign_on_record!(
      external_id: university_user.student_id,
      external_email: university_user.email
    )
    puts "Linked: #{user.username} → #{university_user.student_id}"
  end
end
```

**Solution 2: Manual linking (for unmatched accounts)**
- User logs in with university credentials (creates new account)
- Notices their old posts are under different username
- Admin manually merges accounts: Admin → Users → Merge

### Fallback for Non-University Users

**Problem:** Alumni, guests, external users don't have university credentials

**Solution A: Hybrid mode**
```yaml
# Allow both SSO and local login
enable_local_logins: true
enable_discourse_connect: true
```
- University users: SSO
- Others: Local password

**Solution B: Guest accounts**
- Create special group: "Alumni"
- Alumni register with email (no university SSO)
- Manual approval process

**Solution C: SSO with exceptions**
- Most users: SSO required
- Whitelist: Certain emails can use local login
- Configured per-user

---

## Option C: Hybrid Approach (Phased)

**Recommended for large migrations** - Low-risk cutover, future-proof

### Phase 1: Cutover (Import-Only)

**Timing:** Migration day

**Implementation:**
- Import all accounts
- Users reset passwords
- Standard Discourse authentication

**Duration:** 1-3 months

**Goal:** Stabilize platform, validate user base

### Phase 2: SSO Implementation

**Timing:** After stabilization (Month 2-3)

**Implementation:**
1. Set up university SSO integration
2. Test on staging
3. Link existing accounts by email
4. Enable SSO alongside local login (hybrid)

**Duration:** 1-2 months

**Goal:** Implement and test SSO without disrupting current users

### Phase 3: SSO Migration

**Timing:** After SSO testing (Month 4)

**Implementation:**
1. Announce SSO availability
2. Encourage users to link accounts (one-time SSO login)
3. Monitor adoption rate

**Metrics:**
- % of users linked to SSO
- Login failures
- Support requests

### Phase 4: SSO Enforcement (Optional)

**Timing:** After high adoption (Month 6+)

**Implementation:**
```yaml
enable_local_logins: false
enable_discourse_connect: true
```

**Prerequisites:**
- >90% of active users linked to SSO
- Alumni access plan in place
- Rollback plan ready

---

## Security Considerations

### Password Migration (Don't!)

**Never migrate password hashes from phpBB to Discourse**

**Why not:**
- Different hashing algorithms (phpBB: MD5/bcrypt, Discourse: bcrypt/pbkdf2)
- Security risk if hashes compromised
- Best practice: Force new passwords

### Account Takeover Prevention

**During password reset period:**

1. **Email verification required**
   - Only valid emails can reset passwords

2. **Rate limiting:**
   - Limit reset emails per hour
   - Prevent brute-force attacks

3. **Monitor for abuse:**
   - Watch for multiple accounts accessed from same IP
   - Flag suspicious activity

4. **Two-factor authentication:**
   - Encourage users to enable 2FA post-login
   - Admin → Settings → Enable 2FA

### SSO Security

**Shared secret management:**
- Use strong random secret (32+ characters)
- Store securely (environment variable, not in git)
- Rotate periodically (every 6-12 months)

**HTTPS required:**
- All SSO communication must be over HTTPS
- Invalid or self-signed certificates rejected

**Payload validation:**
- Always verify HMAC signature
- Check nonce uniqueness (prevent replay attacks)
- Validate email format

---

## Implementation Checklist

### For Option A (Import-Only)

- [ ] Email templates customized
- [ ] Welcome email prepared
- [ ] FAQ page created (/t/migration-faq)
- [ ] Support workflow documented
- [ ] Support team trained
- [ ] Email deliverability tested
- [ ] Password reset tested (10+ test accounts)

### For Option B (SSO)

- [ ] DiscourseConnect configuration documented
- [ ] Shared secret generated and stored securely
- [ ] SSO endpoint implemented and tested
- [ ] User attribute mapping defined
- [ ] Account linking tested (email match)
- [ ] Fallback for non-university users planned
- [ ] SSO tested with 10+ test accounts
- [ ] Error handling tested
- [ ] Documentation for users created

### For Option C (Hybrid)

- [ ] Phase 1 (import-only) checklist complete
- [ ] Phase 2 (SSO implementation) timeline defined
- [ ] SSO integration development started
- [ ] Testing plan for SSO created
- [ ] Communication plan for SSO rollout
- [ ] Metrics defined for SSO adoption

---

## User Documentation

### Password Reset Guide

**Create at: /t/how-to-reset-password**

```markdown
# How to Reset Your Password

After the migration, all users need to create a new password.

## Steps:

1. Go to https://forum.example.com
2. Click **Log In**
3. Click **Forgot Password?**
4. Enter your email address
5. Check your email for a reset link
6. Click the link and set a new password

## Troubleshooting:

**I didn't receive the email:**
- Check your spam folder
- Wait 5 minutes and try again
- Email us at support@example.com

**I don't remember my email:**
- Email support@example.com with:
  - Your username
  - 2-3 recent posts you made
  - We'll help you recover your account

**My email is no longer valid:**
- Email support@example.com
- We'll update your email after verifying your identity
```

### SSO Guide (if applicable)

**Create at: /t/how-to-use-university-login**

```markdown
# How to Log In with University Credentials

You can now log in using your university account!

## For New Users:

1. Click **Log In**
2. You'll be redirected to the university login page
3. Enter your university credentials
4. You'll be redirected back and logged in automatically

## For Existing Users (Account Linking):

If you had an account before SSO:

1. Log in with university credentials (first time)
2. Your accounts will be automatically linked by email
3. All your posts and history remain intact

If emails don't match, contact support@example.com

## Alumni / External Users:

Don't have university credentials? Email support@example.com
We'll set up a local account for you.
```

---

## Deliverables

- [ ] **Auth decision record** (from Phase 1, finalized)
- [ ] **Implementation checklist** (above)
- [ ] **Technical documentation** (SSO if applicable)
- [ ] **User guides** (password reset, SSO)
- [ ] **Support workflow** (handling auth issues)
- [ ] **Testing results** (auth tested with diverse users)

---

## Success Criteria

- [ ] 95%+ of users can log in
- [ ] Email reset process works smoothly
- [ ] Support requests manageable (<10% of users)
- [ ] No account takeover incidents
- [ ] SSO working (if implemented)
- [ ] User satisfaction with auth process

---

## Next Steps

Once Phase 7 is complete, proceed to [Phase 8: Feature Parity and Modernization](../phase8-feature-parity/)
