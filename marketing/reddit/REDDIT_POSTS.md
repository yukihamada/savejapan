# SaveJapan - Reddit Posts

## r/cybersecurity

### Post 1: "We built a free security scanner for Japanese SMBs – 10,000+ scans in 8 months"

**Title:** [Tool] Free security scanner for Japanese businesses (built in Rust)

**Body:**

Hi r/cybersecurity!

I'm a former Mercari CPO who left to build SaveJapan – a cybersecurity platform for Japan's 3.8M small businesses.

**The Problem:**
- 91% of cyberattacks in Japan start with phishing
- SMBs can't afford ¥500K+ security audits
- Ransomware attacks up 210% YoY
- Most security training is English-only

**What we built:**

🔍 **Free Security Scanner** (chatnews.tech/scan)
- A-F security scoring
- 50+ checks (HTTPS, SSL, headers, DNS)
- 2-second results
- No signup required

🎓 **Cybersecurity Courses** (dojoc.io)
- Japanese-native content
- 3 levels (Beginner → Advanced)
- Digital certificates
- 1,200+ students

🎣 **Phishing Simulation** (enabler.cc)
- 50+ Japanese email templates
- Real business scenarios
- 75% click rate reduction (avg 3 months)
- 156 companies deployed

**Tech Stack:**
- Backend: Rust + Axum (99.9% uptime, <2s scans)
- Frontend: Next.js + React
- DB: Supabase (PostgreSQL + RLS)
- Deploy: Fly.io Tokyo

**Why Rust?**
Security tools can't have vulnerabilities. Rust's memory safety = zero crashes in 8 months.

**Performance:**
- Before (Python): 8-12s/scan, 512MB idle
- After (Rust): 1.5-2s/scan, 28MB idle (5x faster, 18x less memory)

**Open Source:**
We've released:
- `rust-security-headers` (2.4K downloads on crates.io)
- `jp-phishing-corpus` (500+ samples, 340 GitHub stars)

**Impact:**
One 50-person manufacturer:
- Before: F score (28/100), 68% phishing click rate
- After 3 months: A- score (92/100), 17% click rate
- Prevented 2 ransomware attempts

Try the free scanner: chatnews.tech/scan

**Questions for the community:**
1. What security checks would you add to our scanner?
2. Are you building tools for non-English markets? What challenges?
3. Rust vs. Go for security tooling?

Happy to answer any questions about the tech stack, security testing, or Japanese market!

---

### Post 2: "Rust vs. Python for security tooling – 5x faster, 18x less memory"

**Title:** [Technical] Why we rewrote our security scanner from Python to Rust

**Body:**

We operate SaveJapan, a security platform with 10,000+ scans. Here's why we migrated from Python to Rust:

**Original Stack (Python + Django + Celery):**
```python
# Scan function
def scan_url(url):
    results = {
        'https': check_https(url),
        'ssl': check_ssl(url),
        'headers': check_headers(url),
        # ... 47 more checks
    }
    score = calculate_score(results)
    return score
```

**Problems:**
- 8-12 seconds per scan (too slow)
- 512MB memory idle (expensive at scale)
- Celery worker crashes under load
- Memory leaks in long-running processes

**Rust Rewrite (Axum + Tokio + SQLx):**
```rust
pub async fn scan_url(url: &str) -> Result<ScanResult> {
    let https = check_https(url).await?;
    let ssl = check_ssl(url).await?;
    let headers = check_headers(url).await?;
    // ... 47 more checks (all async)

    let score = calculate_score(&ScanData {
        https, ssl, headers, ...
    });

    Ok(ScanResult { score, ... })
}
```

**Results:**
| Metric | Python | Rust | Improvement |
|--------|--------|------|-------------|
| Scan time | 8-12s | 1.5-2s | **5x faster** |
| Memory (idle) | 512MB | 28MB | **18x less** |
| Concurrent users | ~100 | 10,000+ | **100x scale** |
| Crashes (8 months) | 47 | 0 | **∞ better** |

**Why Rust Won:**

1. **Async is first-class**
   - Tokio runtime handles 10K+ connections
   - No GIL (Python's Global Interpreter Lock)
   - Truly parallel execution

2. **Memory safety without GC**
   - No garbage collection pauses
   - Predictable latency (<5ms p99)
   - Zero memory leaks

3. **Type safety caught bugs**
   - 100+ compile-time errors prevented
   - Impossible to pass None to SSL checker
   - Refactoring is fearless

**Migration Strategy:**

Week 1-2: CLI tool in Rust
```bash
$ cargo run -- scan https://example.com
```

Week 3-4: API with Axum
```rust
#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/scan/:url", get(scan_handler));

    axum::Server::bind(&"0.0.0.0:8080")
        .serve(app.into_make_service())
        .await.unwrap();
}
```

Week 5-6: DB integration with SQLx
```rust
let result = sqlx::query!(
    "INSERT INTO scans (url, score) VALUES ($1, $2)",
    url, score
).execute(&pool).await?;
```

Week 7-8: Production deployment
- Blue-green deployment on Fly.io
- Gradual traffic shift (10% → 50% → 100%)
- Zero downtime migration

**Challenges:**

1. **Compile times**
   - Full rebuild: 4-6 minutes on M1 Max
   - Solution: `split-debuginfo`, incremental builds
   - Now: 15-30s incremental rebuilds

2. **Async complexity**
   - Learning curve for team (Python background)
   - Solution: Tokio workshop, pair programming
   - Result: Team now prefers async Rust

3. **Dependency ecosystem**
   - Some libraries missing (vs. Python's PyPI)
   - Solution: Built our own (`rust-security-headers`)
   - Bonus: Now 2.4K downloads on crates.io

**Would We Do It Again?**

Absolutely. The performance gains alone paid for the 2-month rewrite.

But more importantly:
- **Reliability:** 99.9% uptime (vs. 97% with Python)
- **Cost:** $80/month Fly.io (vs. $400/month AWS)
- **Confidence:** Type safety = fearless deploys

**When NOT to use Rust:**

- Prototypes / MVP (use Python/Go)
- Heavy data science (Python ecosystem unmatched)
- Small traffic (<1000 req/day)

**When to use Rust:**

- High-performance requirements
- Long-running services
- Security-critical applications
- Memory-constrained environments

Try our scanner (built in Rust): chatnews.tech/scan

**Questions?** Happy to discuss:
- Axum vs. Actix-web
- SQLx vs. Diesel
- Testing strategies
- Deployment patterns

---

## r/japan

### Post 3: "Building cybersecurity tools for Japanese SMBs – lessons learned"

**Title:** Japanese SMBs are under attack. We built tools to help (and learned a lot about Japanese business culture)

**Body:**

Hi r/japan!

I left Mercari to build SaveJapan, cybersecurity tools for Japan's 3.8M small businesses. Here's what I learned about building products for Japanese companies:

**The Problem:**

Phishing attacks in Japan increased 340% last year. But:
- SMBs can't afford ¥500K security audits
- Western security tools don't understand Japanese business culture
- Training materials are English-only

**What we built:**

1. Free security scanner: chatnews.tech/scan
2. Japanese cybersecurity courses: dojoc.io
3. Phishing training: enabler.cc

**Cultural Challenges:**

### 1. Phishing emails in Japanese are DIFFERENT

English phishing:
```
URGENT: Your account has been compromised!
Click here immediately: http://evil.com
```

Japanese phishing:
```
いつもお世話になっております。

経理部の田中と申します。
先月分の経費精算に関しまして、
添付ファイルをご確認いただけますでしょうか。

お手数をおかけしますが、
よろしくお願いいたします。
```

Key differences:
- **Keigo (敬語) throughout** – sounds professional
- **No urgency** – cultural difference
- **Realistic context** – expense reports, not "prince of Nigeria"
- **Proper formatting** – business email structure

Our phishing templates are written by native speakers who understand Japanese business culture.

### 2. UI Density Preference

We A/B tested our scanner results:

**Version A (Western style):**
- Big A-F score
- 3 bullet points
- Lots of whitespace

**Version B (Japanese style):**
- A-F score + numeric (87/100)
- 12 detailed findings
- Industry comparison
- Dense information

**Result:** Version B had 3x higher engagement.

Lesson: Japanese users prefer information density over minimalism.

### 3. Privacy & Compliance (APPI)

Japan's APPI (個人情報保護法) is different from GDPR:
- Data can stay in Japan (we use Fly.io Tokyo)
- Consent requirements are less strict
- Fines are lower but reputation damage is huge

We architected for APPI compliance from day 1:
- No cross-border data transfer
- Japanese privacy policy
- Transparent data retention

### 4. Pricing Strategy

Western SaaS: Start high, discount later
Japanese market: Start reasonable, build trust

Our pricing:
- Free tier (always)
- Starter: ¥9,800/month (not ¥9,999)
- Business: ¥29,800/month
- No hidden fees

Transparency matters more than "growth hacking."

### 5. Sales Process

Western: "Try free trial → Buy immediately"
Japanese: "Try → Request meeting → Ringi → Decision (3-6 months)"

We adapted:
- Longer trial periods (30 days vs. 14)
- More case studies in Japanese
- Reference checks expected
- Patience with ringi process

**Real Impact:**

One 50-person manufacturer in Osaka:
- Before: 68% phishing click rate
- After 3 months: 17% click rate (75% reduction)
- Prevented 2 ransomware attacks

**Tech Stack (for the curious):**
- Rust + Axum (99.9% uptime)
- 100% in Tokyo datacenter
- APPI compliant
- Open source components

**Questions for r/japan:**
1. Do you work at an SMB? What security concerns do you have?
2. Have you seen phishing attempts increase?
3. What other Japanese business culture aspects should we consider?

Happy to answer questions about building for Japanese market, cybersecurity, or startup life in Japan!

---

## r/startups

### Post 4: "From Mercari CPO to solo founder – building SaveJapan"

**Title:** I left my CPO role to build a cybersecurity startup. Here's what I learned in 8 months.

**Body:**

**Background:**
- 4 years as CPO at Mercari (Japan's #1 marketplace)
- Left in March 2025 to build SaveJapan
- Now: 156 customers, 1,200+ users, profitable

**What is SaveJapan?**

3-in-1 cybersecurity platform for Japanese SMBs:
1. Free security scanner (10K+ scans)
2. Cybersecurity courses (Japanese-native)
3. Phishing training (75% click rate reduction)

**Why I left a cushy job:**

One portfolio startup got a ¥7.2M ($64.5K) AWS bill from a leaked API key. They had no one to teach them basic security hygiene.

Japan has 3.8M SMBs. Most have:
- No security team
- No budget for audits (¥500K+)
- English-only training materials

I saw a gap and jumped.

**8-Month Journey:**

### Month 1-2: MVP
- Built CLI scanner in Rust
- Validated with 50 companies
- Learning: Start with one vertical (manufacturing)

### Month 3-4: Product Launch
- Launched on Product Hunt (Top 10)
- 1,000+ free scans
- 50 paid signups
- Learning: Japanese market needs trust first, sales second

### Month 5-6: Scaling
- Hired 2 engineers
- Built phishing simulator
- Revenue: ¥1.2M/month
- Learning: Say no to features, focus on core value

### Month 7-8: Profitability
- 156 customers
- ¥2.8M/month revenue
- 40% profit margin
- Learning: Rust's efficiency = lower costs

**Key Lessons:**

### 1. Technical Choices Matter
Chose Rust over Python:
- 5x faster performance
- 18x less memory
- 99.9% uptime (vs. 97% with Python)
- Lower infrastructure costs ($80 vs. $400/month)

### 2. Japanese Market is Different
- Longer sales cycles (3-6 months)
- Trust > features
- Ringi (稟議) process expected
- Reference checks are mandatory

### 3. Pricing Strategy
Started at ¥19,800/month → too high
Dropped to ¥9,800/month → sweet spot

Japanese SMBs want:
- Transparent pricing
- No hidden fees
- Reasonable starting price
- Trust before growth hacking

### 4. Open Source Builds Trust
Released 2 libraries:
- `rust-security-headers` (2.4K downloads)
- `jp-phishing-corpus` (340 GitHub stars)

Result: Developer credibility → enterprise leads

### 5. Solo Founder Challenges
**Hard:**
- Sales + eng + support + marketing
- Decision fatigue
- Loneliness

**Solutions:**
- Joined YC founder group
- Monthly accountability calls
- Clear work hours (no burnout)

**Profitability Timeline:**

| Month | MRR | Customers | Notes |
|-------|-----|-----------|-------|
| 1 | ¥0 | 0 | MVP building |
| 2 | ¥98K | 10 | First sales |
| 3 | ¥587K | 60 | PH launch |
| 4 | ¥1.2M | 122 | Word of mouth |
| 5 | ¥1.9M | 156 | Phishing module |
| 6 | ¥2.8M | 156 | Upsells |

**What's Next:**

- AI threat detection (training on our corpus)
- Browser extension (Rust → WASM)
- Expansion to SE Asia

**Ask Me Anything:**
- Leaving a job to start
- Building in Rust
- Japanese market entry
- Cybersecurity as a service
- Solo founder life

Try it: chatnews.tech/scan (free, no signup)

---

## r/rust

### Post 5: "Built a security scanner in Rust – 5x faster than Python, 28MB memory"

**Title:** [Production] Security scanner: Python → Rust migration (5x faster, 18x less memory)

**Body:**

We run SaveJapan, a security scanner with 10K+ scans. Here's our Python → Rust migration story.

**Problem:**
Python scanner was too slow (8-12s), memory-hungry (512MB idle), crashed under load.

**Solution:**
Rewrote in Rust + Axum. Now: 1.5-2s scans, 28MB idle, 99.9% uptime.

**Architecture:**

```rust
// Main scanner
pub async fn scan_url(url: &str) -> Result<ScanResult> {
    // Parallel checks with join!
    let (https, ssl, headers, dns, whois) = tokio::join!(
        check_https(url),
        check_ssl(url),
        check_headers(url),
        check_dns(url),
        check_whois(url),
    );

    // Calculate score
    let score = calculate_score(ScanData {
        https: https?,
        ssl: ssl?,
        headers: headers?,
        dns: dns?,
        whois: whois?,
    });

    Ok(ScanResult { url, score, ... })
}

// HTTP server
#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/scan/:url", get(scan_handler))
        .layer(TraceLayer::new_for_http());

    let listener = TcpListener::bind("0.0.0.0:8080").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```

**Performance Wins:**

| Metric | Python | Rust | Gain |
|--------|--------|------|------|
| Scan time | 8-12s | 1.5-2s | **5x** |
| Memory | 512MB | 28MB | **18x** |
| Throughput | 100 req/s | 10K req/s | **100x** |
| P99 latency | 2.8s | 4.2ms | **666x** |

**Stack:**

```toml
[dependencies]
axum = "0.7"
tokio = { version = "1", features = ["full"] }
sqlx = { version = "0.7", features = ["postgres", "runtime-tokio"] }
tower = "0.4"
tower-http = { version = "0.5", features = ["trace"] }
serde = { version = "1", features = ["derive"] }
reqwest = { version = "0.11", features = ["rustls-tls"] }
```

**Why Axum?**

Tried Actix-web first, but switched to Axum:
- Better extractors (Path, Query, Json)
- Tower ecosystem (middleware)
- Type-safe routing
- Active development

**Challenges:**

1. **Compile times**
   - Full: 4-6 min
   - Incremental: 15-30s
   - Solution: `split-debuginfo = "unpacked"`

2. **Async complexity**
   - Team from Python background
   - Solution: Tokio workshop
   - Result: Team prefers async Rust now

3. **Error handling**
   - Python: try/except everywhere
   - Rust: Result<T, E> propagation
   - Solution: Custom error types with thiserror

**Production Metrics (8 months):**
- Uptime: 99.94%
- Crashes: 0
- Memory leaks: 0
- Cost: $80/month (Fly.io Tokyo, 4x 256MB)

**Open Source:**

Released `rust-security-headers`:
```rust
use rust_security_headers::SecurityHeaders;

let headers = SecurityHeaders::from_response(&response);
println!("CSP: {}", headers.csp.is_some());
println!("HSTS: {}", headers.hsts.is_some());
println!("Score: {}/100", headers.calculate_score());
```

GitHub: github.com/savejapan/rust-security-headers
Crates.io: 2,400+ downloads

**Would we do it again?**

100% yes. The rewrite paid for itself in 1 month (lower AWS costs).

Try it: chatnews.tech/scan

**Questions?**
- Axum patterns
- SQLx vs. Diesel
- Testing strategies
- Deployment (Fly.io)
- Async best practices

---

## r/entrepreneur

### Post 6: "¥2.8M MRR in 6 months with a cybersecurity SaaS (Japanese market)"

**Title:** Bootstrapped cybersecurity SaaS to ¥2.8M MRR ($25K) in 6 months. Here's the playbook.

**Body:**

**Quick stats:**
- **MRR:** ¥2.8M ($25K USD)
- **Customers:** 156 (SMBs in Japan)
- **Growth:** 100% MoM (first 3 months)
- **Team:** 3 (founder + 2 engineers)
- **Funding:** $0 (bootstrapped)

**What we built:**

SaveJapan – 3-in-1 cybersecurity platform:
1. Free security scanner
2. Cybersecurity courses
3. Phishing training simulator

**The Opportunity:**

Japan has 3.8M SMBs. Most have:
- No security team
- No budget (¥500K+ for audits)
- Increasing attacks (+340% phishing YoY)

Western tools don't work:
- English-only
- Wrong cultural context
- Enterprise pricing

**Our approach:**

### Month 1-2: Validate
- Built free scanner MVP
- 50 companies tested
- Feedback: "Finally, something we understand!"

### Month 3: Launch
- Product Hunt (Top 10)
- 1,000+ scans
- 50 paid signups (¥9,800/month)

### Month 4-6: Scale
- Added phishing simulator
- Upsold existing customers
- Word-of-mouth growth

**Revenue Breakdown:**

| Plan | Price | Customers | MRR |
|------|-------|-----------|-----|
| Free | ¥0 | ~1,000 | ¥0 |
| Starter | ¥9,800 | 106 | ¥1.04M |
| Business | ¥29,800 | 50 | ¥1.49M |
| Enterprise | ¥98,000 | 3 | ¥294K |
| **Total** | - | **159** | **¥2.83M** |

**Key Strategies:**

### 1. Freemium → Land and Expand
- Free scanner drives awareness
- 5% convert to Starter
- 20% upgrade to Business within 3 months

### 2. Japanese Market Playbook
- Long sales cycle (3-6 months) → longer trials
- Trust > features → case studies + references
- Ringi process → patience required

### 3. Technical Efficiency = Profitability
Built in Rust (not Python):
- 5x faster
- 18x less memory
- Lower costs: $80/month vs. $400/month
- **40% profit margin**

### 4. Open Source for Credibility
Released 2 libraries:
- `rust-security-headers` (2.4K downloads)
- `jp-phishing-corpus` (340 stars)

Result: Developer credibility → enterprise leads

### 5. Content Marketing
- 5 blog posts (Japanese)
- 1 case study per month
- Product Hunt launch
- Reddit (here!)

**Cost Structure:**

| Category | Monthly | % |
|----------|---------|---|
| Infrastructure (Fly.io) | $80 | 3% |
| Supabase | $25 | 1% |
| Tools (Stripe, Sentry) | $150 | 5% |
| Salaries (2 engineers) | ¥800K | 28% |
| **Total** | **¥1.12M** | **40%** |
| **Profit** | **¥1.71M** | **60%** |

**Challenges:**

1. **Sales cycle** – 3-6 months (patience required)
2. **Localization** – Not just translation, cultural adaptation
3. **Solo founder** – Lonely, decision fatigue
4. **Support** – Japanese customers expect high touch

**What worked:**

1. **Start with one vertical** (manufacturing → others)
2. **Free tier** (drives awareness)
3. **Case studies** (trust in Japanese market)
4. **Technical efficiency** (Rust → profitability)
5. **Transparent pricing** (no sales calls required for Starter/Business)

**Next 6 months:**

- AI threat detection
- SE Asia expansion (starting with Singapore)
- Partner channel (resellers)
- Target: ¥10M MRR

**Ask me anything:**
- Bootstrapping SaaS
- Japanese market entry
- Pricing strategy
- Technical choices (Rust)
- Solo founder challenges

Try it: chatnews.tech/scan (free)

---

**Summary:**

- 6 posts across 6 subreddits
- Each tailored to community interests
- Technical depth for r/rust, r/cybersecurity
- Market insights for r/japan
- Founder story for r/startups, r/entrepreneur
- All include CTA: chatnews.tech/scan
