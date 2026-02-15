# News.xyz AI Data Pipeline & Distribution System - Implementation Plan

> Version 1.0 | 2026-02-15

## Executive Summary

news.xyzは現在100+のRSSソースから記事を集約する、ターミナル風デザインのニュースアグリゲーターです。本プランでは、AIを活用したデータクリーニング機能と包括的な配信システムを追加し、次世代のニュース配信プラットフォームへと進化させます。

### 現在の実装状況

**技術スタック:**
- Backend: Rust (Axum, tokio)
- Database: SQLite (articles, feeds, categories, subscriptions)
- Deployment: Fly.io (nrt region)
- Feeds: 12,384行のTOML設定 (100+ソース)
- 既存機能: 記事重複排除 (UUID v5), タイトル類似度グルーピング (trigram + Jaccard), Claude API統合

**既存の重複排除:**
```rust
// dedup.rs: URL正規化 + UUID v5
article_id_from_url("https://example.com/article/1?utm_source=twitter#section")
// → 同一URLとして識別

// grouping.rs: 文字3-gramベースのJaccard類似度
similarity("東京都で新型コロナ100人確認", "東京都で新型コロナ150人確認")
// → 0.5+ (関連記事としてグルーピング)
```

---

## 1. Architecture Overview

### 1.1 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        INGESTION LAYER                          │
│  RSS/Atom Feeds (100+) → Fetcher → Dedup (UUID v5 + URL norm)  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      AI CLEANING PIPELINE                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Summarizer   │  │ Categorizer  │  │ Credibility  │          │
│  │ (Claude 4.5) │  │ (Batch LLM)  │  │ Scorer       │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Duplicate    │  │ Keyword      │  │ Sentiment    │          │
│  │ Detector     │  │ Extractor    │  │ Analyzer     │          │
│  │ (Vector DB)  │  │ (NLP)        │  │ (Heuristic)  │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                       ENRICHED STORAGE                           │
│  SQLite (extended schema) + Vector Index (in-memory/on-disk)    │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     DISTRIBUTION LAYER                           │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐   │
│  │ RSS/Atom  │  │ JSON API  │  │ WebSocket │  │ Email     │   │
│  │ Generator │  │ (REST)    │  │ (SSE)     │  │ Newsletter│   │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘   │
│  ┌───────────┐                                                  │
│  │ Webhook   │                                                  │
│  │ Notifier  │                                                  │
│  └───────────┘                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Database Schema Extensions

```sql
-- 既存テーブル拡張
ALTER TABLE articles ADD COLUMN summary TEXT;                -- AI要約
ALTER TABLE articles ADD COLUMN keywords TEXT;               -- JSON array ["AI", "技術", "オープンソース"]
ALTER TABLE articles ADD COLUMN sentiment TEXT;              -- "positive" | "negative" | "neutral"
ALTER TABLE articles ADD COLUMN sentiment_score REAL;        -- -1.0 to 1.0
ALTER TABLE articles ADD COLUMN credibility_score REAL;      -- 0.0 to 1.0
ALTER TABLE articles ADD COLUMN fact_check_status TEXT;      -- "verified" | "disputed" | "unverified"
ALTER TABLE articles ADD COLUMN fact_check_notes TEXT;       -- ファクトチェック結果
ALTER TABLE articles ADD COLUMN embedding BLOB;              -- Vector embedding (768次元 float32)
ALTER TABLE articles ADD COLUMN ai_processed_at TEXT;        -- 処理タイムスタンプ

-- 新規テーブル: ベクトル検索用インデックス
CREATE TABLE IF NOT EXISTS article_vectors (
    article_id TEXT PRIMARY KEY,
    embedding BLOB NOT NULL,                                 -- 768 floats (3KB)
    norm REAL NOT NULL,                                      -- L2 norm for fast cosine similarity
    processed_at TEXT NOT NULL,
    FOREIGN KEY (article_id) REFERENCES articles(id) ON DELETE CASCADE
);
CREATE INDEX idx_vectors_processed ON article_vectors(processed_at);

-- 重複クラスタ管理
CREATE TABLE IF NOT EXISTS duplicate_clusters (
    cluster_id TEXT PRIMARY KEY,
    canonical_article_id TEXT NOT NULL,                      -- 代表記事
    member_article_ids TEXT NOT NULL,                        -- JSON array of article IDs
    similarity_threshold REAL NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (canonical_article_id) REFERENCES articles(id)
);

-- Webhook購読者
CREATE TABLE IF NOT EXISTS webhook_subscriptions (
    subscription_id TEXT PRIMARY KEY,
    callback_url TEXT NOT NULL,
    categories TEXT,                                         -- JSON array or NULL (all)
    keywords TEXT,                                           -- JSON array or NULL (all)
    min_credibility REAL,                                    -- Filter threshold
    secret_token TEXT NOT NULL,                              -- HMAC verification
    active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL,
    last_triggered_at TEXT
);

-- Email購読者
CREATE TABLE IF NOT EXISTS email_subscriptions (
    email TEXT PRIMARY KEY,
    categories TEXT,                                         -- JSON array
    frequency TEXT NOT NULL,                                 -- "realtime" | "daily" | "weekly"
    last_sent_at TEXT,
    verified INTEGER NOT NULL DEFAULT 0,
    verification_token TEXT,
    created_at TEXT NOT NULL
);
```

---

## 2. AI Data Cleaning Pipeline

### 2.1 記事要約生成 (Summarizer)

**目的:** 長文記事を1-3文に要約し、ユーザーの読書時間を削減

**実装方針:**
- **Primary Model:** Claude Sonnet 4.5 (既存統合あり、日本語・英語対応)
- **Fallback:** OpenAI GPT-4o-mini (コスト削減)
- **Local Fallback:** Qwen3-0.6B GGUF (オフライン/無料、nanobotで実績あり)

**処理フロー:**
1. 記事取得後、`description`フィールドが存在するか確認
2. 存在しない、または200文字未満の場合、AIで要約生成
3. キャッシュ: `ai_cache`テーブルで24時間保存
4. バッチ処理: 10件ずつまとめて要約 (Claude API効率化)

**コスト最適化:**
- フィードに`<description>`タグがある場合はスキップ
- キャッシュヒット率 > 80%を目標 (同一記事の再処理防止)
- 1日10,000記事想定 → 要約必要: 2,000件 → Claude API: $2-3/日

```rust
// crates/news-ai/src/summarizer.rs
pub async fn summarize_article(
    client: &reqwest::Client,
    api_key: &str,
    title: &str,
    content: &str,
) -> Result<String, String> {
    let prompt = format!(
        "以下のニュース記事を1-2文(100文字以内)で要約してください。\n\n\
        タイトル: {}\n\n\
        本文: {}",
        title,
        &content[..content.len().min(2000)] // 最初の2000文字のみ使用
    );

    let request = ClaudeRequest {
        model: "claude-sonnet-4-5-20250929".into(),
        max_tokens: 200,
        messages: vec![ClaudeMessage {
            role: "user".into(),
            content: prompt,
        }],
    };

    let response = client
        .post("https://api.anthropic.com/v1/messages")
        .header("x-api-key", api_key)
        .header("anthropic-version", "2023-06-01")
        .json(&request)
        .send()
        .await
        .map_err(|e| format!("API request failed: {}", e))?;

    let body: ClaudeResponse = response
        .json()
        .await
        .map_err(|e| format!("JSON parse failed: {}", e))?;

    body.content
        .first()
        .and_then(|block| block.text.clone())
        .ok_or_else(|| "No summary generated".to_string())
}
```

### 2.2 重複排除 (Advanced Duplicate Detection)

**既存実装の課題:**
- URL正規化のみでは、異なるURLで同一内容を検出不可
- タイトル類似度では「東京でコロナ100人」vs「東京都で新型コロナ150人確認」が同一ニュースと判定される可能性

**改善策: セマンティック重複検出**
- ベクトル埋め込み (Sentence Transformers) でコンテンツ全体を比較
- コサイン類似度 > 0.85 → 重複と判定
- 既存のtrigram手法と併用 (高速フィルタリング)

**モデル選択:**
- **intfloat/multilingual-e5-large** (768次元, 日英対応, 1.1GB)
- **sentence-transformers/paraphrase-multilingual-mpnet-base-v2** (768次元, 日英対応, 1.1GB)
- **OpenAI text-embedding-3-small** (API, 1536次元, $0.02/1M tokens)

**推奨:** Local model (intfloat/e5-large) をFly.io GPUインスタンスで実行、またはバッチ処理

```rust
// crates/news-ai/src/embeddings.rs
use candle_core::{Device, Tensor};
use candle_nn::VarBuilder;
use hf_hub::{api::tokio::Api, Repo, RepoType};
use tokenizers::Tokenizer;

pub struct EmbeddingModel {
    model: BertModel,
    tokenizer: Tokenizer,
    device: Device,
}

impl EmbeddingModel {
    pub async fn load() -> Result<Self, String> {
        let api = Api::new().map_err(|e| e.to_string())?;
        let repo = api.repo(Repo::new(
            "intfloat/multilingual-e5-large".to_string(),
            RepoType::Model,
        ));

        let model_file = repo
            .get("model.safetensors")
            .await
            .map_err(|e| e.to_string())?;
        let tokenizer_file = repo
            .get("tokenizer.json")
            .await
            .map_err(|e| e.to_string())?;

        let device = Device::cuda_if_available(0).map_err(|e| e.to_string())?;
        let vb = unsafe {
            VarBuilder::from_mmaped_safetensors(&[model_file], DType::F32, &device)
                .map_err(|e| e.to_string())?
        };

        let model = BertModel::load(vb, &BertConfig::default())
            .map_err(|e| e.to_string())?;
        let tokenizer = Tokenizer::from_file(tokenizer_file)
            .map_err(|e| e.to_string())?;

        Ok(Self {
            model,
            tokenizer,
            device,
        })
    }

    pub fn encode(&self, text: &str) -> Result<Vec<f32>, String> {
        let tokens = self
            .tokenizer
            .encode(text, true)
            .map_err(|e| e.to_string())?;
        let token_ids = Tensor::new(tokens.get_ids(), &self.device)
            .map_err(|e| e.to_string())?
            .unsqueeze(0)
            .map_err(|e| e.to_string())?;

        let embeddings = self
            .model
            .forward(&token_ids)
            .map_err(|e| e.to_string())?;

        // Mean pooling
        let pooled = embeddings
            .mean(1)
            .map_err(|e| e.to_string())?
            .squeeze(0)
            .map_err(|e| e.to_string())?;

        pooled.to_vec1::<f32>().map_err(|e| e.to_string())
    }
}

pub fn cosine_similarity(a: &[f32], b: &[f32]) -> f32 {
    let dot: f32 = a.iter().zip(b).map(|(x, y)| x * y).sum();
    let norm_a: f32 = a.iter().map(|x| x * x).sum::<f32>().sqrt();
    let norm_b: f32 = b.iter().map(|x| x * x).sum::<f32>().sqrt();
    dot / (norm_a * norm_b)
}
```

**処理フロー:**
1. 新規記事のタイトル+要約を結合してベクトル化
2. 過去24時間の記事ベクトルと比較 (SQLite `article_vectors`テーブル)
3. コサイン類似度 > 0.85 → 重複クラスタに追加
4. 代表記事 (canonical) を選定: 最も信頼性スコアが高い記事

### 2.3 カテゴリ自動分類 (Category Classifier)

**現状:** feeds.tomlで手動設定、誤分類あり (例: 「AIニュース」が"Business"カテゴリ)

**改善策:**
- タイトル+要約をLLMで分類
- 既存カテゴリ: general, tech, business, entertainment, sports, science, podcast
- バッチ処理: 100記事をまとめて分類 (Claude batch API or ローカルモデル)

**モデル選択:**
- **Primary:** Claude Haiku 4.0 (高速・低コスト, $0.25/MTok input)
- **Local:** Qwen2.5-7B-Instruct GGUF (分類タスクで高精度)

```rust
pub async fn classify_category(
    client: &reqwest::Client,
    api_key: &str,
    title: &str,
    summary: &str,
) -> Result<Category, String> {
    let prompt = format!(
        "以下のニュース記事のカテゴリを判定してください。\n\n\
        カテゴリ一覧: general, tech, business, entertainment, sports, science, podcast\n\n\
        タイトル: {}\n\
        要約: {}\n\n\
        回答は1単語のみ出力してください (例: tech)",
        title, summary
    );

    let request = ClaudeRequest {
        model: "claude-haiku-4-0".into(),
        max_tokens: 10,
        messages: vec![ClaudeMessage {
            role: "user".into(),
            content: prompt,
        }],
    };

    let response = client
        .post("https://api.anthropic.com/v1/messages")
        .header("x-api-key", api_key)
        .header("anthropic-version", "2023-06-01")
        .json(&request)
        .send()
        .await
        .map_err(|e| format!("API request: {}", e))?;

    let body: ClaudeResponse = response.json().await.map_err(|e| e.to_string())?;
    let category_str = body
        .content
        .first()
        .and_then(|b| b.text.as_ref())
        .ok_or("No response")?
        .trim()
        .to_lowercase();

    Category::from_str(&category_str).ok_or_else(|| format!("Invalid category: {}", category_str))
}
```

### 2.4 信頼性スコア付与 (Credibility Scorer)

**目的:** 信頼できるニュースソースを優先表示

**スコアリング要素:**
1. **ソース評価** (0.0-1.0)
   - 著名メディア: 1.0 (NHK, BBC, Reuters)
   - 確立されたメディア: 0.8 (ITmedia, TechCrunch)
   - 個人ブログ/不明ソース: 0.5
2. **URL品質** (0.0-1.0)
   - HTTPS: +0.2
   - 公式ドメイン (.go.jp, .edu): +0.3
   - 短縮URL/不審ドメイン: -0.3
3. **コンテンツ品質** (0.0-1.0)
   - 文字数 > 500: +0.2
   - 画像あり: +0.1
   - 引用/出典あり: +0.2
4. **時間的新鮮さ** (0.0-1.0)
   - 24時間以内: 1.0
   - 1週間以内: 0.8
   - 1ヶ月以上: 0.5

```rust
pub fn calculate_credibility_score(article: &Article, source_rating: f32) -> f32 {
    let mut score = source_rating * 0.4; // 40% weight

    // URL quality (20%)
    if article.url.starts_with("https://") {
        score += 0.1;
    }
    if article.url.contains(".go.jp") || article.url.contains(".edu") {
        score += 0.1;
    }

    // Content quality (20%)
    if let Some(desc) = &article.description {
        if desc.len() > 500 {
            score += 0.1;
        }
    }
    if article.image_url.is_some() {
        score += 0.05;
    }
    if article.description.as_ref().map_or(false, |d| d.contains("出典") || d.contains("引用")) {
        score += 0.05;
    }

    // Freshness (20%)
    let age_hours = (Utc::now() - article.published_at).num_hours();
    let freshness = if age_hours < 24 {
        1.0
    } else if age_hours < 168 {
        0.8
    } else {
        0.5
    };
    score += freshness * 0.2;

    score.min(1.0)
}

// ソース評価マップ (設定ファイルで管理)
pub fn get_source_rating(source: &str) -> f32 {
    match source {
        "NHK" | "BBC" | "Reuters" | "AP" => 1.0,
        "ITmedia" | "TechCrunch" | "Ars Technica" => 0.8,
        "Hacker News" | "Reddit" => 0.6,
        _ => 0.5,
    }
}
```

### 2.5 ファクトチェック (Fact Checker)

**Phase 1 実装 (シンプル版):**
- 外部ファクトチェックAPIとの連携は将来実装
- 現時点では「信頼性スコア」で代替
- 低信頼性記事に警告バッジ表示

**Phase 2 実装 (将来):**
- Google Fact Check Tools API統合
- ClaimBuster API (米国政治特化)
- 独自ファクトチェックDB構築

### 2.6 キーワード抽出 (Keyword Extractor)

**手法:**
1. **TF-IDF** (軽量、ローカル実行可能)
2. **YAKE** (Yet Another Keyword Extractor, 教師なし学習)
3. **LLM抽出** (Claude/GPT-4o-mini)

**推奨:** TF-IDF + 固有名詞抽出 (日本語: MeCab, 英語: spaCy)

```rust
use std::collections::HashMap;

pub fn extract_keywords_tfidf(
    title: &str,
    summary: &str,
    corpus_idf: &HashMap<String, f32>,
) -> Vec<String> {
    let text = format!("{} {}", title, summary);
    let words: Vec<String> = text
        .split_whitespace()
        .map(|w| w.to_lowercase())
        .filter(|w| w.len() > 2 && !is_stopword(w))
        .collect();

    let mut tf: HashMap<String, f32> = HashMap::new();
    for word in &words {
        *tf.entry(word.clone()).or_insert(0.0) += 1.0;
    }

    let total = words.len() as f32;
    for count in tf.values_mut() {
        *count /= total;
    }

    let mut tfidf: Vec<(String, f32)> = tf
        .into_iter()
        .map(|(word, tf_score)| {
            let idf = corpus_idf.get(&word).copied().unwrap_or(1.0);
            (word, tf_score * idf)
        })
        .collect();

    tfidf.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap());
    tfidf.into_iter().take(5).map(|(w, _)| w).collect()
}

fn is_stopword(word: &str) -> bool {
    matches!(
        word,
        "the" | "a" | "an" | "and" | "or" | "but" | "in" | "on" | "at" | "to" | "for" | "of" | "with"
    )
}
```

### 2.7 感情分析 (Sentiment Analyzer)

**手法:**
1. **ルールベース** (ポジティブ/ネガティブ単語リスト)
2. **ML Model** (BERT-based sentiment classifier)
3. **LLM分析** (Claude/GPT)

**推奨:** ルールベース (初期実装) → ML移行 (Phase 2)

```rust
pub fn analyze_sentiment(text: &str) -> (String, f32) {
    let positive_words = vec!["成功", "達成", "革新", "向上", "success", "achieve", "innovation"];
    let negative_words = vec!["失敗", "危機", "問題", "悪化", "failure", "crisis", "problem"];

    let text_lower = text.to_lowercase();
    let pos_count = positive_words.iter().filter(|w| text_lower.contains(*w)).count();
    let neg_count = negative_words.iter().filter(|w| text_lower.contains(*w)).count();

    let score = (pos_count as f32 - neg_count as f32) / (pos_count + neg_count).max(1) as f32;

    let sentiment = if score > 0.3 {
        "positive"
    } else if score < -0.3 {
        "negative"
    } else {
        "neutral"
    };

    (sentiment.to_string(), score)
}
```

---

## 3. Distribution System Architecture

### 3.1 RSS/Atom Feed Generation

**エンドポイント:**
- `GET /api/feed?format=rss` (RSS 2.0)
- `GET /api/feed?format=atom` (Atom 1.0)
- `GET /api/feed/{category}?format=rss` (カテゴリ別)
- `GET /api/feed/curated?min_credibility=0.8` (信頼性フィルタ)

**実装:**
```rust
use chrono::{DateTime, Utc};

pub fn generate_rss_feed(
    articles: &[Article],
    base_url: &str,
    category: Option<&Category>,
) -> String {
    let title = match category {
        Some(cat) => format!("News.xyz - {}", cat.as_str()),
        None => "News.xyz - All News".to_string(),
    };

    let items: Vec<String> = articles
        .iter()
        .map(|a| {
            format!(
                r#"    <item>
      <title><![CDATA[{}]]></title>
      <link>{}</link>
      <guid isPermaLink="true">{}</guid>
      <pubDate>{}</pubDate>
      <description><![CDATA[{}]]></description>
      <category>{}</category>
      <source url="{}">{}</source>
      {}
    </item>"#,
                a.title,
                a.url,
                a.url,
                a.published_at.to_rfc2822(),
                a.summary.as_ref().or(a.description.as_ref()).unwrap_or(&"".to_string()),
                a.category.as_str(),
                a.url,
                a.source,
                a.image_url
                    .as_ref()
                    .map(|img| format!("<enclosure url=\"{}\" type=\"image/jpeg\" />", img))
                    .unwrap_or_default()
            )
        })
        .collect();

    format!(
        r#"<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>{}</title>
    <link>{}</link>
    <description>Clean, ad-free news aggregation</description>
    <language>ja</language>
    <lastBuildDate>{}</lastBuildDate>
    <atom:link href="{}/api/feed" rel="self" type="application/rss+xml" />
{}
  </channel>
</rss>"#,
        title,
        base_url,
        Utc::now().to_rfc2822(),
        base_url,
        items.join("\n")
    )
}

// Route handler
pub async fn handle_feed(
    Query(params): Query<FeedParams>,
    State(state): State<Arc<AppState>>,
) -> impl IntoResponse {
    let category = params.category.as_deref().and_then(Category::from_str);
    let min_credibility = params.min_credibility.unwrap_or(0.0);

    let articles = state
        .db
        .query_articles_with_filter(category.as_ref(), 50, None, min_credibility)
        .unwrap_or_default();

    let feed_content = match params.format.as_deref() {
        Some("atom") => generate_atom_feed(&articles.0, &state.base_url, category.as_ref()),
        _ => generate_rss_feed(&articles.0, &state.base_url, category.as_ref()),
    };

    (
        StatusCode::OK,
        [(header::CONTENT_TYPE, "application/xml; charset=utf-8")],
        feed_content,
    )
}
```

### 3.2 JSON API (RESTful)

**エンドポイント設計:**

```
GET /api/v1/news
  Query Parameters:
    - category: string (tech, business, etc.)
    - limit: int (default: 20, max: 100)
    - cursor: string (pagination)
    - min_credibility: float (0.0-1.0)
    - keywords: string[] (comma-separated)
    - sentiment: positive|negative|neutral
    - from_date: ISO8601
    - to_date: ISO8601

  Response:
    {
      "articles": [
        {
          "id": "uuid",
          "title": "...",
          "url": "...",
          "summary": "...",
          "source": "...",
          "category": "tech",
          "published_at": "2026-02-15T10:00:00Z",
          "credibility_score": 0.85,
          "sentiment": "neutral",
          "keywords": ["AI", "OpenAI"],
          "image_url": "...",
          "group_id": "uuid",  // 関連記事グループ
          "duplicate_count": 5
        }
      ],
      "next_cursor": "...",
      "total_count": 1234
    }

GET /api/v1/news/:id
  Response:
    {
      "article": { ... },
      "related_articles": [ ... ],  // 類似記事
      "duplicates": [ ... ]          // 重複記事
    }

GET /api/v1/news/:id/summary
  Response:
    {
      "summary": "...",
      "generated_at": "2026-02-15T10:00:00Z",
      "model": "claude-sonnet-4-5"
    }

POST /api/v1/subscribe
  Request:
    {
      "callback_url": "https://example.com/webhook",
      "categories": ["tech", "science"],
      "keywords": ["AI"],
      "min_credibility": 0.7,
      "secret_token": "your-secret"
    }
  Response:
    {
      "subscription_id": "uuid",
      "status": "active"
    }

DELETE /api/v1/subscribe/:id
  Response: 204 No Content
```

**実装例:**
```rust
#[derive(Deserialize)]
pub struct NewsQuery {
    category: Option<String>,
    limit: Option<i64>,
    cursor: Option<String>,
    min_credibility: Option<f32>,
    keywords: Option<String>,
    sentiment: Option<String>,
    from_date: Option<String>,
    to_date: Option<String>,
}

pub async fn handle_get_news(
    Query(params): Query<NewsQuery>,
    State(state): State<Arc<AppState>>,
) -> Result<Json<NewsResponse>, StatusCode> {
    let category = params
        .category
        .as_deref()
        .and_then(Category::from_str);

    let limit = params.limit.unwrap_or(20).min(100);
    let min_cred = params.min_credibility.unwrap_or(0.0);

    let keywords: Vec<String> = params
        .keywords
        .map(|k| k.split(',').map(|s| s.trim().to_string()).collect())
        .unwrap_or_default();

    let (articles, next_cursor) = state
        .db
        .query_articles_advanced(QueryFilter {
            category,
            limit,
            cursor: params.cursor.as_deref(),
            min_credibility: min_cred,
            keywords: if keywords.is_empty() { None } else { Some(keywords) },
            sentiment: params.sentiment.as_deref(),
            from_date: params.from_date.as_deref(),
            to_date: params.to_date.as_deref(),
        })
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    Ok(Json(NewsResponse {
        articles,
        next_cursor,
        total_count: None, // 重い場合は省略
    }))
}
```

### 3.3 WebSocket Real-time Streaming

**実装方針:**
- 既存のSSE (Server-Sent Events) 実装を拡張
- WebSocket追加は将来実装 (複雑性考慮)

**SSE エンドポイント:**
```
GET /api/v1/news/stream
  Query Parameters:
    - categories: string[] (comma-separated)
    - min_credibility: float

  Event Stream:
    event: article
    data: {"id": "...", "title": "...", ...}

    event: heartbeat
    data: {"timestamp": "2026-02-15T10:00:00Z"}
```

**実装例:**
```rust
use axum::response::sse::{Event, KeepAlive, Sse};
use futures::stream::{self, Stream};
use tokio::sync::broadcast;
use tokio_stream::wrappers::BroadcastStream;

// Global broadcast channel for new articles
lazy_static! {
    static ref ARTICLE_CHANNEL: broadcast::Sender<Article> = {
        let (tx, _rx) = broadcast::channel(1000);
        tx
    };
}

pub async fn handle_news_stream(
    Query(params): Query<StreamParams>,
) -> Sse<impl Stream<Item = Result<Event, std::convert::Infallible>>> {
    let rx = ARTICLE_CHANNEL.subscribe();
    let stream = BroadcastStream::new(rx);

    let categories: Vec<String> = params
        .categories
        .map(|c| c.split(',').map(|s| s.trim().to_string()).collect())
        .unwrap_or_default();

    let min_cred = params.min_credibility.unwrap_or(0.0);

    let filtered_stream = stream.filter_map(move |result| {
        let article = result.ok()?;

        // Filter by category
        if !categories.is_empty() && !categories.contains(&article.category.as_str().to_string()) {
            return None;
        }

        // Filter by credibility
        if article.credibility_score.unwrap_or(0.0) < min_cred {
            return None;
        }

        Some(Ok(Event::default()
            .event("article")
            .json_data(&article)
            .unwrap()))
    });

    Sse::new(filtered_stream).keep_alive(KeepAlive::default())
}

// Fetcher broadcasts new articles
pub async fn broadcast_new_article(article: Article) {
    let _ = ARTICLE_CHANNEL.send(article);
}
```

### 3.4 Email Newsletter

**機能:**
- 日次/週次ダイジェスト配信
- カテゴリ別購読
- 信頼性スコア >= 0.7の記事のみ
- HTML + Plain Text 両対応

**実装:**
- SMTP: AWS SES or SendGrid
- テンプレート: Handlebars or Tera
- 購読管理: `email_subscriptions`テーブル

```rust
use lettre::{Message, SmtpTransport, Transport};

pub async fn send_daily_digest(
    email: &str,
    articles: &[Article],
    smtp_transport: &SmtpTransport,
) -> Result<(), String> {
    let html_body = render_newsletter_html(articles);
    let text_body = render_newsletter_text(articles);

    let email_msg = Message::builder()
        .from("News.xyz <noreply@news.xyz>".parse().unwrap())
        .to(email.parse().unwrap())
        .subject("News.xyz Daily Digest")
        .multipart(
            lettre::message::MultiPart::alternative()
                .singlepart(lettre::message::SinglePart::plain(text_body))
                .singlepart(lettre::message::SinglePart::html(html_body)),
        )
        .map_err(|e| e.to_string())?;

    smtp_transport
        .send(&email_msg)
        .map_err(|e| format!("SMTP error: {}", e))?;

    Ok(())
}

fn render_newsletter_html(articles: &[Article]) -> String {
    let items: Vec<String> = articles
        .iter()
        .map(|a| {
            format!(
                r#"<div style="margin-bottom: 20px;">
                    <h2><a href="{}">{}</a></h2>
                    <p style="color: #666;">{} | {}</p>
                    <p>{}</p>
                </div>"#,
                a.url,
                a.title,
                a.source,
                a.published_at.format("%Y-%m-%d %H:%M"),
                a.summary.as_ref().unwrap_or(&"".to_string())
            )
        })
        .collect();

    format!(
        r#"<html>
<body style="font-family: monospace; max-width: 600px; margin: 0 auto; padding: 20px;">
    <h1>News.xyz Daily Digest</h1>
    {}
    <hr>
    <p style="color: #999; font-size: 12px;">
        <a href="https://news.xyz/unsubscribe">Unsubscribe</a>
    </p>
</body>
</html>"#,
        items.join("")
    )
}
```

### 3.5 Webhook Notification

**ユースケース:**
- Slack/Discord通知
- Zapier/IFTTT連携
- 独自システム統合

**実装:**
```rust
use hmac::{Hmac, Mac};
use sha2::Sha256;

pub async fn send_webhook_notification(
    subscription: &WebhookSubscription,
    article: &Article,
    client: &reqwest::Client,
) -> Result<(), String> {
    let payload = serde_json::to_string(&article).map_err(|e| e.to_string())?;

    // HMAC署名生成
    let mut mac = Hmac::<Sha256>::new_from_slice(subscription.secret_token.as_bytes())
        .map_err(|e| e.to_string())?;
    mac.update(payload.as_bytes());
    let signature = hex::encode(mac.finalize().into_bytes());

    let response = client
        .post(&subscription.callback_url)
        .header("Content-Type", "application/json")
        .header("X-News-Signature", format!("sha256={}", signature))
        .header("X-News-Event", "article.published")
        .body(payload)
        .timeout(Duration::from_secs(10))
        .send()
        .await
        .map_err(|e| format!("Webhook request failed: {}", e))?;

    if !response.status().is_success() {
        return Err(format!("Webhook failed: {}", response.status()));
    }

    Ok(())
}

// Background worker
pub async fn webhook_worker(state: Arc<AppState>) {
    let mut rx = ARTICLE_CHANNEL.subscribe();

    while let Ok(article) = rx.recv().await {
        let subscriptions = state
            .db
            .get_active_webhooks()
            .unwrap_or_default();

        for sub in subscriptions {
            // Filter by subscription criteria
            if let Some(ref cats) = sub.categories {
                if !cats.contains(&article.category.as_str().to_string()) {
                    continue;
                }
            }

            if let Some(min_cred) = sub.min_credibility {
                if article.credibility_score.unwrap_or(0.0) < min_cred {
                    continue;
                }
            }

            // Send notification (non-blocking)
            let state_clone = Arc::clone(&state);
            let sub_clone = sub.clone();
            let article_clone = article.clone();
            tokio::spawn(async move {
                if let Err(e) = send_webhook_notification(
                    &sub_clone,
                    &article_clone,
                    &state_clone.http_client,
                )
                .await
                {
                    warn!("Webhook failed for {}: {}", sub_clone.subscription_id, e);
                }
            });
        }
    }
}
```

---

## 4. Technical Stack Selection

### 4.1 AI Models

| タスク | Primary Model | Fallback | Local Option | コスト (1M tokens) |
|--------|--------------|----------|--------------|-------------------|
| 要約 | Claude Sonnet 4.5 | GPT-4o-mini | Qwen3-0.6B | $3 / $0.15 / $0 |
| 分類 | Claude Haiku 4.0 | - | Qwen2.5-7B | $0.25 / - / $0 |
| 埋め込み | OpenAI text-embedding-3-small | - | intfloat/e5-large | $0.02 / - / $0 |
| 感情分析 | - | - | Rule-based | $0 |

### 4.2 Vector Database

**選択肢:**
1. **SQLite with BLOB storage** (現在のDB拡張、シンプル)
2. **Qdrant** (Rust製、高速、スタンドアロン or クラウド)
3. **Milvus** (スケール重視、オーバースペック)
4. **pgvector** (PostgreSQL拡張、移行コスト大)

**推奨:** SQLite BLOB + インメモリインデックス (初期実装) → Qdrant移行 (10万記事超)

```rust
// SQLite + 線形探索 (10万記事で約50ms)
pub fn find_similar_articles(
    db: &Db,
    query_embedding: &[f32],
    threshold: f32,
    limit: usize,
) -> Result<Vec<(String, f32)>, String> {
    let conn = db.conn.lock().map_err(|e| e.to_string())?;

    let mut stmt = conn
        .prepare("SELECT article_id, embedding FROM article_vectors WHERE processed_at > datetime('now', '-7 days')")
        .map_err(|e| e.to_string())?;

    let mut results: Vec<(String, f32)> = Vec::new();

    let rows = stmt
        .query_map([], |row| {
            let id: String = row.get(0)?;
            let blob: Vec<u8> = row.get(1)?;
            Ok((id, blob))
        })
        .map_err(|e| e.to_string())?;

    for row in rows {
        let (id, blob) = row.map_err(|e| e.to_string())?;
        let embedding: Vec<f32> = blob
            .chunks_exact(4)
            .map(|chunk| f32::from_le_bytes([chunk[0], chunk[1], chunk[2], chunk[3]]))
            .collect();

        let similarity = cosine_similarity(query_embedding, &embedding);
        if similarity >= threshold {
            results.push((id, similarity));
        }
    }

    results.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap());
    results.truncate(limit);

    Ok(results)
}
```

### 4.3 Caching Strategy

**レイヤー:**
1. **Application Cache:** 既存 `ai_cache`テーブル (24時間TTL)
2. **Redis:** 将来追加 (高速アクセス、セッション管理)
3. **CDN:** Cloudflare (静的アセット、RSS feed)

**キャッシュ戦略:**
- 要約: 24時間 (記事URLをキー)
- 分類: 永続 (記事作成時に決定、変更なし)
- ベクトル: 永続 (`article_vectors`テーブル)
- RSS/Atom feed: 5分 (Cloudflare CDN)
- JSON API: 1分 (アプリケーションレベル)

---

## 5. Implementation Roadmap

### Phase 1: AI Cleaning Foundation (Week 1-2)

**目標:** 基本的なAI処理パイプラインを構築

**タスク:**
1. データベーススキーマ拡張
   - `ALTER TABLE articles ADD COLUMN summary TEXT;`
   - 他のカラム追加 (keywords, sentiment, credibility_score, etc.)
   - `article_vectors`テーブル作成
2. 要約生成機能
   - `crates/news-ai/src/summarizer.rs` 実装
   - Claude API統合 (既存`claude.rs`を拡張)
   - バッチ処理 (10件ずつ)
3. 信頼性スコア計算
   - ソース評価マップ作成 (`sources_rating.toml`)
   - `calculate_credibility_score()` 実装
4. 基本的な感情分析
   - ルールベース実装
   - ポジティブ/ネガティブ単語リスト (日英)
5. fetcher統合
   - 新規記事取得時にAI処理トリガー
   - 非同期処理 (tokio::spawn)

**検証:**
- 100記事でE2Eテスト
- 処理時間: 100記事/分 (並列処理)
- APIコスト: $0.03/100記事

### Phase 2: Distribution API (Week 3-4)

**目標:** REST API、RSS、WebSocket配信を実装

**タスク:**
1. REST API実装
   - `GET /api/v1/news` (フィルタ、ページング)
   - `GET /api/v1/news/:id`
   - `GET /api/v1/news/:id/summary`
2. RSS/Atom feed生成
   - `generate_rss_feed()` 実装
   - カテゴリ別feed
   - 信頼性フィルタ付きfeed
3. SSE streaming拡張
   - 既存SSEを記事配信用に拡張
   - フィルタリング (カテゴリ、信頼性)
4. API認証
   - Bearer token (既存Stripe統合)
   - Rate limiting (tower middleware)
5. OpenAPI仕様書
   - Swagger UI統合
   - `openapi.yaml` 生成

**検証:**
- Postmanでエンドポイントテスト
- RSS feedリーダーで購読確認 (Feedly, NetNewsWire)
- SSE接続テスト (curl, EventSource API)

### Phase 3: Advanced Features (Week 5-6)

**目標:** ベクトル検索、重複検出、Webhook配信

**タスク:**
1. ベクトル埋め込み
   - intfloat/e5-largeモデルダウンロード
   - `EmbeddingModel::load()` 実装
   - バッチ処理 (100記事/バッチ)
2. セマンティック重複検出
   - `find_similar_articles()` 実装
   - 重複クラスタ生成
   - 代表記事選定ロジック
3. Webhook配信
   - `webhook_subscriptions`テーブル実装
   - `POST /api/v1/subscribe` エンドポイント
   - Background worker (`webhook_worker`)
   - HMAC署名検証
4. Email newsletter
   - `email_subscriptions`テーブル実装
   - SMTP統合 (AWS SES)
   - 日次/週次バッチ処理
   - HTML/Text テンプレート

**検証:**
- ベクトル検索精度: 類似記事検出率 > 90%
- Webhook配信: 成功率 > 95%
- Email配信: 開封率 > 20% (業界平均)

### Phase 4: Optimization & Monitoring (Week 7-8)

**目標:** パフォーマンス最適化、監視システム構築

**タスク:**
1. パフォーマンスチューニング
   - SQLiteインデックス最適化
   - バッチ処理並列度調整
   - API応答時間 < 100ms (p95)
2. 監視システム
   - Prometheus metrics
   - Grafanaダッシュボード
   - エラー率、レイテンシ、スループット
3. コスト最適化
   - Claude API呼び出し削減 (キャッシュヒット率向上)
   - バッチ処理効率化
   - 月次コスト < $100/10万記事
4. ドキュメント整備
   - API仕様書
   - デプロイ手順
   - トラブルシューティングガイド

**検証:**
- 負荷テスト: 1000 req/sec
- 可用性: 99.9%
- エラー率 < 0.1%

---

## 6. API Specifications

### 6.1 RESTful Endpoints

**Base URL:** `https://news.xyz/api/v1`

#### GET /news

ニュース記事一覧を取得

**Query Parameters:**
```yaml
category:
  type: string
  enum: [general, tech, business, entertainment, sports, science, podcast]
  description: フィルタするカテゴリ

limit:
  type: integer
  default: 20
  minimum: 1
  maximum: 100
  description: 取得件数

cursor:
  type: string
  description: ページングカーソル (前回レスポンスのnext_cursorを指定)

min_credibility:
  type: number
  format: float
  minimum: 0.0
  maximum: 1.0
  description: 最小信頼性スコア

keywords:
  type: string
  description: カンマ区切りキーワード (例: "AI,機械学習")

sentiment:
  type: string
  enum: [positive, negative, neutral]
  description: 感情フィルタ

from_date:
  type: string
  format: date-time
  description: 開始日時 (ISO8601)

to_date:
  type: string
  format: date-time
  description: 終了日時 (ISO8601)
```

**Response:**
```json
{
  "articles": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "OpenAI releases GPT-5",
      "url": "https://example.com/article",
      "summary": "OpenAI announced GPT-5 with improved reasoning.",
      "source": "TechCrunch",
      "category": "tech",
      "published_at": "2026-02-15T10:00:00Z",
      "fetched_at": "2026-02-15T10:05:00Z",
      "credibility_score": 0.85,
      "sentiment": "neutral",
      "sentiment_score": 0.1,
      "keywords": ["OpenAI", "GPT-5", "AI"],
      "image_url": "https://example.com/image.jpg",
      "group_id": "abc-123",
      "duplicate_count": 3
    }
  ],
  "next_cursor": "eyJwdWJsaXNoZWRfYXQiOiIyMDI2LTAyLTE1VDA5OjU1OjAwWiIsImlkIjoiLi4uIn0=",
  "total_count": 1234
}
```

#### GET /news/:id

個別記事を取得

**Response:**
```json
{
  "article": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "...",
    "url": "...",
    "summary": "...",
    "description": "Full article description...",
    "source": "TechCrunch",
    "category": "tech",
    "published_at": "2026-02-15T10:00:00Z",
    "credibility_score": 0.85,
    "sentiment": "neutral",
    "keywords": ["OpenAI", "GPT-5"],
    "image_url": "...",
    "group_id": "abc-123"
  },
  "related_articles": [
    {
      "id": "...",
      "title": "...",
      "similarity": 0.92
    }
  ],
  "duplicates": [
    {
      "id": "...",
      "title": "...",
      "source": "Reuters",
      "url": "..."
    }
  ]
}
```

#### GET /news/:id/summary

AI生成要約を取得

**Response:**
```json
{
  "summary": "OpenAIは次世代LLM GPT-5を発表。推論能力が大幅に向上し、数学・コーディングタスクで人間レベルの性能を達成。",
  "generated_at": "2026-02-15T10:10:00Z",
  "model": "claude-sonnet-4-5",
  "confidence": 0.95
}
```

#### POST /subscribe

Webhook購読登録

**Request:**
```json
{
  "callback_url": "https://example.com/webhook",
  "categories": ["tech", "science"],
  "keywords": ["AI", "機械学習"],
  "min_credibility": 0.7,
  "secret_token": "your-secret-token-here"
}
```

**Response:**
```json
{
  "subscription_id": "sub_abc123",
  "status": "active",
  "created_at": "2026-02-15T10:00:00Z"
}
```

#### DELETE /subscribe/:id

Webhook購読解除

**Response:** `204 No Content`

### 6.2 WebSocket / SSE Streaming

**Endpoint:** `GET /api/v1/news/stream`

**Query Parameters:**
```yaml
categories:
  type: string
  description: カンマ区切りカテゴリ (例: "tech,science")

min_credibility:
  type: number
  description: 最小信頼性スコア
```

**Event Stream:**
```
event: article
data: {"id": "...", "title": "...", "category": "tech", ...}

event: article
data: {"id": "...", "title": "...", "category": "science", ...}

event: heartbeat
data: {"timestamp": "2026-02-15T10:00:00Z"}
```

**Client Example (JavaScript):**
```javascript
const eventSource = new EventSource('/api/v1/news/stream?categories=tech&min_credibility=0.7');

eventSource.addEventListener('article', (event) => {
  const article = JSON.parse(event.data);
  console.log('New article:', article.title);
});

eventSource.addEventListener('heartbeat', (event) => {
  console.log('Server alive:', event.data);
});
```

### 6.3 RSS/Atom Feeds

**Endpoints:**
- `GET /api/feed?format=rss` (RSS 2.0)
- `GET /api/feed?format=atom` (Atom 1.0)
- `GET /api/feed/{category}?format=rss`
- `GET /api/feed/curated?min_credibility=0.8&format=rss`

**Response (RSS):**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>News.xyz - Tech</title>
    <link>https://news.xyz</link>
    <description>Clean, ad-free tech news</description>
    <lastBuildDate>Sat, 15 Feb 2026 10:00:00 +0000</lastBuildDate>
    <item>
      <title>OpenAI releases GPT-5</title>
      <link>https://example.com/article</link>
      <guid>https://example.com/article</guid>
      <pubDate>Sat, 15 Feb 2026 10:00:00 +0000</pubDate>
      <description>OpenAI announced GPT-5 with improved reasoning.</description>
      <category>tech</category>
      <source url="https://techcrunch.com">TechCrunch</source>
      <enclosure url="https://example.com/image.jpg" type="image/jpeg" />
    </item>
  </channel>
</rss>
```

---

## 7. Cost Estimation

### 7.1 AI Model Execution Costs

**想定:** 日次10,000記事取得、うち20%が新規 (2,000記事/日)

| タスク | 処理数/日 | トークン数/記事 | モデル | 単価 ($/1M tok) | 日次コスト | 月次コスト |
|--------|-----------|-----------------|--------|-----------------|-----------|-----------|
| 要約生成 | 2,000 | 500 input + 100 output | Claude Sonnet 4.5 | $3 / $15 | $4.50 | $135 |
| カテゴリ分類 | 2,000 | 100 input + 10 output | Claude Haiku 4.0 | $0.25 / $1.25 | $0.075 | $2.25 |
| ベクトル埋め込み | 2,000 | 200 input | OpenAI embedding-3-small | $0.02 | $0.008 | $0.24 |
| **合計** | - | - | - | - | **$4.58** | **$137** |

**最適化後 (キャッシュヒット率80%):**
- 実際の処理数: 400記事/日 (新規のみ)
- 月次コスト: **$27**

**ローカルモデル移行時:**
- Qwen3-0.6B (要約) + Qwen2.5-7B (分類) + intfloat/e5-large (埋め込み)
- AI実行コスト: **$0** (インフラコストのみ)

### 7.2 Infrastructure Costs

**現在 (Fly.io):**
- 1x shared-cpu-1x (256MB RAM): $1.94/月
- ボリューム (10GB): $1.50/月
- **合計: $3.44/月**

**AI処理追加時 (GPU必要):**
- 1x performance-1x (2GB RAM): $62/月
- または 1x gpu-a10 (GPU推論): $3.50/時間 = $2,520/月 (24時間稼働)
- **推奨:** バッチ処理 (1日1時間) → $105/月

**スケーリング時 (10万記事/日):**
- 2x performance-2x: $250/月
- PostgreSQL (managed): $50/月
- Redis (managed): $30/月
- **合計: $330/月**

### 7.3 Distribution Costs

**Email Newsletter (AWS SES):**
- 1,000購読者 × 1通/日 × 30日 = 30,000通/月
- AWS SES: $0.10/1,000通 = **$3/月**

**Webhook配信 (無料):**
- アウトバウンドHTTPリクエストのみ
- Fly.ioは転送量無制限 → **$0**

**CDN (Cloudflare):**
- Freeプランで十分 (RSS feedキャッシュ) → **$0**

### 7.4 Total Cost Summary

| シナリオ | AI処理 | インフラ | Email | 合計/月 |
|---------|--------|---------|-------|---------|
| **Phase 1 (API依存)** | $27 | $3.44 | $3 | **$33** |
| **Phase 2 (ローカルモデル)** | $0 | $105 | $3 | **$108** |
| **Phase 3 (スケール: 10万記事/日)** | $0 | $330 | $10 | **$340** |

**収益化目標:**
- 100 Proユーザー × $10/月 = $1,000/月 → Phase 3コストカバー可能
- 広告表示 (オプション): $500-1,000/月 (10万PV想定)

---

## 8. Implementation Code Examples

### 8.1 Article Summarization

```rust
// crates/news-ai/src/summarizer.rs

use reqwest::Client;
use serde::{Deserialize, Serialize};

#[derive(Serialize)]
struct ClaudeRequest {
    model: String,
    max_tokens: u32,
    messages: Vec<Message>,
}

#[derive(Serialize, Deserialize)]
struct Message {
    role: String,
    content: String,
}

#[derive(Deserialize)]
struct ClaudeResponse {
    content: Vec<ContentBlock>,
}

#[derive(Deserialize)]
struct ContentBlock {
    text: Option<String>,
}

pub async fn batch_summarize_articles(
    client: &Client,
    api_key: &str,
    articles: &[(String, String, String)], // (id, title, description)
) -> Result<Vec<(String, String)>, String> {
    let mut results = Vec::new();

    // Process in batches of 10
    for chunk in articles.chunks(10) {
        let mut summaries = Vec::new();

        for (id, title, desc) in chunk {
            let summary = summarize_single(client, api_key, title, desc).await?;
            summaries.push((id.clone(), summary));
        }

        results.extend(summaries);
    }

    Ok(results)
}

async fn summarize_single(
    client: &Client,
    api_key: &str,
    title: &str,
    description: &str,
) -> Result<String, String> {
    let prompt = format!(
        "以下のニュース記事を1-2文(100文字以内)で要約してください。\n\n\
        タイトル: {}\n\n\
        本文: {}",
        title,
        &description[..description.len().min(2000)]
    );

    let request = ClaudeRequest {
        model: "claude-sonnet-4-5-20250929".into(),
        max_tokens: 200,
        messages: vec![Message {
            role: "user".into(),
            content: prompt,
        }],
    };

    let response = client
        .post("https://api.anthropic.com/v1/messages")
        .header("x-api-key", api_key)
        .header("anthropic-version", "2023-06-01")
        .json(&request)
        .timeout(std::time::Duration::from_secs(30))
        .send()
        .await
        .map_err(|e| format!("API request: {}", e))?;

    let body: ClaudeResponse = response.json().await.map_err(|e| e.to_string())?;

    body.content
        .first()
        .and_then(|b| b.text.clone())
        .ok_or_else(|| "No summary".to_string())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_summarize() {
        let client = Client::new();
        let api_key = std::env::var("ANTHROPIC_API_KEY").unwrap();

        let summary = summarize_single(
            &client,
            &api_key,
            "OpenAI releases GPT-5",
            "OpenAI has announced GPT-5, the next generation of their language model...",
        )
        .await
        .unwrap();

        assert!(summary.len() > 0);
        assert!(summary.len() < 200);
    }
}
```

### 8.2 Semantic Duplicate Detection

```rust
// crates/news-ai/src/dedup_semantic.rs

use std::collections::HashMap;

pub struct DuplicateDetector {
    embeddings: HashMap<String, Vec<f32>>, // article_id -> embedding
}

impl DuplicateDetector {
    pub fn new() -> Self {
        Self {
            embeddings: HashMap::new(),
        }
    }

    pub fn add_article(&mut self, article_id: String, embedding: Vec<f32>) {
        self.embeddings.insert(article_id, embedding);
    }

    pub fn find_duplicates(
        &self,
        query_embedding: &[f32],
        threshold: f32,
    ) -> Vec<(String, f32)> {
        let mut results: Vec<(String, f32)> = self
            .embeddings
            .iter()
            .map(|(id, emb)| {
                let similarity = cosine_similarity(query_embedding, emb);
                (id.clone(), similarity)
            })
            .filter(|(_, sim)| *sim >= threshold)
            .collect();

        results.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap());
        results
    }

    pub fn cluster_duplicates(&self, threshold: f32) -> Vec<Vec<String>> {
        let ids: Vec<String> = self.embeddings.keys().cloned().collect();
        let n = ids.len();
        let mut parent: Vec<usize> = (0..n).collect();

        fn find(parent: &mut [usize], i: usize) -> usize {
            if parent[i] != i {
                parent[i] = find(parent, parent[i]);
            }
            parent[i]
        }

        fn union(parent: &mut [usize], a: usize, b: usize) {
            let ra = find(parent, a);
            let rb = find(parent, b);
            if ra != rb {
                parent[rb] = ra;
            }
        }

        // Compare all pairs
        for i in 0..n {
            for j in (i + 1)..n {
                let emb_i = &self.embeddings[&ids[i]];
                let emb_j = &self.embeddings[&ids[j]];
                let similarity = cosine_similarity(emb_i, emb_j);

                if similarity >= threshold {
                    union(&mut parent, i, j);
                }
            }
        }

        // Collect clusters
        let mut clusters: HashMap<usize, Vec<String>> = HashMap::new();
        for i in 0..n {
            let root = find(&mut parent, i);
            clusters.entry(root).or_default().push(ids[i].clone());
        }

        clusters.into_values().collect()
    }
}

fn cosine_similarity(a: &[f32], b: &[f32]) -> f32 {
    let dot: f32 = a.iter().zip(b).map(|(x, y)| x * y).sum();
    let norm_a: f32 = a.iter().map(|x| x * x).sum::<f32>().sqrt();
    let norm_b: f32 = b.iter().map(|x| x * x).sum::<f32>().sqrt();
    dot / (norm_a * norm_b)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_cosine_similarity() {
        let a = vec![1.0, 0.0, 0.0];
        let b = vec![1.0, 0.0, 0.0];
        assert!((cosine_similarity(&a, &b) - 1.0).abs() < f32::EPSILON);

        let c = vec![0.0, 1.0, 0.0];
        assert!((cosine_similarity(&a, &c) - 0.0).abs() < f32::EPSILON);
    }

    #[test]
    fn test_duplicate_detection() {
        let mut detector = DuplicateDetector::new();
        detector.add_article("1".into(), vec![1.0, 0.0, 0.0]);
        detector.add_article("2".into(), vec![0.9, 0.1, 0.0]);
        detector.add_article("3".into(), vec![0.0, 1.0, 0.0]);

        let query = vec![1.0, 0.0, 0.0];
        let duplicates = detector.find_duplicates(&query, 0.85);

        assert_eq!(duplicates.len(), 2); // "1" and "2"
        assert_eq!(duplicates[0].0, "1");
    }
}
```

### 8.3 Distribution System Sample

```rust
// crates/news-server/src/distribution.rs

use axum::{
    extract::{Query, State},
    http::{header, StatusCode},
    response::{IntoResponse, sse::{Event, Sse}},
    Json,
};
use futures::stream::{self, Stream};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use tokio::sync::broadcast;
use tokio_stream::wrappers::BroadcastStream;

use crate::db::Db;
use news_core::models::{Article, Category};

#[derive(Deserialize)]
pub struct FeedParams {
    category: Option<String>,
    format: Option<String>,
    min_credibility: Option<f32>,
}

pub async fn handle_rss_feed(
    Query(params): Query<FeedParams>,
    State(state): State<Arc<AppState>>,
) -> impl IntoResponse {
    let category = params.category.as_deref().and_then(Category::from_str);
    let min_cred = params.min_credibility.unwrap_or(0.0);

    let articles = state
        .db
        .query_articles_with_credibility(category.as_ref(), 50, None, min_cred)
        .unwrap_or_default();

    let feed_xml = generate_rss_feed(&articles.0, &state.base_url, category.as_ref());

    (
        StatusCode::OK,
        [(header::CONTENT_TYPE, "application/xml; charset=utf-8")],
        feed_xml,
    )
}

fn generate_rss_feed(
    articles: &[Article],
    base_url: &str,
    category: Option<&Category>,
) -> String {
    let title = match category {
        Some(cat) => format!("News.xyz - {}", cat.as_str()),
        None => "News.xyz - All News".to_string(),
    };

    let items: Vec<String> = articles
        .iter()
        .map(|a| {
            format!(
                r#"    <item>
      <title><![CDATA[{}]]></title>
      <link>{}</link>
      <guid>{}</guid>
      <pubDate>{}</pubDate>
      <description><![CDATA[{}]]></description>
      <category>{}</category>
      {}
    </item>"#,
                a.title,
                a.url,
                a.url,
                a.published_at.to_rfc2822(),
                a.summary.as_ref().unwrap_or(&"".to_string()),
                a.category.as_str(),
                a.image_url
                    .as_ref()
                    .map(|img| format!("<enclosure url=\"{}\" type=\"image/jpeg\" />", img))
                    .unwrap_or_default()
            )
        })
        .collect();

    format!(
        r#"<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>{}</title>
    <link>{}</link>
    <description>Clean, ad-free news aggregation powered by AI</description>
    <lastBuildDate>{}</lastBuildDate>
{}
  </channel>
</rss>"#,
        title,
        base_url,
        chrono::Utc::now().to_rfc2822(),
        items.join("\n")
    )
}

// SSE Streaming
#[derive(Deserialize)]
pub struct StreamParams {
    categories: Option<String>,
    min_credibility: Option<f32>,
}

pub async fn handle_news_stream(
    Query(params): Query<StreamParams>,
    State(state): State<Arc<AppState>>,
) -> Sse<impl Stream<Item = Result<Event, std::convert::Infallible>>> {
    let rx = state.article_broadcast.subscribe();
    let stream = BroadcastStream::new(rx);

    let categories: Vec<String> = params
        .categories
        .map(|c| c.split(',').map(|s| s.trim().to_string()).collect())
        .unwrap_or_default();

    let min_cred = params.min_credibility.unwrap_or(0.0);

    let filtered_stream = stream::unfold(stream, move |mut stream| async move {
        while let Some(result) = stream.next().await {
            if let Ok(article) = result {
                // Filter by category
                if !categories.is_empty()
                    && !categories.contains(&article.category.as_str().to_string())
                {
                    continue;
                }

                // Filter by credibility
                if article.credibility_score.unwrap_or(0.0) < min_cred {
                    continue;
                }

                return Some((
                    Ok(Event::default()
                        .event("article")
                        .json_data(&article)
                        .unwrap()),
                    stream,
                ));
            }
        }
        None
    });

    Sse::new(filtered_stream)
}

// AppState extension
pub struct AppState {
    pub db: Arc<Db>,
    pub article_broadcast: broadcast::Sender<Article>,
    pub base_url: String,
    // ... other fields
}

impl AppState {
    pub fn new(db: Arc<Db>, base_url: String) -> Self {
        let (tx, _rx) = broadcast::channel(1000);
        Self {
            db,
            article_broadcast: tx,
            base_url,
        }
    }

    pub fn broadcast_article(&self, article: Article) {
        let _ = self.article_broadcast.send(article);
    }
}
```

---

## 9. Deployment & Operations

### 9.1 Deployment Strategy

**Current (Fly.io):**
```toml
# fly.toml
app = "news-xyz"
primary_region = "nrt"

[build]
  builder = "paketobuildpacks/builder:base"

[env]
  DATABASE_PATH = "/data/news.db"
  STATIC_DIR = "/app/public"

[[mounts]]
  source = "news_data"
  destination = "/data"

[[services]]
  internal_port = 8080
  protocol = "tcp"

  [[services.ports]]
    handlers = ["http"]
    port = 80

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443
```

**With AI Pipeline:**
```toml
[env]
  ANTHROPIC_API_KEY = "..."
  OPENAI_API_KEY = "..."
  ENABLE_AI_PROCESSING = "true"
  AI_BATCH_SIZE = "10"
  EMBEDDING_MODEL_PATH = "/app/models/e5-large"

# GPU instance for local models (optional)
[vm]
  size = "performance-2x"
  memory = "4gb"
```

### 9.2 Monitoring & Logging

**Metrics (Prometheus):**
```rust
use prometheus::{Counter, Histogram, IntGauge};

lazy_static! {
    static ref ARTICLES_PROCESSED: Counter = Counter::new(
        "articles_processed_total",
        "Total articles processed by AI pipeline"
    ).unwrap();

    static ref AI_PROCESSING_TIME: Histogram = Histogram::new(
        "ai_processing_duration_seconds",
        "Time spent processing articles with AI"
    ).unwrap();

    static ref ACTIVE_SUBSCRIPTIONS: IntGauge = IntGauge::new(
        "webhook_subscriptions_active",
        "Number of active webhook subscriptions"
    ).unwrap();
}

pub fn record_article_processed() {
    ARTICLES_PROCESSED.inc();
}

pub fn record_ai_processing_time(duration: f64) {
    AI_PROCESSING_TIME.observe(duration);
}
```

**Logging (tracing):**
```rust
use tracing::{info, warn, error, instrument};

#[instrument(skip(client, api_key))]
pub async fn process_article_pipeline(
    article: &Article,
    client: &Client,
    api_key: &str,
) -> Result<EnrichedArticle, String> {
    info!(article_id = %article.id, "Starting AI processing");

    let start = std::time::Instant::now();

    let summary = summarize_article(client, api_key, &article.title, &article.description)
        .await
        .map_err(|e| {
            error!(article_id = %article.id, error = %e, "Summarization failed");
            e
        })?;

    let credibility = calculate_credibility_score(article);
    let (sentiment, sentiment_score) = analyze_sentiment(&summary);

    let duration = start.elapsed().as_secs_f64();
    record_ai_processing_time(duration);

    info!(
        article_id = %article.id,
        duration_sec = duration,
        credibility = credibility,
        sentiment = %sentiment,
        "AI processing complete"
    );

    Ok(EnrichedArticle {
        article: article.clone(),
        summary,
        credibility_score: credibility,
        sentiment,
        sentiment_score,
    })
}
```

### 9.3 Backup & Recovery

**SQLite Backup:**
```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/data/backups"
DB_PATH="/data/news.db"

mkdir -p $BACKUP_DIR

# SQLite backup command
sqlite3 $DB_PATH ".backup '$BACKUP_DIR/news_$DATE.db'"

# Compress
gzip $BACKUP_DIR/news_$DATE.db

# Upload to S3
aws s3 cp $BACKUP_DIR/news_$DATE.db.gz s3://news-xyz-backups/

# Delete old backups (keep 30 days)
find $BACKUP_DIR -name "news_*.db.gz" -mtime +30 -delete

echo "Backup complete: news_$DATE.db.gz"
```

**Automated Cron:**
```bash
# Fly.io: Add to Dockerfile
RUN echo "0 2 * * * /app/backup.sh" | crontab -
```

---

## 10. Testing Strategy

### 10.1 Unit Tests

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_summarization_e2e() {
        let client = Client::new();
        let api_key = std::env::var("ANTHROPIC_API_KEY").unwrap();

        let article = Article {
            id: "test-1".into(),
            title: "OpenAI Releases GPT-5".into(),
            description: Some("OpenAI has announced GPT-5...".into()),
            // ... other fields
        };

        let summary = summarize_article(&client, &api_key, &article.title, &article.description)
            .await
            .unwrap();

        assert!(summary.len() > 0);
        assert!(summary.len() < 200);
    }

    #[test]
    fn test_credibility_scoring() {
        let article = Article {
            id: "test-1".into(),
            url: "https://news.example.go.jp/article".into(),
            source: "NHK".into(),
            description: Some("A".repeat(600)),
            image_url: Some("https://example.com/image.jpg".into()),
            // ... other fields
        };

        let score = calculate_credibility_score(&article, get_source_rating("NHK"));
        assert!(score > 0.8); // High credibility
    }

    #[test]
    fn test_sentiment_analysis() {
        let (sentiment, score) = analyze_sentiment("This is a great success story!");
        assert_eq!(sentiment, "positive");
        assert!(score > 0.0);

        let (sentiment, score) = analyze_sentiment("Crisis and failure reported.");
        assert_eq!(sentiment, "negative");
        assert!(score < 0.0);
    }
}
```

### 10.2 Integration Tests

```rust
#[tokio::test]
async fn test_rss_feed_generation() {
    let db = Arc::new(Db::open(":memory:").unwrap());
    let state = Arc::new(AppState::new(db.clone(), "https://news.xyz".into()));

    // Insert test articles
    let article = Article {
        id: "test-1".into(),
        category: Category::Tech,
        title: "Test Article".into(),
        url: "https://example.com".into(),
        summary: Some("Test summary".into()),
        // ... other fields
    };
    db.insert_article(&article).unwrap();

    // Generate RSS feed
    let articles = db.query_articles(Some(&Category::Tech), 10, None).unwrap();
    let feed_xml = generate_rss_feed(&articles.0, &state.base_url, Some(&Category::Tech));

    assert!(feed_xml.contains("<title>Test Article</title>"));
    assert!(feed_xml.contains("<category>tech</category>"));
}

#[tokio::test]
async fn test_webhook_notification() {
    let client = Client::new();
    let subscription = WebhookSubscription {
        subscription_id: "test-1".into(),
        callback_url: "https://httpbin.org/post".into(),
        secret_token: "test-secret".into(),
        // ... other fields
    };

    let article = Article {
        // ... test article
    };

    let result = send_webhook_notification(&subscription, &article, &client).await;
    assert!(result.is_ok());
}
```

### 10.3 Load Testing

```bash
# Install wrk
brew install wrk

# Test REST API
wrk -t4 -c100 -d30s --latency https://news.xyz/api/v1/news

# Test RSS feed
wrk -t2 -c50 -d30s --latency https://news.xyz/api/feed

# Test SSE streaming
curl -N https://news.xyz/api/v1/news/stream
```

**Expected Performance:**
- REST API: < 100ms p95, > 1000 req/sec
- RSS Feed: < 50ms p95 (CDN cached)
- SSE: < 10ms first event, stable connection for 1h+

---

## 11. Security Considerations

### 11.1 API Authentication

**Bearer Token:**
```rust
use axum::{
    extract::{Request, State},
    http::StatusCode,
    middleware::Next,
    response::IntoResponse,
};

pub async fn auth_middleware(
    State(state): State<Arc<AppState>>,
    request: Request,
    next: Next,
) -> Result<impl IntoResponse, StatusCode> {
    let auth_header = request
        .headers()
        .get("authorization")
        .and_then(|h| h.to_str().ok())
        .ok_or(StatusCode::UNAUTHORIZED)?;

    let token = auth_header
        .strip_prefix("Bearer ")
        .ok_or(StatusCode::UNAUTHORIZED)?;

    // Verify token
    let user = state
        .db
        .get_user_by_token(token)
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?
        .ok_or(StatusCode::UNAUTHORIZED)?;

    // Add user to request extensions
    request.extensions_mut().insert(user);

    Ok(next.run(request).await)
}
```

### 11.2 Rate Limiting

```rust
use tower::limit::RateLimitLayer;
use std::time::Duration;

// In main.rs
let api_routes = Router::new()
    .route("/api/v1/news", get(handle_get_news))
    .layer(RateLimitLayer::new(100, Duration::from_secs(60))); // 100 req/min
```

### 11.3 Webhook Signature Verification

```rust
use hmac::{Hmac, Mac};
use sha2::Sha256;

pub fn verify_webhook_signature(
    payload: &str,
    signature: &str,
    secret: &str,
) -> Result<(), String> {
    let expected_sig = signature
        .strip_prefix("sha256=")
        .ok_or("Invalid signature format")?;

    let mut mac = Hmac::<Sha256>::new_from_slice(secret.as_bytes())
        .map_err(|e| e.to_string())?;
    mac.update(payload.as_bytes());
    let computed = hex::encode(mac.finalize().into_bytes());

    if computed == expected_sig {
        Ok(())
    } else {
        Err("Signature mismatch".to_string())
    }
}
```

---

## 12. Future Enhancements

### 12.1 Phase 5 Features (Q3 2026)

1. **ユーザーカスタマイズ:**
   - 個人化フィード (興味に基づく推薦)
   - 既読/未読管理
   - ブックマーク機能

2. **高度なAI機能:**
   - ファクトチェックAPI統合 (Google Fact Check)
   - マルチモーダル分析 (画像・動画の内容理解)
   - 自動記事生成 (複数ソースから統合記事作成)

3. **モバイルアプリ:**
   - iOS/Android ネイティブアプリ
   - プッシュ通知 (重要ニュース)
   - オフライン読書

### 12.2 スケーラビリティ改善

1. **データベース移行:**
   - SQLite → PostgreSQL (100万記事超)
   - DynamoDB (グローバル展開時)

2. **ベクトルDB:**
   - Qdrant導入 (高速類似検索)
   - 分散インデックス (シャーディング)

3. **キャッシング:**
   - Redis導入 (セッション、API応答)
   - Cloudflare Workers (エッジキャッシング)

### 12.3 ビジネスモデル

1. **Proプラン ($10/月):**
   - API無制限アクセス
   - リアルタイムWebhook
   - カスタムフィルタ
   - 優先サポート

2. **Enterpriseプラン ($100+/月):**
   - 専用インスタンス
   - カスタムAIモデル
   - SLA保証 (99.99% uptime)
   - オンプレミス展開

3. **API課金:**
   - Free: 100 req/日
   - Pro: 10,000 req/日
   - Enterprise: 無制限

---

## 13. Conclusion

本実装プランにより、news.xyzは単なるRSSアグリゲーターから、AIを活用した次世代ニュースプラットフォームへと進化します。

**主要な成果:**
- **AI処理:** 要約、重複排除、分類、信頼性評価、感情分析
- **配信:** REST API, RSS/Atom, WebSocket, Email, Webhook
- **コスト効率:** $27/月 (APIベース) または $108/月 (ローカルモデル)
- **スケーラビリティ:** 10万記事/日まで対応可能

**次のステップ:**
1. データベーススキーマ拡張 (Week 1)
2. AI処理パイプライン実装 (Week 1-2)
3. REST API & RSS実装 (Week 3-4)
4. ベクトル検索 & Webhook (Week 5-6)
5. 最適化 & 監視 (Week 7-8)

**成功指標:**
- API応答時間 < 100ms (p95)
- AI処理スループット > 100記事/分
- 重複検出精度 > 90%
- 可用性 > 99.9%
- 月次コスト < $100 (10万記事/日)

**Questions / Feedback:**
- GitHub: https://github.com/yukihamada/news-xyz
- Email: yuki@news.xyz
- Twitter: @yukihamada

---

**Generated with:** Claude Sonnet 4.5
**Date:** 2026-02-15
**Version:** 1.0
