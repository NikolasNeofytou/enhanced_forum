# Validation Checklist for Migration Rehearsal

**Iteration #:** ___  
**Date:** ___________  
**Tester:** ___________

## Data Completeness

### User Count
- [ ] phpBB users: _______ (expected: 11,362)
- [ ] Discourse users: _______
- [ ] Difference: _______
- [ ] Explanation for difference: _______________________

### Topic Count
- [ ] phpBB topics: _______ (expected: 21,849)
- [ ] Discourse topics: _______
- [ ] Difference: _______
- [ ] Explanation: _______________________

### Post Count
- [ ] phpBB posts: _______ (expected: 837,201)
- [ ] Discourse posts: _______
- [ ] Difference: _______
- [ ] Explanation: _______________________

### Attachment Count
- [ ] phpBB attachments: _______
- [ ] Discourse attachments: _______
- [ ] Difference: _______
- [ ] Explanation: _______________________

**Data Completeness Score:** ___/4 passed

---

## Content Quality (Sample 50 Topics)

### Topic Selection
Sample these specific topics:
- [ ] Topic ID 1 (oldest)
- [ ] Topic ID ______ (newest)
- [ ] 10 random from year 1
- [ ] 10 random from year 2
- [ ] 10 random from last 6 months
- [ ] 10 with images/attachments
- [ ] 10 with special formatting
- [ ] Remaining random selection

### Quality Checks (for each sampled topic)

**Topic #: _______**
- [ ] Title preserved correctly
- [ ] Greek characters display correctly (if applicable)
- [ ] Post content matches original
- [ ] Paragraphs and formatting preserved
- [ ] BBCode converted to Markdown correctly
- [ ] Images display properly
- [ ] Attachments downloadable
- [ ] Links work
- [ ] Quotes render correctly
- [ ] Code blocks formatted correctly

**Issues found:**
_______________________________________________________

Repeat for all 50 sampled topics.

**Content Quality Score:** ___/50 topics fully correct

---

## User Data (Sample 20 Users)

### User Selection
- [ ] User ID 1 (likely admin)
- [ ] 5 high post-count users
- [ ] 5 medium activity users
- [ ] 5 low activity users
- [ ] 4 random users

### User Checks (for each sampled user)

**Username: _______**
- [ ] Username correct (or documented transformation)
- [ ] Email preserved (or placeholder if invalid)
- [ ] Post count matches
- [ ] Join date preserved
- [ ] User can find their posts
- [ ] Profile data correct

**Issues found:**
_______________________________________________________

**User Data Score:** ___/20 users fully correct

---

## Structure and Organization

### Categories
- [ ] All categories created
- [ ] Category hierarchy correct
- [ ] Topics in correct categories
- [ ] Category permissions correct
- [ ] Private categories restricted
- [ ] Category colors/icons set

**Issues:**
_______________________________________________________

### Tags
- [ ] Tags created (if applicable)
- [ ] Topics tagged correctly
- [ ] Tag groups configured
- [ ] Tag permissions correct

**Issues:**
_______________________________________________________

### Topic Status
- [ ] Pinned topics show as pinned
- [ ] Closed/locked topics show as closed
- [ ] Announcements preserved
- [ ] Topic timestamps correct

**Issues:**
_______________________________________________________

**Structure Score:** ___/4 sections passed

---

## Technical Validation

### Search Functionality
- [ ] Basic text search works
- [ ] Greek text searchable (if applicable)
- [ ] Search within category works
- [ ] Search by username works
- [ ] Search by tag works
- [ ] Advanced filters work

**Issues:**
_______________________________________________________

### Performance
- [ ] Homepage loads in < 3 seconds
- [ ] Topic page loads in < 2 seconds
- [ ] Search responds in < 2 seconds
- [ ] Image loading acceptable
- [ ] No timeout errors

**Actual times:**
- Homepage: _____ seconds
- Topic page: _____ seconds
- Search: _____ seconds

### Error Logs
- [ ] No critical errors in logs
- [ ] No database errors
- [ ] No missing attachment errors
- [ ] Warning count: _______

**Critical errors found:**
_______________________________________________________

### Authentication
- [ ] Can request password reset
- [ ] Reset email received
- [ ] Can set new password
- [ ] Can log in with new password
- [ ] Email notifications working

**Issues:**
_______________________________________________________

**Technical Score:** ___/4 sections passed

---

## Specific phpBB Feature Tests

### BBCode Conversion
Test these specific BBCode patterns:

- [ ] `[b]bold[/b]` → **bold**
- [ ] `[i]italic[/i]` → *italic*
- [ ] `[u]underline[/u]` → <u>underline</u> or marked
- [ ] `[url]link[/url]` → clickable link
- [ ] `[img]url[/img]` → displayed image
- [ ] `[quote]text[/quote]` → quote block
- [ ] `[code]code[/code]` → code block
- [ ] `[list][*]item[/list]` → bulleted list
- [ ] Custom BBCode: ________________

**Issues:**
_______________________________________________________

### Attachments
Test 10 random topics with attachments:

1. Topic _____: [ ] Pass / [ ] Fail - _____________
2. Topic _____: [ ] Pass / [ ] Fail - _____________
3. Topic _____: [ ] Pass / [ ] Fail - _____________
4. Topic _____: [ ] Pass / [ ] Fail - _____________
5. Topic _____: [ ] Pass / [ ] Fail - _____________
6. Topic _____: [ ] Pass / [ ] Fail - _____________
7. Topic _____: [ ] Pass / [ ] Fail - _____________
8. Topic _____: [ ] Pass / [ ] Fail - _____________
9. Topic _____: [ ] Pass / [ ] Fail - _____________
10. Topic _____: [ ] Pass / [ ] Fail - _____________

**Attachment Pass Rate:** ___/10

---

## Redirects and Permalinks

### Permalink Testing
Test 10 old phpBB URLs:

1. `/viewtopic.php?t=1`: [ ] Pass / [ ] Fail
2. `/viewtopic.php?t=100`: [ ] Pass / [ ] Fail
3. `/viewtopic.php?t=1000`: [ ] Pass / [ ] Fail
4. `/viewforum.php?f=1`: [ ] Pass / [ ] Fail
5. `/viewforum.php?f=5`: [ ] Pass / [ ] Fail
6. Custom test 1: ___________: [ ] Pass / [ ] Fail
7. Custom test 2: ___________: [ ] Pass / [ ] Fail
8. Custom test 3: ___________: [ ] Pass / [ ] Fail
9. Custom test 4: ___________: [ ] Pass / [ ] Fail
10. Custom test 5: ___________: [ ] Pass / [ ] Fail

**Redirect Pass Rate:** ___/10

---

## Overall Assessment

### Pass/Fail Criteria

| Category | Target | Actual | Pass/Fail |
|----------|--------|--------|-----------|
| Data completeness | 100% | ___% | [ ] |
| Content quality | >95% | ___% | [ ] |
| User data | >95% | ___% | [ ] |
| Structure | 100% | ___% | [ ] |
| Technical | All passing | ___/4 | [ ] |
| BBCode conversion | >90% | ___% | [ ] |
| Attachments | >95% | ___% | [ ] |
| Redirects | >90% | ___% | [ ] |

### Issues Summary

**Critical (must fix before production):**
1. _______________________________________________________
2. _______________________________________________________
3. _______________________________________________________

**Major (should fix, but not blocking):**
1. _______________________________________________________
2. _______________________________________________________
3. _______________________________________________________

**Minor (nice to fix):**
1. _______________________________________________________
2. _______________________________________________________

### Decision

- [ ] **PASS** - Ready for production with current state
- [ ] **PASS WITH NOTES** - Minor issues acceptable, document workarounds
- [ ] **FAIL** - Critical issues must be fixed, another rehearsal needed

### Next Steps

1. _______________________________________________________
2. _______________________________________________________
3. _______________________________________________________

### Sign-off

**QA Lead:** _________________ Date: _______  
**Technical Lead:** _________________ Date: _______  
**Project Lead:** _________________ Date: _______

---

## Notes

Use this space for any additional observations:

_______________________________________________________
_______________________________________________________
_______________________________________________________
_______________________________________________________
_______________________________________________________
