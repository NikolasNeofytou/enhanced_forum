# Phase 4: Information Architecture Mapping

## Objective

Map phpBB's structure (forums/subforums/threads/posts) to Discourse's mental model (categories/tags/topics/replies).

## Understanding the Mental Model Shift

### phpBB Structure
```
Forum (Category)
  └── Subforum
      └── Thread (Sticky/Announcement)
          └── Post
              └── Reply
```

### Discourse Structure
```
Category
  └── Subcategory (optional)
      └── Topic (Pinned/Banner)
          ├── Tags
          └── Reply
```

### Key Differences

| Concept | phpBB | Discourse |
|---------|-------|-----------|
| **Top Level** | Forums | Categories |
| **Hierarchy** | Forums → Subforums (deep nesting) | Categories → Subcategories (2 levels max) |
| **Thread** | Thread | Topic |
| **Post** | Post | Reply/Post |
| **Organization** | Folder-based | Tags + Categories |
| **Sticky** | Sticky, Announcement, Global | Pinned, Banner |
| **Private Areas** | Forum permissions | Category permissions |

---

## Category Tree Design

### Step 1: Audit Current phpBB Forums

**Export forum structure:**

```sql
SELECT 
    forum_id,
    parent_id,
    forum_name,
    forum_desc,
    forum_type,
    forum_posts,
    forum_topics
FROM phpbb_forums
ORDER BY parent_id, left_id;
```

**Document hierarchy:**
- [ ] List all top-level forums
- [ ] List all subforums and their parents
- [ ] Identify deep nesting (>2 levels)
- [ ] Note post/topic distribution

### Step 2: Design Category Structure

**Principles:**
- Keep it familiar to existing users (reduce confusion)
- Flatten deep hierarchies (Discourse limit: 2 levels)
- Group related content
- Plan for future growth
- Use tags to replace some subforum distinctions

**Example Mapping:**

#### phpBB Structure
```
📁 Academic
  📁 First Year
    📁 Math 101
    📁 Physics 101
  📁 Second Year
    📁 Math 201
    📁 Physics 201
📁 General
  📁 Announcements
  📁 Off-Topic
```

#### Discourse Structure (Option A: Maintain hierarchy)
```
📂 Academic
  📂 First Year
  📂 Second Year
📂 General
  📂 Announcements
  📂 Off-Topic
```
*Use tags:* `math-101`, `physics-101`, `math-201`, etc.

#### Discourse Structure (Option B: Flatten with tags)
```
📂 Courses
  (All course discussions)
📂 General
  📂 Announcements
  📂 Off-Topic
```
*Use tags:* `year-1`, `year-2`, `math`, `physics`, `math-101`, `physics-101`

**Recommended:** Option A for initial migration (less disruptive), evolve to B if needed

### Step 3: Category Specification

**Template for each category:**

| Category Name | Parent | Description | Permissions | Auto-close | Tags Required |
|---------------|--------|-------------|-------------|------------|---------------|
| Academic | - | Academic discussions and resources | All users | No | Optional |
| First Year | Academic | First year courses | All users | No | Optional |
| Second Year | Academic | Second year courses | All users | No | Optional |
| Announcements | General | Official announcements | Read: All, Post: Staff | No | Required |
| Off-Topic | General | Non-academic discussions | All users | No | Optional |

**Additional Fields:**
- Default view (latest/categories/top)
- Notification level default
- Position (display order)
- Color (hex code)
- Icon (emoji or image)

---

## Tag Strategy

### Why Tags in Discourse?

Tags add a second dimension to organization:
- **Categories:** Broad topic areas (e.g., "Academic")
- **Tags:** Specific subjects, types, metadata (e.g., `exam`, `lab`, `math-101`)

### Tag Design for SHMMY/ECE NTUA

#### Course-Related Tags

**Course codes:**
- `math-101`, `physics-101`, `circuits-201`, etc.
- Format: `subject-code` (lowercase, hyphenated)

**Academic terms:**
- `fall-2024`, `spring-2025`
- Use for time-sensitive content

**Content types:**
- `lecture`, `lab`, `homework`, `exam`, `project`
- `notes`, `resources`, `recording`

#### Topic Type Tags

**Question/Answer:**
- `question`, `solved`, `unsolved`
- Can mark topics as solved (Discourse feature)

**Priority/Status:**
- `urgent`, `important`, `archived`

#### Meta Tags

**Year tags:**
- `year-1`, `year-2`, `year-3`, `year-4`, `graduate`

**Subject areas:**
- `mathematics`, `physics`, `programming`, `circuits`, `signals`

### Tag Groups

Organize tags into groups for better UX:

| Tag Group | Tags | Usage |
|-----------|------|-------|
| Course Codes | `math-101`, `physics-101`, ... | Required in "Courses" category |
| Academic Year | `year-1`, `year-2`, `year-3`, `year-4` | Optional |
| Content Type | `lecture`, `lab`, `exam`, `homework` | Optional |
| Semester | `fall-2024`, `spring-2025`, ... | Optional |
| Status | `solved`, `unsolved`, `urgent` | Optional |

**Configuration:**
- Some groups can be "one tag per topic only"
- Some can be required in certain categories
- Set permissions: who can create/use tags

### Tag Naming Conventions

**Rules:**
- Lowercase only
- Use hyphens for spaces (`math-101`, not `math_101`)
- Keep short (max 20 chars)
- No special characters
- Descriptive, not cryptic

**Examples:**
- ✅ `math-101`, `exam-prep`, `solved`
- ❌ `Math101`, `math_101`, `m101`, `!exam`

---

## Migration Mapping

### Mapping phpBB Forums to Discourse Categories

**Create mapping table:**

| phpBB Forum ID | phpBB Forum Name | Discourse Category | Discourse Subcategory | Default Tags |
|----------------|------------------|--------------------|-----------------------|--------------|
| 1 | Academic | Academic | - | - |
| 5 | First Year | Academic | First Year | `year-1` |
| 10 | Math 101 Discussion | Academic | First Year | `math-101`, `year-1` |
| 15 | Physics 101 Discussion | Academic | First Year | `physics-101`, `year-1` |
| 20 | General Discussion | General | - | - |

**If deep nesting exists:**

**phpBB: Forum → Subforum → Sub-subforum**

**Option A:** Flatten to Category → Subcategory, use tags
```
Forum: Academic → Subforum: Year 1 → Sub: Math 101
Becomes: Category: Academic → Subcategory: First Year (Tags: math-101)
```

**Option B:** Promote sub-subforum to subcategory
```
Forum: Academic → Subforum: Year 1 → Sub: Math 101
Becomes: Category: Academic → Subcategory: Math 101
```

### Sticky/Announcement Mapping

| phpBB | Discourse |
|-------|-----------|
| Sticky | Pinned Topic |
| Announcement | Pinned Topic + Banner (optional) |
| Global Announcement | Banner Topic |

**Migration script handles:**
- Convert sticky → pinned
- Convert announcement → pinned (optionally banner)

---

## Trust Levels and Permissions

### Understanding Discourse Trust Levels

Discourse uses an automated trust system instead of user groups:

| Level | Name | Auto-granted When | Abilities |
|-------|------|-------------------|-----------|
| 0 | New User | Just joined | Read, like, flag |
| 1 | Basic User | Read 5 topics, 30 posts, 10 min | Reply, upload images, wiki edits |
| 2 | Member | Visit 15 days, read 20+ topics, 100+ min, 1+ like received | Edit own posts, flag, invite users |
| 3 | Regular | Visit 50% of last 100 days, read/engaged extensively | Edit all posts, approve new users, first post moderation |
| 4 | Leader | Manual promotion | Recategorize, rename, merge, split topics |

### Custom Trust Level Settings

**Adjust for your community:**

```yaml
# Common adjustments
trust_level_0_time: 0  # Time to stay at TL0 (0 = immediate promotion)
trust_level_1_requires_read_posts: 5  # Lower for established migration
trust_level_2_requires_topics_entered: 10
trust_level_3_requires_topics_viewed: 50  # Adjust based on activity
```

### Mapping phpBB Groups to Discourse

**phpBB user groups → Discourse approach:**

| phpBB Group | Discourse Equivalent | Implementation |
|-------------|---------------------|----------------|
| Administrators | Admin users | Manual assignment |
| Moderators | Moderators (category-specific) | Manual assignment |
| Registered Users | Trust Level 0-4 | Automatic |
| Special Access Groups | Category permissions | Create groups, assign category permissions |
| Course-Specific Groups | Tags | Use tag-based filtering |

### Category Permission Design

**Public categories:**
- Everyone: Create/Reply/See

**Announcement categories:**
- Staff: Create
- Everyone: Reply/See (or just See)

**Private categories (if needed):**
- Example: "Staff Discussions"
- Staff group: Create/Reply/See
- Others: No access

**Course-specific (if needed):**
- Example: "Graduate Seminars"
- Graduate students group: Create/Reply/See
- Others: No access

---

## Moderation Workflow

### Discourse Moderation Tools

**Built-in features:**
1. **Flags:** Users can flag inappropriate content
2. **Review queue:** Mods review flagged content
3. **Trust level promotions:** Automatic based on activity
4. **Silencing:** Temporarily restrict posting
5. **Suspension:** Temporarily ban user
6. **Post editing:** Mods can edit any post
7. **Topic operations:** Close, archive, delete, merge, split, move

### Moderation Strategy

**Category Moderators:**
- Assign moderators to specific categories
- Example: Faculty member moderates their course category

**Moderation Guidelines:**
- [ ] Document what constitutes rule violation
- [ ] Define warning → suspension → ban escalation
- [ ] Set expectations for response times

**Automation:**
- Trust level system reduces mod burden (trusted users self-moderate)
- Akismet for spam detection (built-in)
- Auto-close old topics (optional, by category)

### Moderation Settings

**Recommended settings:**

```yaml
# Anti-spam
min_trust_to_create_topic: 0  # Or 1 to reduce spam
min_trust_to_post_links: 0  # Or 1 to reduce spam
max_topics_per_day: 20  # Per user limit
max_replies_per_day: 100

# Auto-moderation
approve_post_count: 0  # Number of posts requiring approval (0 = none)
approve_new_topics_unless_trust_level: 0  # Auto-approve TL0+

# Quality control
body_min_length: 20  # Minimum post length
title_min_length: 15  # Minimum topic title length
```

---

## Migration Implementation

### Pre-Migration Category Setup

**On staging Discourse:**

1. **Create all categories:**
   - Admin → Categories → New Category
   - Set name, description, parent, permissions
   - Set color, icon, position

2. **Create tag groups and tags:**
   - Admin → Tags → New Tag Group
   - Admin → Tags → New Tag
   - Assign tags to groups

3. **Configure category settings:**
   - Default view, notification level
   - Required tags, allowed tags
   - Auto-close settings

4. **Set up user groups:**
   - Admin → Groups → New Group
   - Assign permissions to categories

### During Migration

**Import script will:**
- Map phpBB forum IDs to Discourse category IDs
- Create topics in correct categories
- Apply tags based on mapping rules
- Preserve pinned/sticky status

**Mapping configuration:**
```ruby
# In phpBB importer script
CATEGORY_MAPPINGS = {
  1 => { category_id: 5, tags: [] },  # Academic → Academic
  5 => { category_id: 6, tags: ['year-1'] },  # First Year → First Year
  10 => { category_id: 6, tags: ['math-101', 'year-1'] },  # Math 101 → First Year
  # ...
}
```

### Post-Migration Review

- [ ] Verify all topics are in correct categories
- [ ] Verify tags are applied correctly
- [ ] Check pinned topics
- [ ] Review category permissions
- [ ] Test moderation tools

---

## Information Architecture Documentation

### Deliverable: Category + Tag Specification

Create a comprehensive document:

**1. Category Tree Diagram:**
```
📂 Academic
  📂 First Year Courses
  📂 Second Year Courses
  📂 Third Year Courses
  📂 Fourth Year Courses
  📂 Graduate Seminars

📂 Resources
  📂 Study Materials
  📂 Past Exams
  📂 Lab Resources

📂 Community
  📂 Announcements
  📂 General Discussion
  📂 Events

📂 Technical Support
  📂 Forum Help
  📂 Course Technical Issues
```

**2. Category Details Table:**
(See template in previous section)

**3. Tag Taxonomy:**
- Complete list of tags
- Tag groups
- Usage guidelines
- Required vs. optional by category

**4. Permission Matrix:**
- Who can post/reply/see in each category
- Trust level requirements
- Special group permissions

**5. Moderation Assignments:**
- Category moderators
- Responsibility areas
- Escalation paths

---

## User Communication

### Explaining the New Structure

**Key messages:**
1. **Familiar but better:** Same content, better organization
2. **Tags are powerful:** Find exactly what you need
3. **Learn as you go:** Trust levels unlock features over time

**Documentation needed:**
- "Where did my favorite forum go?" mapping guide
- "How to use tags" tutorial
- "Understanding trust levels" guide

**Example announcement:**
```markdown
## Welcome to the New Forum Structure! 🎉

We've reorganized the forum to make it easier to find what you need:

### Categories
Think of categories like the old forums. We've kept them familiar!

- 📚 **Academic** → All course discussions
- 🎓 **Resources** → Study materials, past exams
- 💬 **Community** → Announcements, general chat

### Tags (NEW!)
Tags help you find specific topics within categories:

- Course tags: `math-101`, `physics-201`
- Content tags: `exam`, `homework`, `lab`
- Status tags: `solved`, `urgent`

### Find Topics
- Browse by category: Click a category to see all topics
- Filter by tags: Click a tag to see tagged topics
- Search: Our search is much better now!

Questions? Ask in #forum-help
```

---

## Success Criteria

- [ ] Category structure designed and documented
- [ ] Tag strategy defined
- [ ] Permission model designed
- [ ] Migration mapping table complete
- [ ] Moderation workflow documented
- [ ] Categories and tags created in staging
- [ ] Test migration validates structure
- [ ] User communication prepared

---

## Next Steps

Once Phase 4 is complete, proceed to [Phase 5: Migration Rehearsal Loop](../phase5-migration-rehearsal/)
