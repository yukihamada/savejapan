# How I Left Mercari to Protect 3.8 Million Japanese Businesses from Cyber Threats

*The story behind SaveJapan, a 3-in-1 cybersecurity platform built in Rust*

---

## The $64.5K Wake-Up Call

It was 3 AM when I got the Slack notification. One of our portfolio startups had been hit with a ¥7.2M ($64,500) AWS bill – in a single month.

The cause? A compromised API key in a public GitHub repo. An automated scraper found it within 6 hours of the commit. By the time they noticed, crypto miners had been running on EC2 for 29 days.

This wasn't a sophisticated attack. No zero-days. No APTs. Just basic security hygiene that no one had taught them.

That's when I realized: **Japan's 3.8 million SMBs are sitting ducks.**

---

## Why I Left Mercari

After 4 years as CPO at Mercari, I had seen world-class security operations:
- 24/7 SOC team
- Penetration testing every quarter
- Bug bounty program with $500K+ payouts
- Dedicated security engineers on every product team

But when I talked to SMB owners – including my own family running a 50-person dojo – I heard the same problems:

**"We don't know if we're secure"**
Professional security audits cost ¥500,000+. Most SMBs can't afford it.

**"Training is all in English"**
Cybersecurity courses on Udemy, Coursera are English-only. Japanese business owners need content that matches their context.

**"We got phished, but don't know how to prevent it"**
One email. One click. Ransomware locks everything. ¥2M ransom demand. No recovery plan.

The gap was enormous. And it was getting worse:
- Phishing attacks in Japan: **+340% YoY** (2024-2025)
- Ransomware targeting SMBs: **+210% YoY**
- Average recovery cost: **¥12M per incident**

I decided to leave Mercari and build SaveJapan.

---

## The 3-Layer Defense Philosophy

Security isn't a product. It's a journey.

Most security vendors try to sell you everything at once: SIEM, EDR, DLP, CASB... alphabet soup of acronyms that confuse more than they clarify.

I took a different approach: **Meet businesses where they are.**

### Layer 1: Awareness (chatnews.tech/scan)

"You can't fix what you can't measure."

Most SMBs don't know their security baseline. Are they using HTTPS? Is their SSL certificate valid? Do they have security headers?

**Solution: Free Security Scanner**
- Enter any URL
- Get A-F security score in 2 seconds
- Actionable recommendations (no jargon)
- 100% free, forever

**Impact:**
- 10,000+ scans completed
- Average score: C+ (room for improvement!)
- 68% of scans revealed critical issues

### Layer 2: Education (dojoc.io)

"Knowledge is the best defense."

Once you know you have problems, what do you do? Hire a ¥10M/year CISO? Not realistic for 50-person companies.

**Solution: DojoC – Cybersecurity Courses**
- 3 levels: Beginner → Intermediate → Advanced
- 45 lessons total
- 100% Japanese (cultural context included)
- Digital certificates + LinkedIn badges

**Real courses:**
- "AI Security for Startups 2026"
- "OWASP Top 10 for Japanese Web Apps"
- "Incident Response Playbook (GDPR + APPI)"

**Impact:**
- 1,200+ students
- 89% pass rate
- 156 companies enrolled

### Layer 3: Practice (enabler.cc)

"Employees are the last line of defense."

91% of cyberattacks start with phishing. You can teach theory, but people need practice.

**Solution: PhishGuard – Phishing Simulation**
- 50+ Japanese email templates
- Real scenarios: expense reports, password resets, shipping notifications
- Real-time dashboard: open rate, click rate, report rate
- Department-level risk scores

**Impact:**
- 156 companies deployed
- 75% click rate reduction (average 3 months)
- 2 ransomware attempts prevented (confirmed)

---

## Why We Built It in Rust

I chose Rust for SaveJapan's backend. Here's why:

### 1. Security Tools Can't Have Vulnerabilities

Ironic if your security scanner crashes from a buffer overflow, right?

Rust's memory safety guarantees mean:
- No null pointer dereferences
- No use-after-free
- No data races

We've run SaveJapan for 8 months. **Zero security incidents. Zero crashes.**

### 2. Performance Matters at Scale

Our scanner checks 50+ security parameters per URL:
- HTTPS status
- SSL certificate validation
- Security headers (CSP, HSTS, X-Frame-Options, etc.)
- DNS records
- WHOIS data
- Known vulnerability databases

**Before (Python + Django):**
- 8-12 seconds per scan
- 512MB memory idle
- Max 100 concurrent users

**After (Rust + Axum):**
- 1.5-2 seconds per scan (5x faster)
- 28MB memory idle (18x less)
- 10,000+ concurrent users (100x scale)

### 3. One Codebase, Three Products

Challenge: We have 3 separate domains but shared logic.

Rust's module system + Cargo workspaces = perfect solution.

```rust
// Shared scoring engine
pub fn calculate_security_score(
    https: bool,
    ssl_valid: bool,
    headers: &SecurityHeaders,
) -> SecurityScore {
    let mut score = 100;

    if !https { score -= 40; }
    if !ssl_valid { score -= 30; }
    score -= headers.missing_count() * 5;

    SecurityScore::from_value(score)
}
```

This function powers:
- Scanner results page
- DojoC course exercises
- PhishGuard security posture tracking

---

## The Japanese Market Challenge

Building for Japan isn't just translation. It's a completely different context.

### Cultural Phishing Patterns

English phishing emails:
```
URGENT: Your account has been compromised!
Click here to verify: http://evil.com
```

Japanese phishing emails:
```
いつもお世話になっております。

経理部の田中と申します。
先月分の経費精算に関しまして、
添付ファイルをご確認いただけますでしょうか。

お手数をおかけしますが、
よろしくお願いいたします。
```

Notice the difference?
- Polite keigo (敬語) throughout
- Realistic department names
- Plausible business context
- NO urgency (cultural difference)

Our phishing templates are written by native speakers who understand Japanese business culture.

### Compliance: APPI vs. GDPR

Japan's Act on Protection of Personal Information (APPI) has different requirements than GDPR:

| Aspect | GDPR | APPI |
|--------|------|------|
| Consent | Explicit opt-in | Implied consent OK |
| Data transfer | DPA required | Easier Asia transfer |
| Breach notification | 72 hours | "Without delay" |
| Fines | Up to 4% revenue | Up to ¥100M |

SaveJapan is architected for APPI compliance:
- All data in Tokyo datacenter (Fly.io)
- No cross-border transfers
- Japanese-language privacy policy
- Transparent data retention (90 days default)

---

## Real Impact: Case Study

**Company:** 50-person manufacturing company (Osaka)
**Industry:** Industrial parts
**Problem:** High phishing susceptibility, no security baseline

### Before SaveJapan
- **Security Score:** F (28/100)
- **Phishing Click Rate:** 68%
- **Security Awareness:** "What's HTTPS?"
- **Incidents:** 1 ransomware scare (recovered from backup)

### Implementation (3 months)
**Month 1:**
- Free scan revealed 14 critical issues
- Fixed HTTPS, SSL, security headers
- Security score: C+ (74/100)

**Month 2:**
- 15 employees enrolled in DojoC Beginner course
- 89% completion rate
- First phishing simulation: 51% click rate (improvement!)

**Month 3:**
- Weekly phishing simulations
- Department competition (lowest click rate wins)
- Advanced course for IT team

### After SaveJapan
- **Security Score:** A- (92/100)
- **Phishing Click Rate:** 17% (75% reduction)
- **Security Awareness:** Regular training embedded in culture
- **Incidents:** 2 phishing attempts detected and reported by employees

**ROI:** ¥29,800/month investment prevented estimated ¥8M+ in potential ransomware costs.

---

## Open Source Contributions

We believe security is a community effort. We've open-sourced:

### 1. rust-security-headers
Parser and validator for HTTP security headers.

```rust
use rust_security_headers::SecurityHeaders;

let headers = SecurityHeaders::from_response(&response);
let score = headers.calculate_score();

println!("CSP: {}", headers.csp.is_some());
println!("HSTS: {}", headers.hsts.is_some());
println!("Score: {}/100", score);
```

**GitHub:** github.com/savejapan/rust-security-headers
**Downloads:** 2,400+ on crates.io

### 2. jp-phishing-corpus
500+ anonymized Japanese phishing emails for research.

- Real-world samples (personally identifiable info removed)
- Labeled by attack type
- Ideal for ML training

**GitHub:** github.com/savejapan/jp-phishing-corpus
**Stars:** 340+

---

## Tech Stack Deep Dive

For the engineers reading this:

### Backend
```
Rust 1.75 + Axum 0.7
├── Tokio (async runtime)
├── SQLx (type-safe DB queries)
├── Tower (middleware)
└── Serde (serialization)
```

**Why Axum over Actix-web?**
- Better ergonomics with extractors
- Tower ecosystem compatibility
- Active development + backing from Tokio team

### Frontend
```
Next.js 15 + React + TypeScript
├── TailwindCSS (styling)
├── Shadcn/ui (components)
├── React Query (data fetching)
└── Recharts (analytics)
```

### Database
```
Supabase (PostgreSQL 15)
├── Row-level security (RLS)
├── Realtime subscriptions
├── Built-in auth
└── PostGIS (future: threat mapping)
```

### Infrastructure
```
Fly.io (Tokyo region)
├── 4x 256MB instances (auto-scaling)
├── 99.9% uptime SLA
├── <50ms latency in Japan
└── $80/month cost
```

### Monitoring
```
Sentry (error tracking)
Grafana (metrics)
PostHog (product analytics)
```

---

## Lessons Learned

### 1. Start with CLI, Then Build API

Our scanner started as a CLI tool:
```bash
$ cargo run -- scan https://example.com
```

This forced us to:
- Separate concerns (CLI vs. business logic)
- Design a clean API surface
- Write testable code from day 1

Later, adding the web API was trivial:
```rust
async fn scan_handler(
    Path(url): Path<String>
) -> Json<ScanResult> {
    // Same function as CLI
    let result = scan_url(&url).await?;
    Json(result)
}
```

### 2. Japanese UX ≠ English UX

Western design: Minimalism, whitespace, "less is more"
Japanese design: Density, information richness, "show me everything"

We A/B tested our scanner results page:

**Version A (Western):**
- Big A-F score
- 3 bullet points
- "Learn more" button

**Version B (Japanese):**
- A-F score + numeric (87/100)
- 12 detailed findings
- Expandable recommendations
- Comparison to industry average

**Result:** Version B had 3x higher engagement. Japanese users wanted density.

### 3. Don't Prematurely Optimize

I spent 2 weeks optimizing our scanner with:
- Custom connection pooling
- Request batching
- Aggressive caching

**Impact:** 2.1s → 1.8s (14% improvement)

Then I realized: **No one cared about 0.3 seconds.**

What users actually wanted:
- More security checks (added 15 new ones)
- Better explanations (rewrote all copy)
- PDF reports (took 1 day to build)

**Lesson:** Optimize for user value, not benchmarks.

### 4. Rust Compile Times Are Real

Full rebuild: 4-6 minutes on M1 Max.

Our solution:
```toml
# Cargo.toml
[profile.dev]
split-debuginfo = "unpacked"
incremental = true

[profile.dev.package."*"]
opt-level = 1  # Slightly optimize dependencies
```

Incremental rebuild: 15-30 seconds (acceptable).

Also: `cargo-watch` for auto-recompile during development.

---

## What's Next

### Q2 2026: AI Threat Detection

We're training a model on our jp-phishing-corpus to:
- Detect zero-day phishing campaigns
- Predict attack trends
- Auto-generate defensive playbooks

**Tech:** Fine-tuned Claude 3.5 on Japanese business emails.

### Q3 2026: Browser Extension

Real-time phishing detection while browsing.

**Tech:** Rust → WASM → Chrome/Firefox extension

### Q4 2026: Community Threat Intelligence

Crowdsourced threat database:
- Companies share anonymized attack data
- AI aggregates patterns
- Real-time alerts to community

**Privacy:** Differential privacy + federated learning.

---

## Pricing Philosophy

Traditional security vendors:
- Enterprise-only (minimum ¥1M/year)
- Sales calls required
- Hidden pricing

SaveJapan:
- Transparent pricing on website
- Free tier (forever)
- Self-serve signup
- Cancel anytime

| Plan | Price | Best For |
|------|-------|----------|
| **Free** | ¥0 | Startups, scanning |
| **Starter** | ¥9,800/mo | 1-20 employees |
| **Business** | ¥29,800/mo | 20-100 employees |
| **Enterprise** | Custom | 100+ employees |

**Why affordable?**
Rust's efficiency = lower infrastructure costs = savings passed to customers.

---

## Join the Mission

SaveJapan is more than a product. It's a movement to democratize cybersecurity in Japan.

**We're hiring:**
- Rust engineers (Tokyo or remote)
- Security researchers
- Japanese content writers
- DevRel / Community

**We're open-sourcing:**
- Security tools (Rust crates)
- Phishing datasets
- Educational content

**Try SaveJapan:**
- Free scan: chatnews.tech/scan
- Courses: dojoc.io
- Phishing training: enabler.cc

Let's protect Japan's 3.8 million businesses together. 🛡️🇯🇵

---

*Yuki Hamada is the founder of SaveJapan and former CPO at Mercari. He's also building Elio (offline AI), ChatWeb (voice-controlled automation), and JiuFlow (BJJ training AI). Follow him on Twitter @yukihamada.*

**Published on Medium:** March 11, 2026
**Reading time:** 12 minutes
**Tags:** #Cybersecurity #Rust #Japan #Startups #ProductHunt
