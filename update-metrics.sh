#!/bin/bash
set -Eeuo pipefail

# =========================
# CONFIG
# =========================
NPM_USER="mayank1513"
SO_USER_ID="9640177"
NPM_TOKEN="${NPM_TOKEN:-}"
BADGE_DIR=".badges"
METRICS_FILE="$BADGE_DIR/metrics.json"
PARALLEL_JOBS=6

# =========================
# VALIDATION
# =========================
command -v curl jq xargs awk sed grep expr >/dev/null || exit 2
[ -z "$NPM_TOKEN" ] && { echo "Missing NPM_TOKEN"; exit 2; }
mkdir -p "$BADGE_DIR"

# =========================
# UTILS
# =========================
format_number() {
  local number=$1 suffixes=("" "k" "M" "G" "T") index=0
  while awk "BEGIN {exit !($number >= 1000)}"; do
    number=$(awk "BEGIN {printf \"%.2f\", $number / 1000}")
    ((index++))
  done
  printf "%.1f%s\n" "$number" "${suffixes[index]}"
}

# =========================
# NPM
# =========================
fetch_packages() {
  curl -s -H "Authorization:Bearer $NPM_TOKEN" \
    "https://registry.npmjs.org/-/v1/search?text=maintainer:$NPM_USER&size=250" |
    jq -r '.objects[].package.name'
}

fetch_download_count() {
  local pkg=$1
  curl -s "https://api.npmjs.org/downloads/point/1970-01-01:3024-12-31/$(jq -rn --arg v "$pkg" '$v|@uri')" |
    jq -r '.downloads // 0'
}

packages=$(fetch_packages)
npm_total=$(
  printf "%s\n" "$packages" |
    xargs -P "$PARALLEL_JOBS" -I{} bash -c 'fetch_download_count "$@"' _ {} |
    awk '{s+=$1} END{print s}'
)
npm_formatted=$(format_number "$npm_total")

# =========================
# STACK OVERFLOW
# =========================
rank=$(curl -s "https://stackoverflow.com/users/rank?userId=$SO_USER_ID" |
  grep -oP '(?<="_blank">).*?(?=</a>)' |
  sed 's/<b>//g;s/<\/b>//g')

user_data=$(curl -s "https://api.stackexchange.com/2.2/users/$SO_USER_ID?site=stackoverflow&filter=!--1nZv)deGu1")

name=$(jq -r '.items[0].display_name' <<<"$user_data")
reputation=$(jq -r '.items[0].reputation' <<<"$user_data")
gold=$(jq -r '.items[0].badge_counts.gold' <<<"$user_data")
silver=$(jq -r '.items[0].badge_counts.silver' <<<"$user_data")
bronze=$(jq -r '.items[0].badge_counts.bronze' <<<"$user_data")

rep_short=$(format_number "$reputation")

# =========================
# METRICS JSON
# =========================
jq -n \
  --arg npm "$npm_total" \
  --arg npm_fmt "$npm_formatted" \
  --arg rep "$reputation" \
  --arg rep_fmt "$rep_short" \
  --arg rank "$rank" \
  --arg gold "$gold" \
  --arg silver "$silver" \
  --arg bronze "$bronze" \
  '{
    npm: { total: ($npm|tonumber), formatted: $npm_fmt },
    stackoverflow: {
      reputation: ($rep|tonumber),
      formatted: $rep_fmt,
      rank: $rank,
      badges: { gold: ($gold|tonumber), silver: ($silver|tonumber), bronze: ($bronze|tonumber) }
    }
  }' > "$METRICS_FILE"

# =========================
# BADGES (NPM)
# =========================
cat <<EOF > "$BADGE_DIR/npm-downloads.svg"
<svg xmlns='http://www.w3.org/2000/svg' width='129' height='20'>
<text x='5' y='14'>downloads: $npm_formatted</text>
</svg>
EOF

# =========================
# BADGES (STACK OVERFLOW)
# =========================
themes=(
"#4A4E51 #2D2D2D #F2F2F3 .svg"
"#eff0f1 #fff #0f0f0f -light.svg"
)

for t in "${themes[@]}"; do
  read -r c1 c2 c3 f <<<"$t"

  cat <<EOF > "$BADGE_DIR/stack-overflow$f"
<svg width='280' height='80' viewBox='0 0 280 80' xmlns='http://www.w3.org/2000/svg'>
<rect stroke='$c1' fill='$c2' x='1' y='1' width='278' height='78' rx='5'/>
<text x='20' y='30' fill='$c3' font-size='16' font-weight='bold'>$name</text>
<text x='20' y='55' fill='$c3' font-size='14'>$rep_short ● $gold ● $silver ● $bronze — $rank</text>
</svg>
EOF

  cat <<EOF > "$BADGE_DIR/stack-overflow-small$f"
<svg width='200' height='48' viewBox='0 0 200 48' xmlns='http://www.w3.org/2000/svg'>
<rect stroke='$c1' fill='$c2' x='1' y='1' width='198' height='46' rx='5'/>
<text x='12' y='32' fill='$c3' font-size='18' font-weight='bold'>$rep_short</text>
</svg>
EOF
done

echo "✅ Metrics + badges generated."
