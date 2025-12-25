# Phase 1: Project Framing and Decision Record

## Objective

Replace phpBB with Discourse while preserving content, identities, and link integrity, and improving UX/moderation/search.

## Non-Negotiables (Define Up Front)

### 1. Ownership and Moderation Governance

**Decision Required:** Who are the admins/moderators on day-1 and ongoing?

- [ ] Identify current phpBB administrators
- [ ] Identify current phpBB moderators
- [ ] Define admin roles in Discourse
- [ ] Define moderator roles in Discourse
- [ ] Map phpBB permissions to Discourse trust levels
- [ ] Document governance structure

**Template:** See [governance-template.md](./governance-template.md)

### 2. Data/Privacy Stance

**Decision Required:** What is our stance on data retention, deleted users/posts handling, and GDPR compliance?

- [ ] Define data retention policy
- [ ] Document deleted users handling strategy
- [ ] Document deleted posts handling strategy
- [ ] Create GDPR compliance process
- [ ] Define right-to-be-forgotten workflow
- [ ] Document data export procedures

**Template:** See [privacy-policy-template.md](./privacy-policy-template.md)

### 3. Scope of "Identity"

**Decision Required:** Keep existing accounts (import) vs. enforce new SSO (university login) at cutover?

**Option A: Import existing accounts**
- ✅ Lower risk, smoother cutover
- ✅ Users keep their history
- ❌ Users must reset passwords via email
- ❌ No central identity management

**Option B: Enforce SSO from day-1**
- ✅ Central identity management
- ✅ University authentication integration
- ❌ Higher complexity
- ❌ Risk of account matching issues

**Recommended:** Option A for cutover, add SSO post-stabilization

- [ ] Choose identity strategy
- [ ] Document username mapping rules
- [ ] Define email validation requirements
- [ ] Plan for duplicate accounts
- [ ] Document SSO timeline (if applicable)

**Template:** See [identity-strategy-template.md](./identity-strategy-template.md)

### 4. Cutover Rule

**Decision Required:** What is the "read-only freeze" window, rollback posture, and will the old forum stay online read-only?

- [ ] Define freeze window duration (recommended: 4-8 hours)
- [ ] Define rollback criteria
- [ ] Decide if old forum stays online read-only
- [ ] Define DNS cutover strategy
- [ ] Document communication plan

**Template:** See [cutover-rules-template.md](./cutover-rules-template.md)

## Deliverable

**Output:** A 1-page "Decision & Scope" document that clearly states:
- What changes
- What does not change
- Who is responsible
- How data is handled
- When and how the cutover happens

**Template:** Use [decision-scope-document.md](./decision-scope-document.md)

## Success Criteria

- [ ] All stakeholders have reviewed and approved the decision document
- [ ] Governance structure is clearly defined
- [ ] Data/privacy policies are documented
- [ ] Identity strategy is chosen and documented
- [ ] Cutover rules are established
- [ ] Communication plan is approved

## Next Steps

Once Phase 1 is complete, proceed to [Phase 2: Technical Discovery and Audit](../phase2-technical-discovery/)
