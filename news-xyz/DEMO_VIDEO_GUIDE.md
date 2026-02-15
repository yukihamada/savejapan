# News.xyz Demo Video Complete Production Guide

## 概要

このガイドでは、Product Hunt、YouTube、Twitter用のnews.xyzデモ動画（30-60秒）の制作プロセスを完全に解説します。

## 動画スペック

- **長さ**: 30-60秒（Product Hunt推奨）
- **解像度**: 1920x1080 (Full HD) または 1280x720 (HD)
- **フレームレート**: 30fps または 60fps
- **フォーマット**: MP4 (H.264 codec)
- **アスペクト比**: 16:9 (横長) / 1:1 (Square for SNS) / 9:16 (縦長 for Stories)

---

## 1. 動画スクリプト（秒単位）

### 📱 30秒版（Product Hunt推奨）

```
[0-3秒] オープニング
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
画面: News.xyz ロゴ + "News, the terminal way"
効果: フェードイン
BGM: スタート（テクノ系/アンビエント）
ナレ: なし（テキストのみ）

[3-8秒] ホームページ全体表示
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
画面: トップページをゆっくりスクロール
     ターミナル風デザインを強調
効果: スムーズスクロール
ナレ: "100+ sources. Zero clutter. Pure content."
テキスト: "100+ CURATED NEWS SOURCES"

[8-13秒] カテゴリフィルタデモ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
画面: カテゴリボタンをクリック
     Tech → Business → Science と切り替え
効果: クリックにズーム強調
ナレ: "Filter by topic. Instantly."
テキスト: "ONE-CLICK FILTERING"

[13-18秒] 記事読み込みUX
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
画面: 記事をクリック → 詳細ページ表示
     美しいタイポグラフィ表示
効果: ページ遷移アニメーション
ナレ: "Read in beautiful monospace."
テキスト: "DISTRACTION-FREE READING"

[18-23秒] モバイルビュー
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
画面: iPhoneシミュレータまたは実機
     スクロール、タップ操作
効果: デバイスフレーム付き表示
ナレ: "Perfect on any device."
テキスト: "MOBILE-OPTIMIZED"

[23-28秒] キーボードショートカット
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
画面: キー押下を可視化（KeyCastr等）
     j/k で記事移動、Enter で開く
効果: キー表示オーバーレイ
ナレ: "Keyboard shortcuts for everything."
テキスト: "BUILT FOR POWER USERS"

[28-30秒] CTA（Call to Action）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
画面: News.xyz ロゴ + URL
効果: フェードイン
ナレ: "Try it free. news.xyz"
テキスト: "NEWS.XYZ - TRY IT FREE"
           "github.com/savejapan/news-xyz" (optional)
```

### 📱 60秒版（YouTube/詳細デモ用）

```
[0-5秒] オープニング
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
画面: アニメーション付きロゴ
     "Tired of cluttered news sites?"
効果: タイピングエフェクト（ターミナル風）
BGM: スタート

[5-15秒] 問題提起 → ソリューション
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
画面: 他の煩雑なニュースサイト（ぼかし）
     → News.xyzのクリーンな画面に切り替え
効果: ビフォー・アフター比較
ナレ: "Most news sites are bloated with ads and distractions.
       News.xyz brings back focus."
テキスト: "BEFORE → AFTER"

[15-25秒] 主要機能デモ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
画面: カテゴリフィルタ、記事読み込み、検索
効果: スプリットスクリーン（複数機能同時表示）
ナレ: "100+ curated sources. One-click filtering.
       Real-time updates via SSE streaming."

[25-35秒] デザイン哲学
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
画面: デザイン詳細（1px borders, monospace fonts）
     カラーパレット表示
効果: ズームイン・アウト
ナレ: "WorldMonitor-inspired terminal aesthetics.
       1px precision. Zero clutter."
テキスト: "EXTREME MINIMAL DESIGN"

[35-45秒] モバイル・PWA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
画面: iPhone、Android実機デモ
     ホーム画面追加（PWA）
効果: デバイス回転、スワイプ操作
ナレ: "Mobile-optimized. PWA support for offline reading."

[45-55秒] 技術スタック・オープンソース
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
画面: GitHub repo、コード一部表示
     Next.js, Tailwind CSS ロゴ
効果: コードエディタ風
ナレ: "Built with Next.js 15 and Tailwind CSS.
       100% open source on GitHub."
テキスト: "OPEN SOURCE"

[55-60秒] CTA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
画面: ロゴ + URL + Product Hunt badge
効果: パルスアニメーション
ナレ: "Read news like a hacker. news.xyz"
テキスト: "★ UPVOTE ON PRODUCT HUNT"
```

---

## 2. 撮影方法

### A. QuickTime Player（macOS）

最もシンプルな方法。画面収録のみで十分な場合に推奨。

```bash
# 1. QuickTime Playerを起動
open -a "QuickTime Player"

# 2. メニュー: ファイル → 新規画面収録
# 3. オプション:
#    - マイク: オン（ナレーション入れる場合）
#    - 品質: 高品質
#    - マウスクリックを表示: オン（推奨）

# 4. 収録範囲を選択
#    - フルスクリーン or 選択範囲（1920x1080推奨）

# 5. ブラウザでnews.xyzを開く（ウィンドウサイズ調整済み）
open -a "Google Chrome" --args --window-size=1920,1080 https://news.xyz

# 6. 収録開始 → スクリプト通りに操作 → 停止

# 7. ファイル保存
# ~/Movies/news-xyz-demo.mov
```

**QuickTimeのメリット:**
- macOS標準、追加ソフト不要
- シンプルで直感的
- 高画質収録（60fps対応）

**QuickTimeのデメリット:**
- オーバーレイ（テキスト、キー表示）は後から編集必要
- 複数音声トラック不可

---

### B. OBS Studio（全プラットフォーム）

プロフェッショナル品質。オーバーレイ、複数シーン管理が可能。

#### インストール

```bash
# macOS（Homebrew）
brew install --cask obs

# Windows
# https://obsproject.com/download からインストーラー

# Linux
sudo apt install obs-studio  # Debian/Ubuntu
```

#### OBS Studio設定

##### 1. プロジェクト設定

```
設定 → 出力
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
出力モード: 詳細
エンコーダ: Apple VT H264 Software Encoder (macOS)
          または NVIDIA NVENC H.264 (Windows/Linux)
レート制御: CRF
CRF: 18（高品質） または 23（標準）
キーフレーム間隔: 2秒
プリセット: Quality
プロファイル: high
```

```
設定 → 映像
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
基本解像度: 1920x1080
出力解像度: 1920x1080
縮小フィルタ: Lanczos
FPS: 30 または 60
```

```
設定 → 音声
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
サンプリングレート: 48kHz
チャンネル: ステレオ
デスクトップ音声: なし（BGMは編集時に追加）
マイク音声: 使用マイク（ナレーション用）
```

##### 2. シーン構成

```
シーン1: オープニング
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ソース:
  - 画像: news-xyz-logo.png (中央配置)
  - テキスト: "News, the terminal way"
           (フォント: SF Mono, 48px, #00ff00)

シーン2: デスクトップキャプチャ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ソース:
  - ウィンドウキャプチャ: Google Chrome
  - テキストオーバーレイ: "100+ CURATED SOURCES"
                        (左上、32px、フェードイン)

シーン3: モバイルビュー
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ソース:
  - ウィンドウキャプチャ: Chromeデベロッパーツール（モバイル表示）
  - 画像: iphone-frame.png（デバイスフレーム）

シーン4: CTA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ソース:
  - 画像: news-xyz-logo.png
  - テキスト: "NEWS.XYZ - TRY IT FREE"
  - テキスト: "github.com/savejapan/news-xyz"
```

##### 3. トランジション設定

```
シーン切り替え効果: フェード
継続時間: 300ms
```

##### 4. 収録開始

```
1. シーン1を選択 → 収録開始
2. 3秒待機
3. シーン2に切り替え → ブラウザ操作
4. スクリプトに沿って各シーンを切り替え
5. シーン4で終了 → 収録停止
```

**OBSのメリット:**
- プロフェッショナル品質
- リアルタイムオーバーレイ
- 複数シーン管理
- 無料・オープンソース

**OBSのデメリット:**
- 初期設定が複雑
- CPUリソース消費大

---

### C. キーボード表示ツール（オプション）

キーボードショートカットを可視化する場合。

```bash
# macOS: KeyCastr
brew install --cask keycastr

# 設定:
# - フォント: SF Mono, 24px
# - 表示時間: 2秒
# - 位置: 画面下部中央

# Windows: Carnac
# https://github.com/Code52/carnac

# Linux: screenkey
sudo apt install screenkey
```

---

## 3. 編集ガイド

### A. iMovie（macOS初心者向け）

#### プロジェクト作成

```
1. iMovie起動 → 新規プロジェクト
2. ムービー → テーマなし
3. アスペクト比: 16:9
4. フレームレート: 30fps または 60fps
```

#### タイムライン構成

```
[トラック1: メインビデオ]
  - news-xyz-demo.mov（QuickTimeで収録した素材）

[トラック2: BGM]
  - background-music.mp3（後述の推奨BGM）
  - 音量: 20-30%に下げる

[トラック3: ナレーション]
  - voiceover.m4a（後述のナレーション台本で録音）
  - 音量: 100%

[トラック4: テキストオーバーレイ]
  - "100+ CURATED SOURCES"（5-8秒に表示）
  - "ONE-CLICK FILTERING"（8-13秒に表示）
  - etc.
```

#### テキストスタイル設定

```
フォント: Courier New または SF Mono
サイズ: 48px
カラー: #00ff00（ターミナル風グリーン）
背景: 半透明黒（rgba(0,0,0,0.7)）
位置: 画面下部中央
アニメーション: フェードイン/アウト
```

#### トランジション

```
推奨トランジション:
  - クロスディゾルブ（フェード）
  - 継続時間: 0.3秒

避けるべきトランジション:
  - ワイプ、キューブ、ページめくり（古臭い）
```

#### エフェクト

```
カラー補正:
  - 露出: +5%（画面を少し明るく）
  - 彩度: -10%（落ち着いた色調）
  - シャープネス: +10%（テキスト鮮明化）

スピード調整:
  - スクロールシーン: 80%（ゆっくり見せる）
  - クリック操作: 100%（リアルタイム）
  - トランジション: 120%（テンポよく）
```

#### 書き出し

```
ファイル → 共有 → ファイル

設定:
  - 解像度: 1080p
  - 品質: 高品質
  - 圧縮: 高速（H.264）
  - ファイル名: news-xyz-demo-30sec.mp4
```

---

### B. Final Cut Pro（macOS上級者向け）

#### プロジェクト設定

```
ファイル → 新規 → プロジェクト

設定:
  - 名前: News.xyz Demo
  - 解像度: 1920x1080 HD
  - レート: 30p または 60p
  - オーディオ: ステレオ
  - レンダリング: ProRes 422（編集用）
```

#### マルチカムワークフロー

```
1. 複数アングル（デスクトップ、モバイル）を同期
2. マルチカムクリップを作成
3. アングルビューアーで切り替えながら編集
```

#### カラーグレーディング

```
インスペクタ → カラー

調整:
  - コントラスト: +15
  - ハイライト: -5
  - シャドウ: +10
  - 彩度: -5
  - 色温度: -2（クールトーン）

LUT（オプション）:
  - Cinematic Look LUT
  - または News.xyz専用カラーパレット（#0a0a0a, #00ff00）
```

#### モーショングラフィックス

```
タイトル → 3Dテキスト

"NEWS.XYZ" ロゴアニメーション:
  - 開始: 回転（-90度） + 不透明度0%
  - 終了: 回転（0度） + 不透明度100%
  - 継続時間: 1秒
  - イージング: イーズアウト
```

#### 書き出し

```
ファイル → 共有 → Master File（ProRes）

Product Hunt用:
  - ファイル → 共有 → Apple Devices 1080p (H.264)
  - ビットレート: 15 Mbps

YouTube用:
  - ファイル → 共有 → YouTube & Facebook
  - 解像度: 1080p
  - ビットレート: 20 Mbps
```

---

### C. DaVinci Resolve（全プラットフォーム・無料）

#### インストール

```bash
# 公式サイトからダウンロード
https://www.blackmagicdesign.com/products/davinciresolve/

# 無料版で十分（制限: 4K以上の書き出しなし）
```

#### プロジェクト設定

```
File → Project Settings

Master Settings:
  - Timeline Resolution: 1920x1080 HD
  - Timeline Frame Rate: 30fps
  - Playback Frame Rate: 30fps
  - Optimized Media Format: ProRes 422 LT
```

#### 編集ワークフロー

```
1. Media Pool: 素材をインポート
2. Edit: タイムライン編集
3. Fusion: モーショングラフィックス（ロゴアニメーション）
4. Color: カラーグレーディング
5. Fairlight: オーディオミックス（BGM + ナレーション）
6. Deliver: 書き出し
```

#### カラーページ（プロ品質）

```
ノード構成:
  [ノード1] 露出補正
  [ノード2] コントラスト調整
  [ノード3] 彩度調整
  [ノード4] カラーマッチング（全シーン統一）
  [ノード5] ビネット効果（オプション）

数値例:
  - リフト（シャドウ）: +0.05
  - ガンマ（ミッドトーン）: +0.10
  - ゲイン（ハイライト）: -0.05
  - 彩度: 0.95（少し落とす）
```

#### 書き出し

```
Deliver → Custom

設定:
  - Format: MP4
  - Codec: H.264
  - Resolution: 1920x1080
  - Frame Rate: 30
  - Quality: Automatic (15-20 Mbps)
  - Audio: AAC, 192kbps

ファイル名: news-xyz-demo-final.mp4
```

---

## 4. 推奨BGM（著作権フリー）

### A. Product Hunt向け（テクノロジー系）

| 曲名 | アーティスト | ソース | ムード |
|------|------------|--------|--------|
| **Technology** | Corporate Music Zone | [Pixabay](https://pixabay.com/music/corporate-technology-143965/) | 先進的、クリーン |
| **Inspiring Technology** | AlexiAction | [Pixabay](https://pixabay.com/music/ambient-inspiring-technology-148942/) | アンビエント、集中 |
| **Minimal** | MusicParadise | [Chosic](https://www.chosic.com/free-music/minimal/) | ミニマル、エレクトロニック |
| **Cyber Dreams** | Ian Post | [Mixkit](https://mixkit.co/free-stock-music/tag/electronic/) | サイバーパンク、未来的 |
| **Terminal Beats** | Neutron | [Bensound](https://www.bensound.com/royalty-free-music/tech) | ターミナル風、ループ |

**推奨**: "Inspiring Technology" by AlexiAction
- テンポ: 120 BPM（ちょうどいいペース）
- 長さ: 2:30（編集でカット可能）
- ループ対応: はい
- 商用利用: OK（クレジット表記推奨）

### B. YouTube向け（エンゲージメント重視）

| 曲名 | アーティスト | ソース | ムード |
|------|------------|--------|--------|
| **Motivational** | Corporate Music Zone | [Pixabay](https://pixabay.com/music/corporate-motivational-143966/) | モチベーション向上 |
| **Upbeat Corporate** | ProductionHive | [Free To Use](https://freetouse.com/music/corporate) | ポジティブ、エネルギッシュ |
| **Tech House** | DreamHeaven | [Chosic](https://www.chosic.com/free-music/tech-house/) | ダンサブル、モダン |

### C. Twitter/SNS向け（短尺・インパクト重視）

| 曲名 | アーティスト | ソース | ムード |
|------|------------|--------|--------|
| **Trailer Intro** | FStudios | [Fesliyan Studios](https://www.fesliyanstudios.com/royalty-free-music/commercial-advertising-music) | ドラマティック、短尺 |
| **Epic Cinematic** | Lexin Music | [Pixabay](https://pixabay.com/music/cinematic/) | シネマティック、壮大 |

### ライセンス注意事項

```
✅ 商用利用OK（全て）
✅ YouTube Content ID: クリア（著作権主張なし）
✅ 改変OK: トリミング、ループ、ピッチ変更

⚠️ クレジット表記:
  - Product Hunt: 不要（動画内）
  - YouTube: 説明欄に記載推奨
    例: "Music: Inspiring Technology by AlexiAction (Pixabay)"
  - Twitter: 不要

🚫 禁止事項:
  - 楽曲の再配布
  - 楽曲単体での販売
  - クリエイター名の偽装
```

---

## 5. ナレーション台本

### 日本語版（30秒）

```
[0-3秒]
（無音 - テキストのみ）

[3-8秒]
「100以上のニュースソース、広告ゼロ、純粋なコンテンツ。」

[8-13秒]
「トピック別にフィルタリング、ワンクリックで。」

[13-18秒]
「美しいモノスペースフォントで読む。」

[18-23秒]
「どんなデバイスでも完璧に。」

[23-28秒]
「キーボードショートカットですべて操作。」

[28-30秒]
「無料で試せます。news.xyz」
```

**トーン**: 落ち着いた、プロフェッショナル、やや低音
**テンポ**: ゆっくり（1秒に3-4単語）
**アクセント**: 標準語、ビジネス的

---

### 英語版（30秒）

```
[0-3秒]
(Silent - text only)

[3-8秒]
"One hundred plus sources. Zero clutter. Pure content."

[8-13秒]
"Filter by topic. Instantly."

[13-18秒]
"Read in beautiful monospace."

[18-23秒]
"Perfect on any device."

[23-28秒]
"Keyboard shortcuts for everything."

[28-30秒]
"Try it free. news dot xyz."
```

**Tone**: Calm, professional, slightly deep voice
**Tempo**: Slow (3-4 words per second)
**Accent**: Neutral (General American or RP British)

---

### 英語版（60秒・詳細）

```
[0-5秒]
"Tired of cluttered news sites?"

[5-15秒]
"Most news sites are bloated with ads and distractions.
News dot xyz brings back focus."

[15-25秒]
"One hundred plus curated sources.
One-click filtering.
Real-time updates via S-S-E streaming."

[25-35秒]
"WorldMonitor-inspired terminal aesthetics.
One-pixel precision. Zero clutter."

[35-45秒]
"Mobile-optimized.
P-W-A support for offline reading."

[45-55秒]
"Built with Next dot J-S fifteen and Tailwind C-S-S.
One hundred percent open source on GitHub."

[55-60秒]
"Read news like a hacker.
news dot xyz."
```

---

### ナレーション録音方法

#### A. 自分で録音（無料）

```bash
# macOS: QuickTime Player
1. QuickTime Player起動
2. ファイル → 新規オーディオ収録
3. 録音品質: 高
4. マイク: 内蔵マイク or 外部マイク（Blue Yeti推奨）
5. 台本を読み上げる
6. 保存: narration.m4a

# ノイズ除去（Audacity）
brew install --cask audacity

1. narration.m4aを開く
2. エフェクト → ノイズ除去
3. 無音部分を選択 → ノイズプロファイル取得
4. 全体を選択 → ノイズ除去適用
5. エフェクト → コンプレッサー（音量均一化）
6. エフェクト → ノーマライズ（-1.0 dB）
7. 書き出し: narration-final.mp3
```

#### B. AI音声生成（有料・高品質）

```bash
# ElevenLabs（最高品質）
https://elevenlabs.io/

プラン: Starter ($5/月) - 30,000文字/月
音声: "Adam" (男性、プロフェッショナル)
      "Rachel" (女性、ニュースキャスター風)
設定: Stability=70%, Clarity=80%, Style=0%
出力: MP3, 44.1kHz

# Google Cloud Text-to-Speech（コスパ良）
pip install google-cloud-texttospeech

python:
from google.cloud import texttospeech

client = texttospeech.TextToSpeechClient()
text = "One hundred plus sources. Zero clutter."
synthesis_input = texttospeech.SynthesisInput(text=text)

voice = texttospeech.VoiceSelectionParams(
    language_code="en-US",
    name="en-US-Neural2-J",  # Male, professional
    ssml_gender=texttospeech.SsmlVoiceGender.MALE
)

audio_config = texttospeech.AudioConfig(
    audio_encoding=texttospeech.AudioEncoding.MP3,
    speaking_rate=0.9,  # Slightly slower
    pitch=-2.0  # Slightly deeper
)

response = client.synthesize_speech(
    input=synthesis_input, voice=voice, audio_config=audio_config
)

with open("narration.mp3", "wb") as out:
    out.write(response.audio_content)
```

---

## 6. アップロード仕様

### A. Product Hunt

```
動画要件:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ファイル形式: MP4, MOV, WebM
最大ファイルサイズ: 100MB
推奨サイズ: 10-30MB（読み込み速度のため）
推奨長さ: 30-60秒
解像度: 1280x720 (HD) 以上
アスペクト比: 16:9 推奨（1:1 also works）
自動再生: はい（ミュート状態）
ループ: はい
字幕: 推奨（ミュート視聴者向け）

アップロード手順:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Product Hunt管理画面 → Products → Your Product
2. Gallery → Upload Media
3. news-xyz-demo-30sec.mp4 をドラッグ&ドロップ
4. サムネイル: 自動生成 or カスタム（1270x760px）
5. キャプション: "Watch News.xyz in action - terminal-style news aggregator"
6. 順序: 1番目（最初に表示される）
```

**最適化コマンド（ファイルサイズ削減）:**

```bash
# FFmpegでファイルサイズ削減（品質維持）
ffmpeg -i news-xyz-demo-30sec.mp4 \
  -vcodec h264 \
  -crf 23 \
  -preset slow \
  -acodec aac \
  -b:a 128k \
  -movflags +faststart \
  news-xyz-demo-optimized.mp4

# 結果: 50-80% ファイルサイズ削減、品質劣化ほぼなし
```

---

### B. YouTube

```
動画要件:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ファイル形式: MP4, MOV
推奨解像度: 1920x1080 (Full HD)
アスペクト比: 16:9
フレームレート: 30fps or 60fps
ビットレート: 8-12 Mbps (1080p)
音声: AAC, 128-192kbps, 48kHz

アップロード情報:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
タイトル（100文字以内）:
"News.xyz - Terminal-Style News Aggregator | Product Hunt Launch 2026"

説明（5000文字以内）:
News.xyz is a minimal, terminal-inspired news aggregator with 100+ curated sources.

🎯 Features:
• 100+ news sources (tech, business, science, design)
• WorldMonitor extreme minimal design
• Zero ads, zero tracking, pure content
• Keyboard shortcuts for power users
• Mobile-optimized PWA

🔗 Links:
• Try it now: https://news.xyz
• Product Hunt: https://producthunt.com/posts/news-xyz
• GitHub: https://github.com/savejapan/news-xyz

🎵 Music:
Inspiring Technology by AlexiAction (Pixabay)

#NewsAggregator #TerminalUI #MinimalDesign #ProductHunt #OpenSource

タグ（500文字以内）:
news aggregator, terminal ui, minimal design, product hunt, worldmonitor, rss reader, developer tools, open source, nextjs, tailwind css

サムネイル（1280x720px）:
news-xyz-youtube-thumbnail.png
  - 大きな文字: "NEWS.XYZ"
  - サブテキスト: "Terminal-Style News"
  - 背景: #0a0a0a（ダーク）
  - アクセント: #00ff00（グリーン）

再生リスト:
"Product Launches 2026"

カテゴリ:
Science & Technology

字幕:
英語（自動生成） + 日本語（手動アップロード）
```

**サムネイル作成（Figma/Canva）:**

```
サイズ: 1280x720px

レイヤー構成:
  [背景] #0a0a0a（黒）
  [ボーダー] 1px #00ff00（緑、四辺）
  [ロゴ] news.xyz（中央、Courier New, 120px）
  [サブテキスト] "Terminal-Style News Aggregator"（下部、36px）
  [バッジ] "LIVE ON PRODUCT HUNT"（右上、赤背景）

書き出し: PNG, 72dpi, RGB
```

---

### C. Twitter（X）

```
動画要件:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
最大長: 2分20秒（140秒）
最大ファイルサイズ: 512MB
推奨サイズ: 5-15MB
解像度: 1280x720 (推奨) or 1920x1080
アスペクト比: 16:9（横長） or 1:1（正方形） or 9:16（縦長）
フレームレート: 30fps or 60fps
ビットレート: 5000 kbps以下推奨

最適化コマンド:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Twitter最適化（ファイルサイズ重視）
ffmpeg -i news-xyz-demo-30sec.mp4 \
  -vcodec h264 \
  -crf 28 \
  -maxrate 5000k \
  -bufsize 10000k \
  -vf scale=1280:720 \
  -acodec aac \
  -b:a 128k \
  -movflags +faststart \
  news-xyz-twitter.mp4

# 結果: ~5MB, 高品質維持

投稿テキスト（280文字制限）:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Launching News.xyz on Product Hunt today!

Terminal-style news aggregator:
✅ 100+ sources
✅ Zero ads
✅ Keyboard shortcuts
✅ Open source

Vote & feedback welcome! 👇
https://producthunt.com/posts/news-xyz

#ProductHunt #News #TerminalUI

（残り文字数: 18）

ハッシュタグ戦略:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
必須: #ProductHunt
推奨: #News #TerminalUI #MinimalDesign #DevTools
避ける: 5個以上（スパム扱い）
```

---

### D. Instagram Reels / TikTok

```
動画要件:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
アスペクト比: 9:16（縦長、必須）
解像度: 1080x1920
最大長: 90秒（Instagram）/ 10分（TikTok）
推奨長: 15-30秒
フレームレート: 30fps

縦長変換コマンド:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 16:9 → 9:16変換（上下に余白追加）
ffmpeg -i news-xyz-demo-30sec.mp4 \
  -vf "scale=1080:608,pad=1080:1920:0:656:black" \
  -c:a copy \
  news-xyz-vertical.mp4

# または、ズーム＆クロップ（余白なし）
ffmpeg -i news-xyz-demo-30sec.mp4 \
  -vf "scale=1920:-1,crop=1080:1920" \
  -c:a copy \
  news-xyz-vertical-crop.mp4

投稿キャプション:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
News reading for hackers 👨‍💻

100+ sources | Zero ads | Terminal aesthetic

Try it: news.xyz (link in bio)

#newsdotxyz #terminalnews #minimaldesign #devtools #producthunt #newsaggregator #codinglife #developerlife

（Instagramは30ハッシュタグまでOK、TikTokは5個推奨）
```

---

## 7. バリエーション一覧

```
news-xyz-demo-30sec.mp4
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
用途: Product Hunt（メイン）
長さ: 30秒
解像度: 1920x1080
アスペクト比: 16:9
ファイルサイズ: ~15MB
特徴: フルデモ、ナレーション付き

news-xyz-demo-60sec.mp4
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
用途: YouTube
長さ: 60秒
解像度: 1920x1080
アスペクト比: 16:9
ファイルサイズ: ~25MB
特徴: 詳細説明、技術スタック紹介

news-xyz-twitter.mp4
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
用途: Twitter/X
長さ: 30秒
解像度: 1280x720
アスペクト比: 16:9
ファイルサイズ: ~5MB
特徴: 軽量、モバイル最適化

news-xyz-square.mp4
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
用途: LinkedIn, Facebook
長さ: 30秒
解像度: 1080x1080
アスペクト比: 1:1（正方形）
ファイルサイズ: ~10MB
特徴: SNSフィード最適化

news-xyz-vertical.mp4
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
用途: Instagram Reels, TikTok, YouTube Shorts
長さ: 15-30秒
解像度: 1080x1920
アスペクト比: 9:16（縦長）
ファイルサイズ: ~8MB
特徴: モバイルファースト、短尺

news-xyz-teaser.mp4
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
用途: Pre-launch告知
長さ: 15秒
解像度: 1920x1080
アスペクト比: 16:9
ファイルサイズ: ~5MB
特徴: "Coming Soon"、期待感醸成
```

---

## 8. 制作チェックリスト

### 事前準備

- [ ] スクリプト最終確認（30秒版 & 60秒版）
- [ ] BGM選定・ダウンロード（Pixabay "Inspiring Technology"推奨）
- [ ] ナレーション録音 or AI音声生成
- [ ] news.xyz実サイト動作確認（デモ用データ準備）
- [ ] ブラウザウィンドウサイズ調整（1920x1080）
- [ ] KeyCastrインストール（キーボード表示用）

### 撮影

- [ ] QuickTime or OBS起動
- [ ] 画面解像度設定: 1920x1080
- [ ] フレームレート設定: 30fps
- [ ] マイク設定（ナレーション入れる場合）
- [ ] 収録テスト（5秒）→ 音質・画質確認
- [ ] 本番収録（スクリプト通り操作）
- [ ] 素材保存: news-xyz-raw.mov

### 編集

- [ ] iMovie/Final Cut Pro/DaVinci Resolveにインポート
- [ ] タイムライン構成（ビデオ + BGM + ナレーション）
- [ ] テキストオーバーレイ追加（6箇所）
- [ ] トランジション追加（フェード、0.3秒）
- [ ] カラー補正（露出+5%, 彩度-10%）
- [ ] オーディオミックス（BGM 20%, ナレーション 100%）
- [ ] エンディングCTA追加（"NEWS.XYZ - TRY IT FREE"）
- [ ] プレビュー再生（全体チェック）

### 書き出し

- [ ] 30秒版書き出し（Product Hunt用）
- [ ] 60秒版書き出し（YouTube用）
- [ ] Twitter版書き出し（最適化、5MB以下）
- [ ] 縦長版書き出し（Instagram Reels用）
- [ ] 正方形版書き出し（LinkedIn用）
- [ ] ファイルサイズ確認（全て規定内）
- [ ] 再生テスト（全バージョン）

### アップロード

- [ ] Product Huntにアップロード（30秒版）
- [ ] YouTubeにアップロード（60秒版 + サムネイル + 説明）
- [ ] Twitterに投稿（30秒版 + テキスト）
- [ ] LinkedInに投稿（正方形版）
- [ ] Instagram Reelsに投稿（縦長版）
- [ ] 各プラットフォームで再生確認
- [ ] エンゲージメント初期反応確認

---

## 9. トラブルシューティング

### 問題1: ファイルサイズが大きすぎる

```bash
解決策: FFmpegで再圧縮

# 品質を落とさずサイズ削減（CRF値調整）
ffmpeg -i input.mp4 \
  -vcodec h264 \
  -crf 28 \
  -preset slow \
  -acodec aac \
  -b:a 128k \
  output.mp4

# CRF値の目安:
# 18 = 高品質（大きいファイル）
# 23 = 標準品質（推奨）
# 28 = 軽量（Twitter用）
```

### 問題2: 音声が小さい

```bash
解決策: FFmpegで音量正規化

# 音量を2倍に増幅
ffmpeg -i input.mp4 -af "volume=2.0" output.mp4

# ノーマライズ（自動最適化）
ffmpeg -i input.mp4 -af "loudnorm" output.mp4
```

### 問題3: 動画がカクつく

```
原因: フレームレート不一致 or エンコード設定

解決策:
1. 元素材のフレームレートを確認
   ffmpeg -i input.mp4
   → "30 fps" or "60 fps" を確認

2. 編集ソフトのプロジェクト設定を素材に合わせる
   iMovie: プロジェクト設定 → フレームレート: 30fps

3. 書き出し時も同じフレームレートを指定
```

### 問題4: Product Huntで動画が再生されない

```
原因: ファイル形式 or コーデック非対応

解決策: H.264コーデックで再書き出し
ffmpeg -i input.mov \
  -vcodec h264 \
  -pix_fmt yuv420p \
  -movflags +faststart \
  output.mp4

# -pix_fmt yuv420p: 互換性最大化
# -movflags +faststart: ストリーミング最適化（重要！）
```

### 問題5: 字幕が読みにくい

```
解決策: テキストスタイル調整

フォントサイズ: 48px → 64px（大きく）
背景: 半透明黒 rgba(0,0,0,0.7) → rgba(0,0,0,0.9)（濃く）
縁取り: 2px白（視認性向上）
位置: 下部中央 → 下から20%（セーフエリア確保）
```

---

## 10. 参考資料・ツール

### 編集ソフト

| ツール | 価格 | プラットフォーム | 推奨用途 |
|--------|------|-----------------|----------|
| **iMovie** | 無料 | macOS, iOS | 初心者、シンプル編集 |
| **Final Cut Pro** | $299 | macOS | プロ品質、macユーザー |
| **DaVinci Resolve** | 無料（有料版$295） | macOS, Windows, Linux | プロ品質、カラーグレーディング |
| **Adobe Premiere Pro** | $20.99/月 | macOS, Windows | プロ品質、業界標準 |
| **Shotcut** | 無料 | macOS, Windows, Linux | 初心者、オープンソース |

### 画面収録

| ツール | 価格 | プラットフォーム | 特徴 |
|--------|------|-----------------|------|
| **QuickTime Player** | 無料 | macOS | シンプル、標準搭載 |
| **OBS Studio** | 無料 | macOS, Windows, Linux | プロ品質、ライブ配信対応 |
| **ScreenFlow** | $169 | macOS | 編集機能統合 |
| **Camtasia** | $299 | macOS, Windows | 教育向け、初心者フレンドリー |

### 音声編集

| ツール | 価格 | プラットフォーム | 特徴 |
|--------|------|-----------------|------|
| **Audacity** | 無料 | macOS, Windows, Linux | 基本編集、ノイズ除去 |
| **Adobe Audition** | $20.99/月 | macOS, Windows | プロ品質 |
| **Logic Pro** | $199 | macOS | 音楽制作統合 |

### AI音声生成

| サービス | 価格 | 品質 | 言語 |
|----------|------|------|------|
| **ElevenLabs** | $5-$99/月 | 最高 | 29言語（日本語含む） |
| **Google Cloud TTS** | $4/100万文字 | 高 | 40+言語 |
| **Amazon Polly** | $4/100万文字 | 中-高 | 30+言語 |
| **Azure TTS** | $4/100万文字 | 高 | 75+言語 |

### サムネイル作成

| ツール | 価格 | プラットフォーム | 特徴 |
|--------|------|-----------------|------|
| **Figma** | 無料（有料版$12/月） | Web | デザイナー向け、コラボレーション |
| **Canva** | 無料（Pro $12.99/月） | Web, iOS, Android | テンプレート豊富、初心者向け |
| **Photoshop** | $20.99/月 | macOS, Windows | プロ品質 |

---

## 11. 成功事例・参考動画

### Product Hunt Top製品のデモ動画分析

| 製品 | 動画長 | 特徴 | 効果 |
|------|--------|------|------|
| **Notion** | 45秒 | シンプル、UIフォーカス、無音 | Product of the Day |
| **Linear** | 30秒 | スピード感、キーボード操作強調 | 1000+ upvotes |
| **Raycast** | 60秒 | ターミナル風、開発者向け | Top 5 of the Month |
| **Arc Browser** | 40秒 | 問題提起→解決、感情的 | 5000+ upvotes |

**共通点:**
- 30-60秒（短尺）
- 最初の5秒でフック（問題提起 or インパクトあるビジュアル）
- 音声なしでも理解できる（字幕必須）
- CTA明確（"Try it free" etc.）
- プロダクトの"雰囲気"を伝える（単なる機能説明ではない）

---

## 12. 最終チェック

動画完成後、以下を確認:

```
✅ 技術品質
  - [ ] 解像度: 1920x1080以上
  - [ ] フレームレート: 30fps以上
  - [ ] 音声: クリア、ノイズなし
  - [ ] ファイルサイズ: 規定内（Product Hunt 100MB以下）
  - [ ] コーデック: H.264

✅ コンテンツ
  - [ ] スクリプト通りの流れ
  - [ ] 全機能デモ（カテゴリ、記事、モバイル、キーボード）
  - [ ] ブランド一貫性（ターミナル風デザイン）
  - [ ] CTA明確（"news.xyz"）

✅ UX
  - [ ] 音声なしでも理解できる（字幕）
  - [ ] 最初の5秒でフック
  - [ ] テンポよい（退屈させない）
  - [ ] エンディング満足感

✅ プラットフォーム対応
  - [ ] Product Hunt: 30秒版準備
  - [ ] YouTube: 60秒版 + サムネイル
  - [ ] Twitter: 最適化版（5MB以下）
  - [ ] Instagram/TikTok: 縦長版

✅ リーガル
  - [ ] BGMライセンス確認（商用利用OK）
  - [ ] フォントライセンス確認（SF Mono = Appleライセンス、商用制限あり → Courier New等に変更推奨）
  - [ ] ニュースコンテンツ権利確認（フェアユース範囲内）
```

---

## 次のステップ

1. **今すぐ撮影開始**: QuickTimeで30秒収録（1時間）
2. **iMovieで編集**: BGM + テキスト追加（2時間）
3. **Product Huntアップロード**: 管理画面で設定（30分）
4. **SNS同時投稿準備**: Twitter/LinkedIn/YouTube準備（1時間）

**総所要時間: 約4-5時間** (初回、慣れれば2-3時間)

---

## まとめ

このガイドに従えば、Product Hunt Top 5を狙える高品質デモ動画が完成します。

**成功のカギ:**
- **シンプル**: 30秒、機能詰め込みすぎない
- **明確**: 1つのメッセージ（"Terminal-style news"）
- **雰囲気**: ターミナル風デザインを動画でも表現
- **CTA**: "Try it free. news.xyz" を明確に

**推奨ワークフロー（初心者）:**
1. QuickTime Playerで画面収録（30分）
2. iMovieで編集（2時間）
3. Pixabay BGM追加（15分）
4. テキストオーバーレイ（30分）
5. 書き出し・アップロード（30分）

**推奨ワークフロー（上級者）:**
1. OBS Studioで収録（シーン事前設定）（1時間）
2. DaVinci Resolveで編集・カラグレ（2時間）
3. ElevenLabsでAIナレーション（15分）
4. 複数バリエーション書き出し（30分）
5. 全プラットフォームアップロード（1時間）

Good luck with your Product Hunt launch! 🚀

---

## Sources

本ガイドは以下のリソースを参考に作成しました:

- [Product Hunt Video: Types, Tips and Examples](https://zelios.agency/creating-product-lunch-video/)
- [10 Best Product Demo Videos, Examples & Ideas That Work (2026)](https://vidico.com/news/best-product-demo-video-examples/)
- [How to launch a developer tool on Product Hunt in 2026](https://hackmamba.io/developer-marketing/how-to-launch-on-product-hunt/)
- [Royalty Free Music Download - Pixabay](https://pixabay.com/music/)
- [Free Music for Creators | Free To Use](https://freetouse.com/music)
- [Background Music Free Download | Chosic](https://www.chosic.com/free-music/all/)
