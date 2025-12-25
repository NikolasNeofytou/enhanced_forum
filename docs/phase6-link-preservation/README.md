# Phase 6: Link Preservation and Redirects

## Objective

Ensure old phpBB links continue to work (SEO + legacy usability).

## Why This Matters

**The forum has been online for years:**
- 800k+ posts indexed by Google
- Countless external links from:
  - Student notes and documents
  - Email archives
  - Social media shares
  - University resources
  - External websites

**Breaking these links means:**
- ❌ Lost SEO rankings
- ❌ User frustration (404 errors)
- ❌ Broken institutional knowledge

---

## Understanding phpBB URL Patterns

### Common phpBB URLs

```
# View topic
/viewtopic.php?t=12345
/viewtopic.php?f=5&t=12345
/viewtopic.php?p=67890#p67890  (specific post with anchor)

# View forum/category
/viewforum.php?f=5

# User profile
/memberlist.php?mode=viewprofile&u=123

# Search
/search.php

# Index
/index.php
```

### With URL Rewriting (if phpBB had SEO URLs)

```
/topic-title-12345.html
/forum-name-f5.html
/user-username-u123.html
```

---

## Discourse URL Patterns

### Standard Discourse URLs

```
# Topic
/t/topic-slug/12345
/t/topic-slug/12345/2  (page 2)
/t/12345  (short form, redirects to full)

# Specific post
/t/topic-slug/12345/10  (10th post)

# Category
/c/category-slug/5

# User profile
/u/username

# Search
/search
```

---

## Redirect Strategy

### Built-in Permalink System

**Discourse includes a permalink system:**

The phpBB importer automatically creates permalinks during import!

**How it works:**
1. Importer creates entries in `permalinks` table
2. Maps old URLs to new Discourse URLs
3. Discourse checks permalinks for 404s and redirects

**Example permalink entries:**

| URL | Topic ID | Post ID | Category ID |
|-----|----------|---------|-------------|
| /viewtopic.php?t=12345 | 100 | - | - |
| /viewtopic.php?p=67890 | - | 500 | - |
| /viewforum.php?f=5 | - | - | 25 |

**Discourse then redirects:**
- `/viewtopic.php?t=12345` → `/t/topic-slug/100`
- `/viewtopic.php?p=67890` → `/t/topic-slug/100/25` (25th post)
- `/viewforum.php?f=5` → `/c/category-slug/25`

### Permalink Configuration

**The importer handles this automatically**, but you can verify:

```bash
# In Discourse Rails console
./launcher enter app
rails c

# Check permalink count
Permalink.count

# Sample permalinks
Permalink.limit(10).each { |p| puts "#{p.url} → Topic:#{p.topic_id} Post:#{p.post_id}" }
```

### Additional Redirect Rules

**For patterns not covered by permalinks, use web server redirects:**

**Nginx configuration (`/etc/nginx/conf.d/discourse-redirects.conf`):**

```nginx
# Redirect old index to new index
rewrite ^/index\.php$ / permanent;

# User profiles
rewrite ^/memberlist\.php\?mode=viewprofile&u=([0-9]+)$ /u/user-$1 permanent;

# Search
rewrite ^/search\.php(.*)$ /search$1 permanent;

# Generic phpBB patterns (fallback)
rewrite ^/viewtopic\.php(.*)$ /phpbb-fallback/viewtopic$1 permanent;
rewrite ^/viewforum\.php(.*)$ /phpbb-fallback/viewforum$1 permanent;
```

**Apache configuration (`.htaccess`):**

```apache
# Redirect old index
RewriteRule ^index\.php$ / [R=301,L]

# User profiles
RewriteCond %{QUERY_STRING} mode=viewprofile&u=([0-9]+)
RewriteRule ^memberlist\.php$ /u/user-%1? [R=301,L]

# Search
RewriteRule ^search\.php(.*)$ /search$1 [R=301,L]
```

---

## Implementation Steps

### Step 1: Verify Permalink Creation

**After import on staging:**

```ruby
# In Rails console
rails c

# Total permalinks
puts "Total permalinks: #{Permalink.count}"

# Expected: ~21,849 topic permalinks + forum permalinks

# Breakdown
puts "Topic permalinks: #{Permalink.where.not(topic_id: nil).count}"
puts "Post permalinks: #{Permalink.where.not(post_id: nil).count}"
puts "Category permalinks: #{Permalink.where.not(category_id: nil).count}"
```

**If counts are off:**
- Reimport with permalink creation enabled
- Check importer logs for errors

### Step 2: Test Permalink Resolution

**Manual testing:**

1. **Find a phpBB URL:**
   ```
   http://old-forum.example.com/viewtopic.php?t=100
   ```

2. **Try on staging Discourse:**
   ```
   http://staging-forum.example.com/viewtopic.php?t=100
   ```

3. **Expected behavior:**
   - Discourse recognizes URL
   - Redirects to `/t/topic-slug/[new-id]`
   - HTTP 301 (permanent redirect)

4. **Verify:**
   ```bash
   curl -I http://staging-forum.example.com/viewtopic.php?t=100
   # Should show:
   # HTTP/1.1 301 Moved Permanently
   # Location: /t/topic-slug/...
   ```

### Step 3: Configure Web Server Redirects

**Add additional redirect rules for non-topic URLs:**

**For Nginx (Discourse default Docker setup):**

```bash
# On Discourse server
cd /var/discourse
nano containers/app.yml
```

**Add to the volumes section:**
```yaml
volumes:
  - volume:
      host: /var/discourse/shared/standalone/nginx-redirects.conf
      guest: /etc/nginx/conf.d/redirects.conf
```

**Create redirect config:**
```bash
nano /var/discourse/shared/standalone/nginx-redirects.conf
```

**Add redirects:**
```nginx
# Legacy phpBB redirects

# Index
rewrite ^/index\.php$ / permanent;

# Profile redirects require custom handling
# Option 1: Redirect to generic /users page
rewrite ^/memberlist\.php(.*)$ /users permanent;

# Search
rewrite ^/search\.php$ /search permanent;

# Handle old attachment downloads if needed
# rewrite ^/download/file\.php\?id=([0-9]+)$ /uploads/...; # Custom logic needed
```

**Rebuild Discourse to apply:**
```bash
./launcher rebuild app
```

### Step 4: Handle Edge Cases

#### Old Attachment URLs

**phpBB pattern:**
```
/download/file.php?id=12345
```

**Challenge:** Attachments are now in Discourse's upload system with different URLs

**Solution options:**

**Option A: Let them 404, document in FAQ**
- Attachments are visible in posts
- Direct download links deprecated

**Option B: Custom redirect script**
- Map old attachment IDs to new upload URLs
- Requires custom development

**Option C: Preserve old attachment URLs**
- Keep old attachment files accessible
- Serve via web server at old paths

#### User Profile URLs

**phpBB pattern:**
```
/memberlist.php?mode=viewprofile&u=123
```

**Challenge:** Need to map phpBB user IDs to Discourse usernames

**Solution: Create custom redirect script**

```ruby
# In Discourse plugin or Rails console
# Create permalink entries for users

User.find_each do |user|
  # Assuming custom_field stores old phpBB user ID
  phpbb_user_id = user.custom_fields['phpbb_user_id']
  if phpbb_user_id
    Permalink.create!(
      url: "memberlist.php?mode=viewprofile&u=#{phpbb_user_id}",
      external_url: "/u/#{user.username}"
    )
  end
end
```

---

## Redirect Testing

### Automated Redirect Testing

**Create test suite of old URLs:**

```bash
# test-redirects.sh
#!/bin/bash

FORUM_URL="http://staging-forum.example.com"
PASS=0
FAIL=0

test_redirect() {
    local old_url=$1
    local expected_pattern=$2
    
    response=$(curl -s -o /dev/null -w "%{http_code}:%{redirect_url}" "${FORUM_URL}${old_url}")
    http_code=$(echo $response | cut -d: -f1)
    redirect_url=$(echo $response | cut -d: -f2-)
    
    if [[ $http_code == "301" || $http_code == "302" ]]; then
        if [[ $redirect_url =~ $expected_pattern ]]; then
            echo "✅ PASS: $old_url → $redirect_url"
            ((PASS++))
        else
            echo "❌ FAIL: $old_url → $redirect_url (expected: $expected_pattern)"
            ((FAIL++))
        fi
    else
        echo "❌ FAIL: $old_url → HTTP $http_code"
        ((FAIL++))
    fi
}

# Test cases
echo "Testing phpBB URL redirects..."
echo "================================"

# Topics
test_redirect "/viewtopic.php?t=1" "/t/"
test_redirect "/viewtopic.php?t=100" "/t/"
test_redirect "/viewtopic.php?t=1000" "/t/"

# Forums
test_redirect "/viewforum.php?f=1" "/c/"
test_redirect "/viewforum.php?f=5" "/c/"

# Index
test_redirect "/index.php" "/"

# Search
test_redirect "/search.php" "/search"

echo "================================"
echo "Results: $PASS passed, $FAIL failed"
```

**Run tests:**
```bash
chmod +x test-redirects.sh
./test-redirects.sh
```

### Manual Testing Sample

**Create a test matrix (200-500 URLs recommended):**

| Old URL | Expected Destination | Actual Redirect | Status | Notes |
|---------|---------------------|-----------------|--------|-------|
| `/viewtopic.php?t=1` | `/t/welcome/1` | `/t/welcome/1` | ✅ | OK |
| `/viewtopic.php?t=100` | `/t/*/100` | `/t/course-help/100` | ✅ | OK |
| `/viewforum.php?f=5` | `/c/academic/5` | `/c/academic/5` | ✅ | OK |
| `/index.php` | `/` | `/` | ✅ | OK |
| `/memberlist.php?u=1` | `/u/admin` | 404 | ❌ | Need custom redirect |

**Sampling strategy:**
- 50 oldest topics (ID 1-50)
- 50 newest topics (ID [max-50] to [max])
- 50 most-viewed topics (from phpBB stats)
- 50 random topics
- All forum/category URLs
- Sample user profiles
- Other common patterns

### Google Search Console Testing

**After cutover, monitor:**

1. **Crawl errors:**
   - Google Search Console → Coverage
   - Look for 404 errors on old URLs

2. **Redirect chains:**
   - Ensure redirects are direct (no chains)

3. **Indexed pages:**
   - Monitor that indexed pages transfer to new URLs
   - May take weeks for full re-index

---

## SEO Preservation

### Pre-Migration SEO Audit

**Document current state:**

1. **Google indexed pages:**
   ```
   site:forum.example.com
   ```
   - Note: Total results

2. **Top landing pages:**
   - Google Analytics → Behavior → Landing Pages
   - Export top 100 pages

3. **External backlinks:**
   - Google Search Console → Links → Top linking sites
   - Ahrefs / Moz (if available)

### Post-Migration SEO Tasks

1. **Update sitemap:**
   - Discourse generates sitemap automatically
   - Submit to Google Search Console: `/sitemap.xml`

2. **Request re-crawl:**
   - Google Search Console → URL Inspection
   - Request indexing for top pages

3. **Monitor rankings:**
   - Track keyword positions
   - Watch for ranking drops (investigate if >20% drop)

4. **Fix any broken links:**
   - Use Screaming Frog or similar to crawl new site
   - Identify and fix broken internal links

---

## Deliverables

### 1. Redirect Strategy Document

**Contents:**
- URL patterns covered
- Redirect mechanisms used
- Edge cases and how they're handled
- What will 404 (if anything)

**Template:** See [redirect-strategy.md](./redirect-strategy.md)

### 2. Redirect Test Suite

**Automated tests for common URL patterns**

**Files:**
- `test-redirects.sh` - Bash script to test redirects
- `redirect-test-cases.csv` - Sample URLs to test

**See:** [/scripts/redirect-tests/](../../scripts/redirect-tests/)

### 3. Test Results

**Documentation of test results:**

**Summary metrics:**
- Total URLs tested: [Number]
- Successful redirects: [Number] ([Percentage]%)
- Failed redirects: [Number] ([Percentage]%)
- Acceptable failures: [Number] (with reasons)

---

## Success Criteria

- [ ] Permalink system operational
- [ ] 90%+ of old topic URLs redirect correctly
- [ ] 90%+ of old forum URLs redirect correctly
- [ ] Common user paths work (index, search)
- [ ] Redirect test suite passes
- [ ] No redirect chains (direct 301s)
- [ ] Web server redirects configured
- [ ] Edge cases documented
- [ ] Team trained on handling redirect issues

---

## Troubleshooting

### Issue: Permalinks not working

**Symptoms:** Old URLs return 404

**Check:**
```ruby
rails c
Permalink.where("url LIKE ?", "%viewtopic%").count
# Should be > 0
```

**Fix:**
- Reimport with permalink creation enabled
- Check importer version (older versions may not create permalinks)

### Issue: Redirects create loops

**Symptoms:** Browser shows "too many redirects"

**Check:**
- Nginx/Apache config for conflicting rules
- Discourse permalink interfering with web server rule

**Fix:**
- Review and simplify redirect rules
- Ensure web server passes through to Discourse for permalink handling

### Issue: Some topics redirect, others don't

**Symptoms:** Inconsistent behavior

**Check:**
- Permalink database entries complete
- Topic IDs correctly mapped

**Debug:**
```ruby
rails c
topic_id = 12345
Permalink.find_by(url: "viewtopic.php?t=#{topic_id}")
# Should return permalink object
```

---

## Next Steps

Once Phase 6 is complete, proceed to [Phase 7: Authentication Strategy](../phase7-authentication/)
