# News.xyz Product Hunt Launch Guide

## 🚀 Product Hunt提出準備完了

### タイトル
```
News.xyz - WorldMonitor Powered News Aggregation
```

### Tagline（60文字以内）
```
Minimal terminal-style news from 100+ sources. Zero clutter.
```

### Description（260文字以内）
```
News.xyz delivers clean, ad-free news in a beautiful terminal interface. Powered by WorldMonitor extreme minimal design, get instant access to 100+ curated sources with 1px precision. No tracking, no bloat, just news.
```

### 完全版Description
```
**News.xyz** brings back the joy of reading news with a WorldMonitor-inspired terminal interface.

## What makes News.xyz different?

⚡ **Extreme Minimal Design**
- 1px borders, 12px text, #0a0a0a dark theme
- Monospace fonts (SF Mono, Monaco, Fira Code)
- Zero animations, zero clutter, pure content

📰 **100+ Curated Sources**
- Tech, business, science, design, sports
- One-click category filtering
- Real-time updates via SSE streaming

🎯 **Built for Focus**
- No ads, no tracking, no distractions
- Keyboard shortcuts for everything
- Terminal-aesthetic that reduces eye strain

🌍 **Global & Local**
- WorldMonitor theme: think like a hacker, read like a pro
- Mobile-optimized (safe-area-inset ready)
- PWA support for offline reading

## Tech Stack
- Next.js 15 + Tailwind CSS v3
- SSE streaming for real-time updates
- Deployed on Fly.io (67MB image)
- 100% open source

Perfect for developers, designers, and anyone tired of cluttered news sites.
```

### カテゴリー
- **Primary**: News & Media
- **Secondary**: Productivity, Design Tools

### トピックタグ
```
news, terminal, minimal design, developer tools, productivity, rss, aggregator, worldmonitor, dark theme, open source
```

### Gallery Assets必要

1. **Hero Screenshot** (1270x760px)
   - トップページ全体
   - ターミナル風デザインが映える

2. **Feature Screenshots** (1270x760px each)
   - カテゴリフィルタ機能
   - 記事詳細ページ
   - モバイルビュー

3. **Demo Video** (推奨30-60秒)
   - サイトを開く
   - カテゴリ切り替え
   - 記事を読む
   - キーボードショートカット使用

### 📸 スクリーンショット撮影スクリプト

```bash
#!/bin/bash
# screenshot.sh - Automated screenshot capture

# 1. Desktop Hero (1270x760)
open -a "Google Chrome" --args --window-size=1270,760 https://news.xyz
sleep 3
screencapture -l$(osascript -e 'tell app "Google Chrome" to id of window 1') ~/Downloads/news-xyz-hero.png

# 2. Category View
# (Click Tech category, then capture)

# 3. Article Detail
# (Open an article, then capture)

# 4. Mobile View (375x812 - iPhone X)
open -a "Google Chrome" --args --window-size=375,812 https://news.xyz
sleep 3
screencapture -l$(osascript -e 'tell app "Google Chrome" to id of window 1') ~/Downloads/news-xyz-mobile.png
```

### 🎥 Demo Video Script (30秒)

```
[0-5s]  News.xyz logo fade in
        Text: "News, the terminal way"

[5-10s] Homepage scroll
        Voiceover: "100+ sources, zero clutter"

[10-15s] Category switching animation
         Voiceover: "Filter by topic instantly"

[15-20s] Article reading experience
         Voiceover: "Read in beautiful monospace"

[20-25s] Mobile view
         Voiceover: "Perfect on any device"

[25-30s] Logo + URL
         Text: "news.xyz - Try it free"
```

### 🗓️ Launch Checklist

#### 1週間前
- [ ] スクリーンショット撮影（4-5枚）
- [ ] Demo動画作成（30-60秒）
- [ ] Product Hunt Makerアカウント確認
- [ ] Hunter探し（フォロワー1000+推奨）

#### 3日前
- [ ] Product Huntに下書き作成
- [ ] Gallery assets全てアップロード
- [ ] Launch date設定（火-木曜推奨）
- [ ] Notifyボタンで事前登録促進

#### Launch Day（UTC 00:01）
- [ ] 公開ボタンクリック
- [ ] Twitter/LinkedIn/Reddit同時投稿
- [ ] コメント返信体制確保（24時間）
- [ ] Discord/Slackで告知

#### Launch Day中
- [ ] 30分ごとにコメントチェック
- [ ] 質問には5分以内に返信
- [ ] Upvoteをお願い（友人・コミュニティ）
- [ ] メディアにプレスリリース送信

### 📱 SNS同時投稿テンプレート

#### Twitter
```
🚀 Launching on Product Hunt today!

News.xyz - Read news like a hacker 👨‍💻

✅ 100+ sources
✅ Terminal aesthetics
✅ Zero ads, zero tracking
✅ Built with WorldMonitor design

Vote & feedback welcome! 🙏
https://producthunt.com/posts/news-xyz

#ProductHunt #News #TerminalUI #MinimalDesign
```

#### LinkedIn
```
Excited to launch News.xyz on Product Hunt today! 🚀

After months of development, we're bringing back clean, focused news reading with a beautiful terminal interface.

What makes it special:
• 100+ curated news sources
• WorldMonitor extreme minimal design
• Zero ads, zero tracking, pure content
• Built for developers and designers

Would love your feedback and support!
→ https://producthunt.com/posts/news-xyz

#ProductLaunch #NewsAggregator #MinimalDesign #DeveloperTools
```

### 🎯 目標KPI

- **Day 1**: Top 5 in Tech category
- **Upvotes**: 200+
- **Comments**: 50+
- **Traffic**: 5,000+ visits
- **Signups**: 500+

### 🔗 必要リンク

- Product Hunt: (提出後に生成)
- Website: https://news.xyz
- Twitter: (準備中)
- GitHub: (準備中 - オープンソース化推奨)

### ⚠️ 注意事項

1. **時間**: UTC 00:01に公開（日本時間 09:01）
2. **Voting**: 自分でupvoteしない（Hunterに依頼）
3. **Engagement**: 最初の6時間が最重要
4. **Authenticity**: 誠実に、スパムしない
5. **Community**: Discord/Slack告知は事前許可を得る

---

## 実行コマンド

```bash
# スクリーンショット撮影
./screenshot.sh

# 動画作成
# QuickTime Player → 新規画面収録 → news.xyz操作

# アップロード
# Product Hunt管理画面からGalleryにアップロード

# Launch!
# Product Huntで"Publish"ボタンクリック
```

準備完了！成功を祈ります 🚀
