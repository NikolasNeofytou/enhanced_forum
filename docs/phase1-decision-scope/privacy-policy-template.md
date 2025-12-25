# Privacy and Data Policy Template

## Data Retention Policy

### Active Users and Content

#### User Accounts
- **Retention:** Indefinite while account is active
- **Data stored:**
  - Username, email, profile information
  - Posts, topics, messages
  - Trust level, badges, achievements
  - Login history, IP addresses (last 30 days)
  - Preferences and settings

#### Posts and Topics
- **Retention:** Indefinite
- **Modifications:** Edit history retained for [X days/indefinitely]
- **Deleted content:** Soft delete (recoverable by admins for [X days])

### Inactive Users

**Definition:** Users who have not logged in for [12/24/36] months

**Policy:**
- [ ] Option A: Retain all data indefinitely
- [ ] Option B: Email notification after X months of inactivity
- [ ] Option C: Archive and anonymize after X months
- [ ] Option D: Delete after X months (with prior notification)

**Selected:** [Choice]

### Deleted User Data

#### User-Initiated Account Deletion

**Process:**
1. User requests deletion via [method]
2. Verification step (email confirmation)
3. Grace period: [X days] for user to cancel
4. Deletion executed

**What gets deleted:**
- Personal information (email, profile data)
- Private messages
- User preferences

**What gets retained (anonymized):**
- Posts and topics (attributed to "deleted user")
- Public contributions to discussions
- Rationale: Preserves discussion continuity and community knowledge

**Alternative (full deletion):**
- [ ] Delete all user content
- [ ] Note: May break discussion threads

### Deleted Posts

#### User-Deleted Posts
- **Soft delete:** [X days] (recoverable by moderators)
- **Hard delete:** After [X days] or immediately if [criteria]
- **Edit history:** Retained for [X days]

#### Moderator-Deleted Posts
- **Soft delete:** [X days]
- **Reason stored:** Yes/No
- **User notification:** Yes/No
- **Appeal process:** [Description]

## GDPR Compliance

### Right to Access (Article 15)

**Process:**
1. User submits request via [email/form]
2. Identity verification: [Method]
3. Response timeline: Within 30 days
4. Data provided in [format]

**Data package includes:**
- All personal data stored
- Source of data
- Purposes of processing
- Recipients of data
- Retention period
- Export of all posts, messages, and content

**Implementation:**
- Discourse has built-in data export feature
- Admin path: `Admin → Users → [Username] → Export user data`

### Right to Rectification (Article 16)

**Process:**
- Users can update their own profile information
- For locked data: Submit request to [email/contact]
- Verification and update within [X] days

### Right to Erasure / "Right to be Forgotten" (Article 17)

**Implementation Options:**

#### Option A: Full Anonymization (Recommended)
- Personal data removed
- Username changed to "deleted_user_[ID]"
- Email removed
- Posts remain, attributed to anonymized account
- ✅ Preserves community knowledge
- ✅ Maintains discussion threads
- ❌ Content still exists

#### Option B: Full Deletion
- All user data deleted
- All posts deleted or reassigned
- ❌ Breaks discussion threads
- ❌ Loses community knowledge

**Selected Approach:** [A/B]

**Exceptions (per GDPR Article 17.3):**
- Legal obligations
- Public interest
- Legal claims

**Process:**
1. Request submitted via [method]
2. Verification of identity
3. Review for exceptions
4. Execution within 30 days
5. Confirmation sent to user

### Right to Data Portability (Article 20)

**Implementation:**
- Use Discourse's export feature
- Format: JSON
- Includes: Posts, topics, messages, profile data
- Timeline: Within 30 days

### Right to Object (Article 21)

**User rights:**
- Object to processing for direct marketing
- Object to automated decision-making

**Our usage:**
- No direct marketing
- No automated decision-making
- Trust levels are algorithm-based but user-visible and appealable

### Data Breach Notification (Article 33-34)

**Process:**
1. Detection and assessment
2. Containment and mitigation
3. Notification to supervisory authority within 72 hours
4. User notification if high risk
5. Documentation and review

**Breach response team:**
- Lead: [Technical Admin]
- Communication: [Community Admin]
- Legal: [Contact]

## Privacy Policy

### Data Collection

**What we collect:**
- Account information: username, email, password (hashed)
- Profile information: bio, location (optional)
- Content: posts, topics, replies, uploads
- Usage data: login times, last seen, reading time
- Technical data: IP address (last 30 days), browser/device info

**Why we collect:**
- Provide forum services
- Trust level calculation
- Spam prevention
- Moderation and safety
- Improve user experience

### Data Sharing

**We do NOT share data with third parties, except:**
- Legal obligations
- Service providers (hosting, email)
- With user consent

### Cookies

**Essential cookies:**
- Session management
- Authentication
- Preferences

**Analytics cookies (if applicable):**
- [ ] We use [analytics tool]
- [ ] Users can opt out via [method]

### Data Security

**Measures:**
- Encrypted connections (HTTPS)
- Hashed passwords
- Regular backups (encrypted)
- Access controls (admin only)
- Regular security updates

### International Transfers

**If applicable:**
- Data stored in [region/country]
- Safeguards: [EU-US Privacy Shield / Standard Contractual Clauses / etc.]

### User Rights Summary

Users have the right to:
- Access their data
- Correct their data
- Delete their data (with limitations)
- Export their data
- Object to processing
- Lodge a complaint with supervisory authority

**Contact for privacy requests:** [email]

## Children's Privacy

- Forum is intended for [age 13+ / 16+ / 18+]
- No knowing collection from children under [age]
- If notified of underage user, account will be deleted

## Updates to Privacy Policy

- Changes will be posted with [X days] notice
- Major changes will trigger email notification
- Continued use after notification implies acceptance

## Data Migration Specific

### Legacy phpBB Data

**What we're migrating:**
- All historical posts and topics (with original timestamps)
- User accounts (username, email if available)
- Attachments and uploads
- Private messages (if applicable)

**What we're NOT migrating:**
- phpBB-specific data (e.g., visit counters)
- Old IP logs (only recent if needed)
- Banned user logs (recreate in Discourse)

**User notification:**
- All users will be notified of migration
- Privacy policy changes communicated
- Users can opt-out by [method] before migration

## Contact Information

**Data Controller:** [Organization name]  
**Address:** [Address]  
**Email:** [privacy@example.com]  
**Phone:** [Phone]

**Data Protection Officer (if applicable):** [Name, Contact]

**Supervisory Authority:** [Relevant GDPR authority]

## Approval

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Legal Review | | | |
| Technical Admin | | | |
| Lead Admin | | | |

**Last Updated:** [Date]  
**Version:** 1.0
