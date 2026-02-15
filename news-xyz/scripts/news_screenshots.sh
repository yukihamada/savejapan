#!/bin/bash
# News.xyz Automated Screenshot Script using Playwright

set -e

echo "🎬 News.xyz Screenshot Automation Starting..."
echo "=============================================="

# Configuration
PROJECT_DIR="/Users/yuki/workspace/savejapan/news-xyz"
OUTPUT_DIR="$PROJECT_DIR/screenshots"
BASE_URL="https://news.xyz"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo ""
echo "📦 Step 1: Installing dependencies..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js first."
    exit 1
fi

cd "$PROJECT_DIR"

if [ ! -d "node_modules" ]; then
    echo "Installing npm packages..."
    npm install
fi

if [ ! -d "node_modules/playwright" ]; then
    echo "Installing Playwright..."
    npm install -D playwright
    npx playwright install chromium
fi

echo ""
echo "🚀 Step 2: Creating Playwright screenshot script..."

cat > "$PROJECT_DIR/scripts/capture.js" << 'PLAYWRIGHT_SCRIPT'
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext({
    viewport: { width: 1270, height: 760 }
  });
  const page = await context.newPage();

  console.log('📸 Taking screenshots...');

  // Screenshot 1: Hero Homepage
  console.log('  1/5: Hero Homepage');
  await page.goto('https://news.xyz', { waitUntil: 'networkidle' });
  await page.waitForTimeout(2000);
  await page.screenshot({ path: 'screenshots/01-hero-homepage.png' });

  // Screenshot 2: Category Filtering (Tech)
  console.log('  2/5: Category Filtering');
  await page.click('text=Tech');
  await page.waitForTimeout(1000);
  await page.screenshot({ path: 'screenshots/02-category-tech.png' });

  // Screenshot 3: Article Detail
  console.log('  3/5: Article Detail');
  const firstArticle = await page.locator('article a').first();
  await firstArticle.click();
  await page.waitForTimeout(2000);
  await page.screenshot({ path: 'screenshots/03-article-detail.png' });

  // Screenshot 4: Mobile View
  console.log('  4/5: Mobile View');
  await page.setViewportSize({ width: 375, height: 812 });
  await page.goto('https://news.xyz');
  await page.waitForTimeout(1000);
  await page.screenshot({ path: 'screenshots/04-mobile-view.png' });

  // Screenshot 5: Terminal Aesthetics Showcase
  console.log('  5/5: Terminal Aesthetics');
  await page.setViewportSize({ width: 1270, height: 760 });
  await page.goto('https://news.xyz');
  await page.waitForTimeout(1000);
  // Scroll to show multiple articles
  await page.evaluate(() => window.scrollBy(0, 400));
  await page.waitForTimeout(500);
  await page.screenshot({ path: 'screenshots/05-terminal-aesthetics.png' });

  console.log('✅ Screenshot capture complete!');
  await browser.close();
})();
PLAYWRIGHT_SCRIPT

echo ""
echo "📸 Step 3: Capturing screenshots..."
node "$PROJECT_DIR/scripts/capture.js"

echo ""
echo "✅ Screenshot automation complete!"
echo "📂 Output directory: $OUTPUT_DIR"
echo ""
echo "📋 Screenshots captured:"
ls -lh "$OUTPUT_DIR"
echo ""
echo "📋 Next Steps:"
echo "  1. Review screenshots in $OUTPUT_DIR"
echo "  2. Edit in Figma if needed (add captions)"
echo "  3. Optimize with TinyPNG: https://tinypng.com"
echo "  4. Upload to Product Hunt (1270x760px format ready)"
echo ""
echo "🎨 Figma Template: Create 1270x760px frames"
echo "📖 Full Guide: $PROJECT_DIR/../SCREENSHOT_CAPTURE_GUIDE.md"
