# phpBB to Discourse Migration Guide

This repository contains a comprehensive end-to-end framework for migrating the SHMMY/ECE NTUA forum from phpBB to Discourse.

## Overview

This migration plan is designed for a forum of significant scale:
- **837,201 posts**
- **21,849 topics**
- **11,362 members**

The goal is to replace phpBB with Discourse while preserving content, identities, and link integrity, and improving UX, moderation, and search capabilities.

## Migration Phases

The migration is structured into 10 distinct phases, each with specific deliverables and checklists:

### Phase 1: Project Framing and Decision Record
**Objective:** Define the scope, governance, and non-negotiables for the migration.

📁 [Documentation](./docs/phase1-decision-scope/)

**Key Deliverables:**
- Decision & Scope document
- Governance model
- Data/privacy stance
- Identity management strategy

### Phase 2: Technical Discovery and Audit
**Objective:** Inventory and assess the current phpBB installation to de-risk the migration.

📁 [Documentation](./docs/phase2-technical-discovery/)

**Key Deliverables:**
- Data & Risk Report
- phpBB version and configuration audit
- User model analysis
- Attachments inventory
- Customizations catalog

### Phase 3: Target Architecture and Environments
**Objective:** Stand up staging and production Discourse environments.

📁 [Documentation](./docs/phase3-target-architecture/)

**Key Deliverables:**
- Infrastructure-as-code
- Deployment notes
- Backup/restore runbook

### Phase 4: Information Architecture Mapping
**Objective:** Map phpBB structure to Discourse's mental model.

📁 [Documentation](./docs/phase4-information-architecture/)

**Key Deliverables:**
- Category tree specification
- Tag strategy
- Moderation workflow design

### Phase 5: Migration Rehearsal Loop
**Objective:** Run and refine the import process until output is correct.

📁 [Documentation](./docs/phase5-migration-rehearsal/)
📁 [Scripts](./scripts/)

**Key Deliverables:**
- Repeatable migration scripts
- Staging validation checklist
- Migration patch list

### Phase 6: Link Preservation and Redirects
**Objective:** Ensure old phpBB links continue to work (SEO + legacy usability).

📁 [Documentation](./docs/phase6-link-preservation/)

**Key Deliverables:**
- Redirect strategy document
- Redirect test suite

### Phase 7: Authentication Strategy
**Objective:** Define and implement user authentication approach.

📁 [Documentation](./docs/phase7-authentication/)

**Key Deliverables:**
- Auth decision record
- Implementation checklist

### Phase 8: Feature Parity and Modernization Layer
**Objective:** Define day-1 features vs. post-launch enhancements.

📁 [Documentation](./docs/phase8-feature-parity/)

**Key Deliverables:**
- Day-1 features list
- Post-launch enhancements roadmap

### Phase 9: Cutover Plan
**Objective:** Execute the production move with minimal chaos.

📁 [Documentation](./docs/phase9-cutover/)

**Key Deliverables:**
- Cutover runbook (minute-by-minute)
- Rollback runbook

### Phase 10: Post-Launch Operations
**Objective:** Ensure the platform survives and thrives post-launch.

📁 [Documentation](./docs/phase10-post-launch/)

**Key Deliverables:**
- Operations handbook
- First month monitoring checklist

## Quick Start

1. **Read Phase 1** to understand the project scope and make key decisions
2. **Execute Phase 2** to audit your current phpBB installation
3. **Set up Phase 3** to create your Discourse environments
4. **Work through Phases 4-10** sequentially, using the provided templates and scripts

## Tools and Resources

- [Discourse Official Documentation](https://docs.discourse.org/)
- [phpBB3 Migration Guide](https://meta.discourse.org/t/importing-from-phpbb3/31201)
- [Discourse GitHub Repository](https://github.com/discourse/discourse)
- [phpBB3 Importer Code](https://github.com/discourse/discourse/tree/main/script/import_scripts/phpbb3)

## Support

For questions or issues during migration, refer to:
- Discourse Meta community forums
- This repository's issues section
- The official Discourse team documentation

## License

This migration framework is provided as-is for the SHMMY/ECE NTUA forum migration project.
