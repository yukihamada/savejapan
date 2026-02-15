#!/bin/bash
# SaveJapan DNS Setup Script for Cloudflare → Fly.io
#
# 使い方:
# 1. Cloudflareダッシュボード → My Profile → API Tokens → Create Token
#    「Edit zone DNS」テンプレートを使い、対象ゾーンを全て選択
# 2. 生成されたトークンを以下に設定:
#    export CF_API_TOKEN="your-token-here"
# 3. このスクリプトを実行:
#    bash setup-dns.sh

set -e

if [ -z "$CF_API_TOKEN" ]; then
  echo "❌ CF_API_TOKEN が設定されていません"
  echo ""
  echo "設定方法:"
  echo "  1. https://dash.cloudflare.com/profile/api-tokens にアクセス"
  echo "  2. 「Create Token」→「Edit zone DNS」テンプレートを選択"
  echo "  3. Zone Resources: Include → All zones"
  echo "  4. トークンを作成してコピー"
  echo "  5. export CF_API_TOKEN=\"your-token-here\""
  echo "  6. bash setup-dns.sh"
  exit 1
fi

API="https://api.cloudflare.com/client/v4"
AUTH="Authorization: Bearer $CF_API_TOKEN"

# ドメインとFly.io IPのマッピング
declare -A ZONES
declare -A IPV4
declare -A IPV6
declare -A ACME

ZONES[chatnews.tech]="e6e0ca1353e9488a10e71aa325623d05"
ZONES[enabler.cc]="f415aa817794ac69ea08b913c5b46772"
ZONES[dojoc.io]="e32e73bf4aa5ae02735037d2ee427117"
ZONES[enablerdao.com]="c63f1e5185b2dc0dad887ead6b1d71ce"

IPV4[chatnews.tech]="66.241.125.200"
IPV4[enabler.cc]="66.241.124.161"
IPV4[dojoc.io]="66.241.124.178"
IPV4[enablerdao.com]="66.241.124.232"

IPV6[chatnews.tech]="2a09:8280:1::d2:d58f:0"
IPV6[enabler.cc]="2a09:8280:1::d2:d58a:0"
IPV6[dojoc.io]="2a09:8280:1::d2:d591:0"
IPV6[enablerdao.com]="2a09:8280:1::d2:d500:0"

ACME[chatnews.tech]="chatnews.tech.o2zj6o3.flydns.net"
ACME[enabler.cc]="enabler.cc.9lredkg.flydns.net"
ACME[dojoc.io]="dojoc.io.l2rx6p2.flydns.net"
ACME[enablerdao.com]="enablerdao.com.pnpj6ll.flydns.net"

# 既存レコード削除用関数
delete_records() {
  local zone_id=$1
  local name=$2
  local type=$3

  local records=$(curl -s -X GET "$API/zones/$zone_id/dns_records?name=$name&type=$type" \
    -H "$AUTH" -H "Content-Type: application/json")

  local ids=$(echo "$records" | python3 -c "
import json, sys
data = json.load(sys.stdin)
if data.get('success') and data.get('result'):
    for r in data['result']:
        print(r['id'])
" 2>/dev/null)

  for id in $ids; do
    curl -s -X DELETE "$API/zones/$zone_id/dns_records/$id" \
      -H "$AUTH" -H "Content-Type: application/json" > /dev/null
    echo "  🗑  削除: $type $name (id: ${id:0:8}...)"
  done
}

# DNS設定関数
setup_domain() {
  local domain=$1
  local zone_id=${ZONES[$domain]}
  local ipv4=${IPV4[$domain]}
  local ipv6=${IPV6[$domain]}
  local acme=${ACME[$domain]}

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🌐 $domain の設定"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # 既存のA/AAAA/CNAMEレコードを削除
  echo "既存レコードを削除中..."
  delete_records "$zone_id" "$domain" "A"
  delete_records "$zone_id" "$domain" "AAAA"
  delete_records "$zone_id" "$domain" "CNAME"
  delete_records "$zone_id" "_acme-challenge.$domain" "CNAME"

  # Aレコード追加 (proxy OFF for Fly.io TLS)
  echo "Aレコードを追加中..."
  curl -s -X POST "$API/zones/$zone_id/dns_records" \
    -H "$AUTH" -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"@\",\"content\":\"$ipv4\",\"ttl\":1,\"proxied\":false}" | \
    python3 -c "import json,sys; d=json.load(sys.stdin); print('  ✅ A → $ipv4' if d.get('success') else f'  ❌ {d}')"

  # AAAAレコード追加
  echo "AAAAレコードを追加中..."
  curl -s -X POST "$API/zones/$zone_id/dns_records" \
    -H "$AUTH" -H "Content-Type: application/json" \
    --data "{\"type\":\"AAAA\",\"name\":\"@\",\"content\":\"$ipv6\",\"ttl\":1,\"proxied\":false}" | \
    python3 -c "import json,sys; d=json.load(sys.stdin); print('  ✅ AAAA → $ipv6' if d.get('success') else f'  ❌ {d}')"

  # ACME Challenge CNAME
  echo "ACME Challengeレコードを追加中..."
  curl -s -X POST "$API/zones/$zone_id/dns_records" \
    -H "$AUTH" -H "Content-Type: application/json" \
    --data "{\"type\":\"CNAME\",\"name\":\"_acme-challenge\",\"content\":\"$acme\",\"ttl\":1,\"proxied\":false}" | \
    python3 -c "import json,sys; d=json.load(sys.stdin); print('  ✅ CNAME _acme-challenge → $acme' if d.get('success') else f'  ❌ {d}')"

  echo "✅ $domain 完了"
}

echo "🚀 SaveJapan DNS設定スクリプト"
echo "Cloudflare DNS → Fly.io に切り替えます"

# 全ドメイン設定
for domain in chatnews.tech enabler.cc dojoc.io enablerdao.com; do
  setup_domain "$domain"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 全ドメインの設定が完了しました！"
echo ""
echo "SSL証明書の確認:"
echo "  flyctl certs check chatnews.tech -a savejapan-scanner"
echo "  flyctl certs check enabler.cc -a savejapan-phishing"
echo "  flyctl certs check dojoc.io -a savejapan-education"
echo "  flyctl certs check enablerdao.com -a enablerdao"
echo ""
echo "証明書の発行には数分かかる場合があります。"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
