# Phase 3: Target Architecture and Environments

## Objective

Stand up staging and production Discourse environments using best practices.

## Required Environments

### 1. Staging Environment

**Purpose:**
- Run and refine migration scripts
- Test import results
- Validate data quality
- Train administrators and moderators
- Practice cutover procedures

**Characteristics:**
- Identical to production configuration
- Can be rebuilt multiple times
- Contains test/migrated data (not live)
- Not publicly accessible

### 2. Production Environment

**Purpose:**
- Final live forum site
- Serves real users
- Permanent data storage

**Characteristics:**
- Production-grade infrastructure
- High availability (if needed)
- Automated backups
- Monitoring and alerting

---

## Recommended Architecture

### Baseline: Official Discourse Docker Deployment

Discourse strongly recommends their Docker-based deployment:

**Reference:** [Official Installation Guide](https://github.com/discourse/discourse/blob/main/docs/INSTALL-cloud.md)

**Why Docker:**
- ✅ Official support from Discourse team
- ✅ Simplified updates and maintenance
- ✅ Consistent environment (dev/staging/prod)
- ✅ Built-in best practices
- ✅ Active community support

**Requirements:**
- Linux server (Ubuntu 20.04+ recommended)
- 2+ GB RAM (4+ GB recommended for 10k+ users)
- 2+ CPU cores
- 40+ GB disk space (more for attachments/backups)
- Docker and Docker Compose installed

---

## Infrastructure Options

### Option 1: Cloud VPS (Recommended)

**Providers:**
- DigitalOcean (easiest, Discourse has guides)
- AWS EC2
- Google Cloud Compute Engine
- Azure Virtual Machines
- Linode
- Hetzner

**Recommended Specs for SHMMY Forum (11k+ users, 800k+ posts):**

**Staging:**
- 2 vCPU
- 4 GB RAM
- 80 GB SSD
- Cost: ~$20-40/month

**Production:**
- 4 vCPU
- 8 GB RAM
- 160 GB SSD (or separate attachment storage)
- Cost: ~$40-80/month

### Option 2: On-Premise Server

**Use if:**
- University has existing infrastructure
- Compliance requires on-premise hosting
- Hardware already available

**Same specs as cloud VPS apply**

### Option 3: Managed Discourse Hosting

**Provider:** discourse.org offers managed hosting

**Pros:**
- Zero infrastructure management
- Automatic updates
- Expert support
- Built-in CDN and backups

**Cons:**
- Higher cost (~$100-300/month for your size)
- Less control over infrastructure

**Recommended for:** Organizations without DevOps resources

---

## Storage Architecture

### Option A: Local Storage (Simplest)

**Attachments stored on same server as Discourse**

**Pros:**
- Simpler setup
- No additional services
- Works with standard Docker install

**Cons:**
- Backups include large attachment files
- Scaling requires larger disk
- Server replacement is complex

**Recommended for:** <50 GB total attachments

### Option B: Object Storage (Recommended for Scale)

**Attachments stored in S3-compatible storage**

**Providers:**
- AWS S3
- DigitalOcean Spaces
- Backblaze B2
- MinIO (self-hosted)
- Wasabi

**Pros:**
- Decoupled from server
- Easier backups (exclude attachments)
- Better scaling
- Potential cost savings

**Cons:**
- Additional service to configure
- Slight complexity increase

**Recommended for:** >50 GB attachments (estimate from Phase 2 audit)

**Configuration:**
- See `app.yml` configuration for S3 settings
- Set `DISCOURSE_S3_BUCKET`, `DISCOURSE_S3_REGION`, etc.

---

## Installation Steps

### Step 1: Server Provisioning

**For Cloud VPS:**

1. **Create server instances:**
   - Staging: [Provider], [Region], [Size]
   - Production: [Provider], [Region], [Size]

2. **Configure DNS:**
   - Staging: `staging-forum.example.com` → [Staging IP]
   - Production: `forum.example.com` → [Production IP]
   - Lower TTL before migration (300s)

3. **Basic server setup:**
   ```bash
   # Update system
   apt-get update && apt-get upgrade -y
   
   # Install Docker
   wget -qO- https://get.docker.com/ | sh
   
   # Install Git
   apt-get install -y git
   ```

### Step 2: Discourse Installation

**Following official guide:**

1. **Clone Discourse Docker:**
   ```bash
   mkdir /var/discourse
   git clone https://github.com/discourse/discourse_docker.git /var/discourse
   cd /var/discourse
   ```

2. **Run setup script:**
   ```bash
   ./discourse-setup
   ```

3. **Configure during setup:**
   - Hostname: `staging-forum.example.com` or `forum.example.com`
   - Admin email: [your email]
   - SMTP settings:
     - Address: [smtp server]
     - Username: [smtp username]
     - Password: [smtp password]
     - Port: [587 or 465]
   - Let's Encrypt email: [email for SSL cert]

4. **Edit configuration if needed:**
   ```bash
   nano containers/app.yml
   ```

5. **Build and launch:**
   ```bash
   ./launcher rebuild app
   ```

6. **Verify installation:**
   - Visit: `https://staging-forum.example.com`
   - Create admin account
   - Test posting, email delivery

### Step 3: Post-Installation Configuration

**Essential Settings:**

1. **Admin Configuration:**
   - Navigate to `/admin`
   - Set site title, description
   - Upload logo, favicon
   - Configure basic settings

2. **Email Configuration:**
   - Test email sending: Admin → Email → Send Test Email
   - Verify deliverability
   - Configure email templates

3. **Security Settings:**
   - Force HTTPS: Should be automatic with Let's Encrypt
   - Set up API keys (for scripts)
   - Configure rate limits

4. **Backup Configuration:**
   ```yaml
   # In app.yml, add:
   - exec: rails r "SiteSetting.backup_location = 's3'"  # If using S3
   - exec: rails r "SiteSetting.s3_backup_bucket = 'your-backup-bucket'"
   ```

5. **Performance Settings:**
   - Enable CDN (if available)
   - Configure cache settings
   - Set up Redis (included in Docker)

---

## Object Storage Setup (If Using)

### For AWS S3:

1. **Create S3 buckets:**
   - Uploads: `discourse-uploads-yoursite`
   - Backups: `discourse-backups-yoursite`

2. **Create IAM user with policy:**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": ["s3:*"],
         "Resource": [
           "arn:aws:s3:::discourse-uploads-yoursite/*",
           "arn:aws:s3:::discourse-backups-yoursite/*"
         ]
       }
     ]
   }
   ```

3. **Configure in app.yml:**
   ```yaml
   env:
     DISCOURSE_S3_BUCKET: "discourse-uploads-yoursite"
     DISCOURSE_S3_REGION: "us-east-1"
     DISCOURSE_S3_ACCESS_KEY_ID: "your-access-key"
     DISCOURSE_S3_SECRET_ACCESS_KEY: "your-secret-key"
     DISCOURSE_S3_BACKUP_BUCKET: "discourse-backups-yoursite"
     DISCOURSE_BACKUP_LOCATION: "s3"
   ```

4. **Rebuild container:**
   ```bash
   ./launcher rebuild app
   ```

---

## Backup Configuration

### Automated Backups

**Discourse includes built-in backup:**

1. **Enable automatic backups:**
   - Admin → Backups
   - Enable automatic backups: Yes
   - Backup frequency: Daily
   - Maximum backups to keep: 7 (or more)

2. **Backup location:**
   - Local: `/var/discourse/shared/standalone/backups/default/`
   - S3: Configured bucket (recommended)

3. **Backup schedule:**
   - Daily at 3:00 AM (configurable)
   - Includes database and uploads
   - Compressed tar.gz format

### Manual Backup

**Before major changes (e.g., updates, migrations):**

```bash
# Enter Discourse container
cd /var/discourse
./launcher enter app

# Create backup
rake backup:create

# Exit container
exit
```

### Backup Testing

**Critical: Test restore process!**

1. **Download backup:**
   - Admin → Backups → Download backup file

2. **Test restore on staging:**
   - Admin → Backups → Upload backup
   - Click "Restore"
   - Verify data integrity

**Schedule:** Test restore quarterly

---

## Monitoring and Alerting

### Built-in Monitoring

**Discourse Dashboard:**
- Admin → Dashboard
- Shows: User activity, post rates, response times, errors
- Check daily during stabilization period

### Infrastructure Monitoring

**Recommended tools:**

1. **Server metrics:**
   - CPU, Memory, Disk usage
   - Tools: htop, netdata, Prometheus
   
2. **Uptime monitoring:**
   - UptimeRobot (free tier)
   - Pingdom
   - StatusCake
   - Check: HTTPS endpoint every 5 minutes

3. **Log monitoring:**
   ```bash
   # Discourse logs
   cd /var/discourse
   ./launcher logs app
   
   # Follow logs
   ./launcher logs app --tail
   ```

4. **Email deliverability:**
   - Monitor bounce rates
   - Admin → Email → Sent, Bounced, Rejected

### Alerting

**Set up alerts for:**
- Server down (>5 minutes)
- Disk usage >80%
- Memory usage >90%
- High error rates in logs
- Email delivery failures

**Notification channels:**
- Email to admin team
- Slack/Discord webhook (optional)
- SMS for critical (optional)

---

## Security Hardening

### Server-Level Security

1. **Firewall configuration:**
   ```bash
   # UFW (Ubuntu)
   ufw allow 22/tcp   # SSH
   ufw allow 80/tcp   # HTTP
   ufw allow 443/tcp  # HTTPS
   ufw enable
   ```

2. **SSH hardening:**
   - Use key-based authentication
   - Disable root login
   - Change default port (optional)
   - Fail2ban for brute-force protection

3. **Automatic security updates:**
   ```bash
   apt-get install unattended-upgrades
   dpkg-reconfigure -plow unattended-upgrades
   ```

### Discourse-Level Security

1. **Admin → Settings → Security:**
   - Enable force HTTPS: Yes
   - Enable HSTS: Yes
   - Content Security Policy: Enabled

2. **API rate limiting:**
   - Configure in Admin → Settings → Rate Limits

3. **Regular updates:**
   ```bash
   cd /var/discourse
   git pull
   ./launcher rebuild app
   ```
   - Check for updates weekly
   - Subscribe to Discourse security announcements

---

## Infrastructure as Code

### Configuration Management

**Store your configuration:**

1. **app.yml template:**
   - Save your configured `containers/app.yml`
   - Remove sensitive values
   - Version control in private repo

2. **Environment variables:**
   - Document all required env vars
   - Use secret management (not in git)

3. **DNS records:**
   - Document A records, MX records, TXT records
   - Include SPF, DKIM, DMARC

### Deployment Script

**Example automation:**

```bash
#!/bin/bash
# deploy-discourse.sh - Staging/Production deployment

ENVIRONMENT=$1  # staging or production

if [ "$ENVIRONMENT" == "staging" ]; then
    HOST="staging-forum.example.com"
    SSH_USER="admin"
elif [ "$ENVIRONMENT" == "production" ]; then
    HOST="forum.example.com"
    SSH_USER="admin"
else
    echo "Usage: ./deploy-discourse.sh [staging|production]"
    exit 1
fi

echo "Deploying to $ENVIRONMENT ($HOST)"

# SSH into server and update
ssh $SSH_USER@$HOST << 'EOF'
cd /var/discourse
git pull
./launcher rebuild app
EOF

echo "Deployment complete!"
```

---

## Deliverables

### Documentation

- [ ] **Infrastructure diagram**
  - Server specs, regions, IPs
  - Storage architecture
  - Backup strategy
  
- [ ] **Access credentials inventory**
  - Server SSH keys
  - Discourse admin accounts
  - SMTP credentials
  - S3/storage credentials
  - (Store securely, not in git!)

- [ ] **Configuration files**
  - `app.yml` template
  - Environment variables list
  - DNS records

### Runbooks

- [ ] **Deployment runbook**
  - Fresh install steps
  - Configuration checklist
  - Verification steps

- [ ] **Backup/Restore runbook**
  - How to create manual backup
  - How to restore from backup
  - Where backups are stored
  - Restore testing procedure

- [ ] **Update runbook**
  - How to update Discourse
  - Pre-update backup
  - Rollback procedure

- [ ] **Troubleshooting guide**
  - Common issues and solutions
  - How to access logs
  - Emergency contacts

---

## Environment Checklist

### Staging Environment

- [ ] Server provisioned and accessible
- [ ] Docker and Discourse installed
- [ ] DNS configured (staging-forum.example.com)
- [ ] SSL certificate issued and working
- [ ] Email sending configured and tested
- [ ] Admin account created
- [ ] Basic settings configured
- [ ] Backups configured (optional for staging)
- [ ] Ready for migration testing

### Production Environment

- [ ] Server provisioned and accessible
- [ ] Docker and Discourse installed
- [ ] DNS configured (forum.example.com)
- [ ] SSL certificate issued and working
- [ ] Email sending configured and tested
- [ ] Admin account created
- [ ] All settings configured
- [ ] Automatic backups enabled and tested
- [ ] Monitoring and alerting configured
- [ ] Security hardening complete
- [ ] Restore test successful
- [ ] Ready for cutover

---

## Success Criteria

- [ ] Both staging and production environments are operational
- [ ] All services (email, storage) are working
- [ ] Backups are running and tested
- [ ] Monitoring is in place
- [ ] Documentation is complete
- [ ] Team has admin access
- [ ] Infrastructure is secure and hardened

---

## Next Steps

Once Phase 3 is complete, proceed to [Phase 4: Information Architecture Mapping](../phase4-information-architecture/)
