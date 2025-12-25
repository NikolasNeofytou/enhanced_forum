# Migration Decision & Scope Document

**Project:** SHMMY/ECE NTUA Forum Migration (phpBB → Discourse)  
**Date:** [Insert Date]  
**Version:** 1.0  
**Status:** [Draft / Under Review / Approved]

## Executive Summary

We are migrating the SHMMY/ECE NTUA forum from phpBB to Discourse to improve user experience, moderation capabilities, and search functionality while preserving all existing content and user identities.

**Current Scale:**
- 837,201 posts
- 21,849 topics
- 11,362 members

## What Changes

### Platform
- **FROM:** phpBB [version]
- **TO:** Discourse [target version]

### User Experience
- Modern, responsive interface
- Improved mobile experience
- Better search capabilities
- Enhanced notification system
- Trust-level based permissions

### Technical Infrastructure
- **FROM:** [Current hosting setup]
- **TO:** Docker-based Discourse deployment
- S3-compatible object storage for attachments (if needed)

## What Does NOT Change

### Content Preservation
- ✅ All posts preserved
- ✅ All topics preserved
- ✅ All user accounts preserved
- ✅ All attachments preserved
- ✅ Historical timestamps maintained

### URL Integrity
- ✅ Old phpBB links will redirect to corresponding Discourse content
- ✅ SEO rankings preserved

### Community Identity
- ✅ Same community, same content
- ✅ Existing usernames preserved (subject to Discourse constraints)
- ✅ User histories and reputation preserved

## Governance

### Administrators (Day-1)
| Name | Role | Responsibilities |
|------|------|------------------|
| [Name] | Lead Admin | Overall platform management |
| [Name] | Technical Admin | Infrastructure and troubleshooting |
| [Name] | Community Admin | User issues and escalations |

### Moderators (Day-1)
| Name | Areas | Notes |
|------|-------|-------|
| [Name] | [Categories] | [Any special notes] |

### Ongoing Governance
- Admin meetings: [Frequency]
- Moderator onboarding process: [Link/description]
- Escalation path: [Description]

## Data & Privacy

### Retention Policy
- Active user data: Retained indefinitely
- Deleted user data: [Describe handling]
- Deleted posts: [Soft delete / Hard delete after X days]

### GDPR Compliance
- Right to access: [Process]
- Right to be forgotten: [Process]
- Data export: [Process]

### Privacy Changes
- [List any changes to privacy policy]
- Users will be notified: [Yes/No, How]

## Identity Management

### Strategy Choice
**Selected Option:** [A: Import accounts / B: SSO from day-1 / C: Hybrid]

### User Account Handling
- Username mapping: [Describe rules]
- Email validation: [Required / Best effort]
- Duplicate accounts: [Resolution strategy]
- Inactive accounts: [Include all / Filter criteria]
- Banned users: [Import as banned / Exclude]

### Password Management
- Initial passwords: [Reset via email / SSO / Other]
- Password reset process: [Description]

### Future SSO (if applicable)
- Target implementation date: [Date/Quarter]
- SSO provider: [University system / Other]
- Migration plan: [Brief description]

## Cutover Plan

### Freeze Window
- **Duration:** [e.g., 6 hours]
- **Date:** [Proposed date/timeframe]
- **Time:** [e.g., 02:00-08:00 UTC]

### Rollback Posture
- **Rollback criteria:** [List conditions that would trigger rollback]
- **Rollback process:** Keep phpBB intact; revert DNS if needed
- **Maximum rollback time:** [e.g., 30 minutes]

### Old Forum Status
- **After cutover:** [Read-only / Offline / Archive mode]
- **Duration:** [If read-only, how long]
- **Redirect strategy:** [Immediate / Grace period]

## Communication Plan

### Pre-Migration
- T-4 weeks: Announcement and FAQ
- T-2 weeks: Migration date confirmation
- T-1 week: Final reminder and preparation guide
- T-1 day: Freeze window announcement

### During Migration
- Status page: [URL]
- Updates: [How often, which channels]

### Post-Migration
- Day 1: Welcome message and help guide
- Week 1: Daily check-ins and feedback collection
- Month 1: Retrospective and improvements

## Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Data loss during migration | High | Low | Multiple rehearsals, backups |
| URL redirects fail | Medium | Low | Comprehensive redirect testing |
| User login issues | Medium | Medium | Clear password reset process |
| Extended downtime | Medium | Low | Rollback plan ready |
| Community resistance | Medium | Medium | Clear communication, training |

## Success Criteria

### Technical
- [ ] All content migrated (99.9%+ success rate)
- [ ] All attachments accessible
- [ ] 95%+ of old URLs redirect correctly
- [ ] Users can log in (via password reset if needed)
- [ ] Search functionality working

### Community
- [ ] Positive community feedback (survey)
- [ ] Active posting resumes within 48 hours
- [ ] Moderators comfortable with new tools
- [ ] Admin team trained

### Operational
- [ ] Backups running automatically
- [ ] Monitoring in place
- [ ] Email deliverability confirmed
- [ ] Performance acceptable (response times)

## Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Project Lead | | | |
| Technical Lead | | | |
| Community Representative | | | |
| Legal/Compliance (if req.) | | | |

## Appendices

- Appendix A: Detailed technical architecture
- Appendix B: Full risk register
- Appendix C: Rollback runbook
- Appendix D: Communication templates
