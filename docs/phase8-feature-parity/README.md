# Phase 8: Feature Parity and Modernization Layer

## Objective

Don't try to replicate every phpBB behavior. Focus on Day-1 features vs. post-launch enhancements.

---

## Philosophy: Embrace the Upgrade

**Key principle:** Discourse is fundamentally different and better in many ways.

**Avoid:**
- ❌ Replicating every phpBB quirk
- ❌ Creating complex workarounds for old behaviors
- ❌ Fighting Discourse's conventions

**Instead:**
- ✅ Educate users on new, better ways
- ✅ Focus on core functionality first
- ✅ Gradually add enhancements based on real user feedback

---

## Day-1 Features (Must Have)

### 1. Core Forum Functionality

**Reading and browsing:**
- ✅ View topics and posts - **Built-in**
- ✅ Browse categories - **Built-in**
- ✅ Search posts - **Built-in** (much better than phpBB!)
- ✅ View user profiles - **Built-in**
- ✅ Mobile responsive - **Built-in**

**Posting:**
- ✅ Create new topics - **Built-in**
- ✅ Reply to topics - **Built-in**
- ✅ Edit own posts - **Built-in**
- ✅ Upload attachments/images - **Built-in**
- ✅ Quote posts - **Built-in**
- ✅ Mention users (@username) - **Built-in**
- ✅ Format text (Markdown) - **Built-in**

**Status:** ✅ All Day-1 ready, no work needed

### 2. Better Composer Experience

**Discourse's composer is superior to phpBB:**

**Built-in features:**
- Live preview
- Drag-and-drop image upload
- Markdown toolbar
- Emoji picker
- Link preview/oneboxing
- Draft saving

**User education needed:**
- Create guide: "Writing Posts in Discourse"
- Document Markdown basics
- Explain preview feature
- Show keyboard shortcuts

**Create at: `/t/writing-guide`**

```markdown
# Writing Posts in Discourse

## Formatting

Discourse uses Markdown for formatting:

**Bold text:** `**bold**` → **bold**
*Italic text:* `*italic*` → *italic*
~~Strikethrough:~~ `~~strike~~` → ~~strike~~

## Code

Inline code: Use `backticks`

Code blocks:
\```python
def hello():
    print("Hello, world!")
\```

## Quoting

Click "Quote" button or use:
> Quote text with > symbol

## Images

Drag and drop, or click upload button.

## Links

Paste URL - it converts automatically!
Or: `[text](url)` → [text](url)

## Tips

- Use live preview (right side)
- Drafts save automatically
- @ mention users: @username
- # link topics: #123
```

### 3. Moderation Tools

**Discourse has powerful built-in moderation:**

**Day-1 features:**
- ✅ Flag inappropriate content - **Built-in**
- ✅ Review queue - **Built-in**
- ✅ Edit any post (mods) - **Built-in**
- ✅ Close topics - **Built-in**
- ✅ Pin topics - **Built-in**
- ✅ Delete posts/topics - **Built-in**
- ✅ Silence users - **Built-in**
- ✅ Suspend users - **Built-in**
- ✅ Category-specific moderators - **Built-in**

**Configure moderation:**

Admin → Settings → Posting:
```yaml
min_post_length: 20
min_first_post_length: 20
title_min_entropy: 10
body_min_entropy: 50
max_post_length: 32000
```

Admin → Settings → Users:
```yaml
suspicious_ip_range_size: 24
max_flags_per_day: 20
max_edits_per_day: 100
```

**Train moderators:**
- Create moderation guide
- Document flag handling process
- Explain trust level system

### 4. Trust Level System

**Critical Discourse feature - automatic privilege escalation**

**Default settings (review and adjust):**

| Setting | Default | Recommended for SHMMY |
|---------|---------|----------------------|
| TL1: Topics entered | 5 | 5 |
| TL1: Posts read | 30 | 30 |
| TL1: Time spent | 10 min | 10 min |
| TL2: Days visited | 15 | 15 |
| TL2: Topics entered | 20 | 15 (lower for migration) |
| TL2: Posts read | 100 | 100 |
| TL2: Time spent | 60 min | 60 min |
| TL2: Likes received | 1 | 1 |
| TL3: Days visited (%) | 50% of 100 days | 50% |
| TL3: Topics replied to | 10 | 10 |
| TL3: Topics viewed (%) | 25% | 25% |
| TL3: Posts read | 500 | 500 |
| TL3: Flags agreed | 1 | 1 |
| TL3: Likes given | 30 | 30 |
| TL3: Likes received | 30 | 30 |

**User communication:**
- Explain trust levels in welcome post
- Create FAQ about privilege unlocking
- Show benefits of engagement

### 5. Search (Major Upgrade!)

**Discourse search is vastly superior:**

**Built-in features:**
- Full-text search
- Greek language support (important!)
- Search within category
- Search by user
- Search by tag
- Advanced filters
- Search in title vs. all text

**Configuration:**

Admin → Settings → Search:
```yaml
search_tokenize_chinese_japanese_korean: false
search_max_length: 50
min_search_term_length: 3
search_prefer_recent_posts: true
```

**For Greek language:**
```yaml
# Greek language pack must be installed
default_locale: el  # If Greek is primary
# Or leave as en if bilingual
```

**User guide:**

```markdown
# How to Search

## Basic search
Type keywords in search box

## Filters
- `in:title keyword` - Search titles only
- `category:academic` - Search in category
- `@username` - Posts by user
- `#tag` - Tagged topics
- `before:2024-01-01` - Date filter
- `order:latest` - Sort by recency

## Examples
- `exam in:title category:year-1` - Exam topics in first year
- `@professor math-101` - Professor's posts about Math 101
- `#solved java` - Solved Java questions
```

### 6. Notifications

**Discourse notifications are real-time and configurable:**

**Built-in:**
- ✅ Email notifications
- ✅ On-site notifications (bell icon)
- ✅ Browser push notifications
- ✅ Per-category notification settings
- ✅ Watching/Tracking/Normal/Muted

**Default settings:**
```yaml
# Admin → Settings → Email
email_time_window_mins: 10  # Batch emails if multiple notifications
enable_mailing_list_mode: true  # Allow users to opt-in
disable_emails: "never"  # Options: never, non_staff, always
```

**User education:**
- Notification preferences tutorial
- Explain watching vs. tracking
- Show how to mute categories
- Demonstrate email digest options

---

## Post-Launch Enhancements (Nice to Have)

### Enhancement 1: Solved/Q&A Workflows

**For course questions - very useful for academic forum**

**Plugin:** [Discourse Solved](https://meta.discourse.org/t/discourse-solved-accepted-answer-plugin/30155)

**Features:**
- Mark topic as "Solved" (checkmark)
- Accept specific answer
- Filter by solved/unsolved
- Gamification (points for accepted answers)

**Installation:**
```yaml
# In app.yml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/discourse/discourse-solved.git
```

**Timeline:** Month 2

**Configuration:**
- Enable in course-related categories
- Train users to mark solutions
- Incentivize answering (trust level boost?)

### Enhancement 2: Voting/Ranking

**For best answers, resources, etc.**

**Plugin:** [Discourse Voting](https://meta.discourse.org/t/discourse-voting/40121)

**Features:**
- Upvote/downvote topics (not posts)
- Sort by votes
- Vote count badges

**Use cases:**
- Resource recommendations
- Feature requests
- Best practices topics

**Timeline:** Month 3-4

### Enhancement 3: Calendar/Events

**For exam dates, study groups, seminars**

**Plugin:** [Discourse Calendar](https://meta.discourse.org/t/discourse-calendar/97376)

**Features:**
- Embed calendar in posts
- RSVP to events
- Recurring events
- iCal export

**Use cases:**
- Exam schedule
- Study group meetups
- Guest lectures
- Office hours

**Timeline:** Month 4-6

### Enhancement 4: Math Rendering

**For math-heavy discussions**

**Plugin:** [Discourse Math](https://meta.discourse.org/t/discourse-math-plugin/65770)

**Features:**
- LaTeX/MathJax rendering
- Inline and block math
- Preview in composer

**Syntax:**
```latex
Inline: $E = mc^2$
Block: $$\int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2}$$
```

**Timeline:** Month 2 (high priority for engineering forum)

### Enhancement 5: Custom Category Badges

**Visual distinction for categories**

**Feature:** Custom category icons and colors

**Implementation:**
- Admin → Categories → [Category] → Edit
- Choose colors and emoji
- Or upload custom icons

**Timeline:** Month 1 (low effort, high impact)

### Enhancement 6: Gamification

**Encourage engagement**

**Built-in badges system:**
- Admin → Badges
- Configure badge criteria
- Auto-grant based on actions

**Custom badges for SHMMY:**
- "First Year Helper" - Helped 10 first-year students
- "Math Wizard" - 50 accepted answers in math categories
- "Tutorial Author" - Created high-quality guides
- "Community Regular" - Active for 6+ months

**Timeline:** Month 3

### Enhancement 7: Tags-based Course Navigation

**Enhance browsing by course**

**Implementation:**
- Create tag pages: `/tags/math-101`
- Create tag groups for semesters, years
- Build navigation menu with common tags

**Custom homepage:**
- Show popular tags
- Course directory page
- Semester view

**Timeline:** Month 2

---

## Features NOT to Replicate

### phpBB Features to Skip

**Don't waste time replicating these:**

1. **BBCode beyond standard**
   - Custom BBCode: Convert to Markdown equivalent
   - Complex nested BBCode: Simplify

2. **Signature files**
   - Discourse doesn't have signatures (reduces noise)
   - Use pinned "About me" post instead

3. **Post count prominently displayed**
   - Discourse uses trust levels, not post count
   - Reduces gamification of quantity over quality

4. **Detailed user ranks/titles**
   - Discourse has simple trust level badges
   - Can add custom titles via badges if really needed

5. **Forum-specific themes per user**
   - Discourse has light/dark mode
   - Consistent UX is better

6. **Highly granular permissions**
   - Discourse uses simpler model (works well)
   - Don't try to map every phpBB permission

---

## User Education and Change Management

### Communication Strategy

**Week -2: Preview**
```markdown
# What's Coming: New Forum Features

Get ready for a better forum experience!

## Better Posting
- Live preview as you type
- Drag-and-drop images
- Auto-save drafts

## Better Search
- Find anything instantly
- Search within categories
- Advanced filters

## Better Mobile
- Fully responsive
- Native app feel
- Fast and smooth

## Trust Levels (New!)
As you participate, you unlock privileges:
- TL1: Basic posting
- TL2: More features
- TL3: Community leader

More details coming soon!
```

**Day 1: Welcome Guide**
```markdown
# Welcome to the New Forum! 🎉

## What's Different?

### Writing Posts
- Use Markdown (not BBCode)
- See preview as you type
- Drag-and-drop images

### Navigation
- Categories (like old forums)
- Tags (new! powerful filtering)
- Better search

### Engaging
- Like posts (not just +1)
- Mention users with @
- Get real-time notifications

## Quick Start

1. **Reset your password** (check email)
2. **Update your profile** (add avatar, bio)
3. **Browse categories** (find your courses)
4. **Try posting** (use preview!)

## Need Help?

- **Writing guide:** /t/writing-guide
- **FAQ:** /t/faq
- **Support:** /t/help

Questions? Ask in #forum-help

Welcome aboard!
```

### Training Materials

**Create comprehensive guides:**

1. **/t/newcomer-guide** - Basics
2. **/t/markdown-guide** - Formatting
3. **/t/search-guide** - Finding content
4. **/t/moderation-guide** - For moderators
5. **/t/trust-levels-explained** - Privilege system
6. **/t/faq** - Common questions

**Video tutorials (optional):**
- Screen recording of common tasks
- 2-3 minutes each
- Embedded in guides

### Feedback Loop

**Collect feedback:**
- Create #feedback category
- Weekly "How's it going?" topics
- Monitor common questions
- Track feature requests

**Iteration:**
- Week 1: Daily check-ins
- Week 2-4: Weekly reviews
- Month 2+: Monthly reviews
- Implement quick wins
- Plan major enhancements

---

## Deliverables

### Day-1 Features List

- [ ] Core functionality verified
- [ ] Composer tested and documented
- [ ] Moderation tools configured
- [ ] Trust level settings reviewed
- [ ] Search tested (including Greek)
- [ ] Notifications configured
- [ ] User guides created

### Post-Launch Enhancements Roadmap

| Enhancement | Priority | Timeline | Effort | Dependencies |
|-------------|----------|----------|--------|--------------|
| Math rendering | High | Month 2 | Low | Plugin install |
| Solved plugin | High | Month 2 | Low | Plugin install |
| Custom badges | Medium | Month 3 | Medium | Community feedback |
| Calendar | Medium | Month 4 | Medium | Event content |
| Voting | Low | Month 4 | Low | Plugin install |
| Tag navigation | Medium | Month 2 | Medium | Tag strategy finalized |

### Documentation Package

- [ ] User welcome guide
- [ ] Markdown/formatting guide
- [ ] Search guide
- [ ] Trust levels explanation
- [ ] FAQ (phpBB vs. Discourse)
- [ ] Moderator training guide

---

## Success Criteria

- [ ] All core features working
- [ ] Users can post, read, search
- [ ] Moderators comfortable with tools
- [ ] User guides published
- [ ] <5% of users confused (survey)
- [ ] Positive feedback on new features
- [ ] Enhancement roadmap approved

---

## Next Steps

Once Phase 8 is complete, proceed to [Phase 9: Cutover Plan](../phase9-cutover/)
