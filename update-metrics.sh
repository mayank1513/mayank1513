#!/bin/bash

# Config
NPM_USER="mayank1513"
SO_USER=9640177

# Utils
format_number() {
    local number=$1
    local suffixes=("" "k" "M" "G" "T" "P" "E" "Z" "Y")
    local index=0

    while [ "$(awk "BEGIN {print ($number >= 1000)}")" -eq 1 ]; do
        number=$(awk "BEGIN {printf \"%.2f\", $number / 1000}")
        index=$((index + 1))
    done

    printf "%.1f%s\n" "$number" "${suffixes[index]}"
}

# Fetch rank HTML 9640177
rank=$(curl -s "https://stackoverflow.com/users/rank?userId=$SO_USER" | \
       grep -oP "(?<=\"_blank\">).*?(?=</a>)" | sed "s/<b>//" | sed "s/<\/b>//" ) # Replace <some-selector> with appropriate HTML tag or class

echo "rank: $rank"

# Fetch StackOverflow_USER data JSON
user_data=$(curl -s "https://api.stackexchange.com/2.2/users/$SO_USER?site=stackoverflow&filter=!--1nZv)deGu1")

# Parse JSON data using jq
name=$(echo "$user_data" | jq -r '.items[0].display_name')
reputation=$(echo "$user_data" | jq -r '.items[0].reputation')
gold=$(echo "$user_data" | jq -r '.items[0].badge_counts.gold')
silver=$(echo "$user_data" | jq -r '.items[0].badge_counts.silver')
bronze=$(echo "$user_data" | jq -r '.items[0].badge_counts.bronze')



hk=( "#4A4E51 #2D2D2D #F2F2F3 .svg" "#eff0f1 #fff #0f0f0f -light.svg")

for ks in "${hk[@]}"; do
  read -r c1 c2 c3 f <<< "$ks"
  
  h=80
  w=280

  echo "<svg width='250' height='80' viewBox='0 0 $w $h' xmlns='http://www.w3.org/2000/svg'><g fill='none' fill-rule='evenodd'><rect stroke='$c1' fill='$c2' x='.5' y='.5' width='$(expr $w - 1)' height='$(expr $h - 1)' rx='5' /><g transform='translate(60 3)'><text font-family='Arial-BoldMT, Arial' font-size='15' font-weight='bold' fill='$c3'><tspan x='12' y='23'>$name</tspan></text><text font-family='Arial-BoldMT, Arial' font-size='13' fill='$c3'><tspan x='12' font-size='15' font-weight='bold' y='43'>$(printf "%'.0f" $reputation)  </tspan><tspan fill='#0000' y='42'> - </tspan><tspan fill='#F1B600'> ● $gold </tspan><tspan fill='#9A9B9E'> ● $silver </tspan><tspan fill='#AB825F'> ● $bronze </tspan></text><g transform='translate(13, 52)'><svg aria-hidden='true' width='15' height='15' viewBox='0 0 18 18'><path d='M15 2V1H3v1H0v4c0 1.6 1.4 3 3 3v1c.4 1.5 3 2.6 5 3v2H5s-1 1.5-1 2h10c0-.4-1-2-1-2h-3v-2c2-.4 4.6-1.5 5-3V9c1.6-.2 3-1.4 3-3V2h-3ZM3 7c-.5 0-1-.5-1-1V4h1v3Zm8.4 2.5L9 8 6.6 9.4l1-2.7L5 5h3l1-2.7L10 5h2.8l-2.3 1.8 1 2.7h-.1ZM16 6c0 .5-.5 1-1 1V4h1v2Z' fill='#b9d7c3'></path></svg><text font-family='Arial-BoldMT, Arial' font-size='13' fill='$c3' x='20' y='12' font-style='italic'>$rank</text></g></g></g><g transform='translate($(expr -$w / 2 + 35) 15)'><svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 118' height='$(expr $h - 30)'><path fill='#BCBBBB' d='M84.072 107.351V75.8h10.516v42.069H0V75.8h10.516v31.551z'/><path fill='#F48024' d='m22.089 72.898 51.458 10.815 2.163-10.292-51.458-10.815-2.163 10.292zm6.808-24.639 47.666 22.199 4.44-9.533-47.666-22.199-4.44 9.533zm13.191-23.385 40.405 33.65 6.73-8.081-40.405-33.65-6.73 8.081zM68.171 0l-8.438 6.276 31.381 42.191 8.438-6.276L68.171 0zM21.044 96.833h52.582V86.316H21.044v10.517z'/></svg></g></svg>" > ".badges/stack-overflow$f"

  h=80
  w=320

  echo "<svg width='200' height='48' viewBox='0 0 $w $h' xmlns='http://www.w3.org/2000/svg'><g fill='none' fill-rule='evenodd'><rect stroke='$c1' fill='$c2' x='.5' y='.5' width='$(expr $w - 1)' height='$(expr $h - 1)' rx='5' /><g transform='translate(60 3)'><text font-family='Arial-BoldMT, Arial' font-size='17' fill='$c3'><tspan x='15' y='38' font-weight='bold' font-size='22'>$(format_number $reputation)  </tspan><tspan fill='#0000' y='37'> - </tspan><tspan fill='#F1B600'> ● $gold </tspan><tspan fill='#0000'>.</tspan><tspan fill='#9A9B9E'> ● $silver </tspan><tspan fill='#0000'>.</tspan><tspan fill='#AB825F'> ● $bronze </tspan></text><g transform='translate(16, 45)'><svg aria-hidden='true' width='15' height='15' viewBox='0 0 18 18'><path d='M15 2V1H3v1H0v4c0 1.6 1.4 3 3 3v1c.4 1.5 3 2.6 5 3v2H5s-1 1.5-1 2h10c0-.4-1-2-1-2h-3v-2c2-.4 4.6-1.5 5-3V9c1.6-.2 3-1.4 3-3V2h-3ZM3 7c-.5 0-1-.5-1-1V4h1v3Zm8.4 2.5L9 8 6.6 9.4l1-2.7L5 5h3l1-2.7L10 5h2.8l-2.3 1.8 1 2.7h-.1ZM16 6c0 .5-.5 1-1 1V4h1v2Z' fill='#b9d7c3'></path></svg><text font-family='Arial-BoldMT, Arial' font-size='13' fill='$c3' x='20' y='12' font-style='italic'>$rank</text></g></g></g><g transform='translate($(expr -$w / 2 + 35) 14)'><svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 118' height='$(expr $h - 30)'><path fill='#BCBBBB' d='M84.072 107.351V75.8h10.516v42.069H0V75.8h10.516v31.551z'/><path fill='#F48024' d='m22.089 72.898 51.458 10.815 2.163-10.292-51.458-10.815-2.163 10.292zm6.808-24.639 47.666 22.199 4.44-9.533-47.666-22.199-4.44 9.533zm13.191-23.385 40.405 33.65 6.73-8.081-40.405-33.65-6.73 8.081zM68.171 0l-8.438 6.276 31.381 42.191 8.438-6.276L68.171 0zM21.044 96.833h52.582V86.316H21.044v10.517z'/></svg></g></svg>" > ".badges/stack-overflow-small$f"
done

# NPM
fetch_packages() {
    local NPM_USER=$1
    local response=$(curl -s "https://registry.npmjs.org/-/v1/search?text=author:$NPM_USER&size=250")
    [ $? -ne 0 ] && exit 1
    # use jq to extract package name + downloads (fallback to 0)
    echo "$response" | jq -r '
      .objects[]
      | [
          .package.name,
          (.downloads.monthly // 0),
          (.downloads.weekly  // 0)
        ]
      | @tsv
    ' | tr "\t" " "
}

fetch_download_count() {
    local package=$1
    local response=$(curl -s -H "Authorization:Bearer $NPM_TOKEN" "https://api.npmjs.org/downloads/point/1970-01-01:3024-12-31/$package")

    [ $? -ne 0 ] && exit 1

    local count=$(echo "$response" | jq -r '.downloads')
    [ "$count" == "null" ] && count=0
    echo "$count"
}

monthly_total=0
weekly_total=0
total_downloads=0
count=0
failed_count=0

while IFS=' ' read -r package monthly weekly; do
  count=$((count + 1))
  monthly_total=$((monthly_total + monthly))
  weekly_total=$((weekly_total + weekly))
  download_count=$(fetch_download_count "$package")
  if (( download_count )); then
    total_downloads=$((total_downloads + download_count))
  elif (( download_count == 0 )); then
    failed_count=$((failed_count + 1))
  fi
  echo "Download count for package $package: $download_count, total: $total_downloads"
  sleep 0.25
  # pause a bit more every 10 packages
  if (( count % 10 == 0 )); then
    echo "Processed $count packages — taking a breather..."
    sleep 2.1
  fi
done < <(fetch_packages "$NPM_USER")

formated_downloads=$(format_number $total_downloads)
echo "Total downloads for packages published by $NPM_USER: $total_downloads ~ $formated_downloads"
echo "<svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' width='129' height='20' aria-label='downloads: $formated_downloads'><linearGradient id='b' x2='0' y2='100%'><stop offset='0' stop-color='#bbb' stop-opacity='.1'/><stop offset='1' stop-opacity='.1'/></linearGradient><clipPath id='a'><rect width='129' height='20' fill='#fff' rx='3'/></clipPath><g clip-path='url(#a)'><path fill='#555' d='M0 0h86v20H0z'/><path fill='#4c1' d='M86 0h67v20H86z'/><path fill='url(#b)' d='M0 0h129v20H0z'/></g><g fill='#fff' font-family='Verdana,Geneva,DejaVu Sans,sans-serif' font-size='110' text-anchor='middle' text-rendering='geometricPrecision'><image xlink:href='data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA0MCA0MCI+PHBhdGggZD0iTTAgMGg0MHY0MEgwVjB6IiBmaWxsPSIjY2IwMDAwIi8+PHBhdGggZmlsbD0iI2ZmZiIgZD0iTTcgN2gyNnYyNmgtN1YxNGgtNnYxOUg3eiIvPjwvc3ZnPg==' width='14' height='14' x='5' y='3'/><text x='525' y='150' fill='#010101' fill-opacity='.3' aria-hidden='true' textLength='590' transform='scale(.1)'>downloads</text><text x='525' y='140' textLength='590' transform='scale(.1)'>downloads</text><text x='978' y='142' fill='#010101' fill-opacity='.3' aria-hidden='true' transform='scale(.11)'>$formated_downloads</text><text x='968' y='135' transform='scale(.11)'>$formated_downloads</text></g></svg>" > .badges/npm-downloads.svg

printf "Processed %d packages\n" "$count"
printf "TOTAL monthly: %d\nTOTAL weekly: %d\n" "$monthly_total" "$weekly_total"

# GitHub Stats
get_gh_stars() {
  local target=$1
  local count
  # Fetch public repos, source only (no forks), sum stargazersCount
  count=$(gh repo list "$target" --limit 9999 --visibility public --source --json stargazersCount --jq 'map(.stargazersCount) | add' 2>/dev/null)
  echo "${count:-0}"
}

echo "Fetching GitHub stars..."
stars_mayank=$(get_gh_stars "mayank1513")
stars_md2docx=$(get_gh_stars "md2docx")
stars_react=$(get_gh_stars "react18-tools")
stars_total=$((stars_mayank + stars_md2docx + stars_react))

echo "GitHub Stars -> Total: $stars_total (mayank1513: $stars_mayank, md2docx: $stars_md2docx, react18-tools: $stars_react)"

# Metrics
jq -n \
  --arg npm "$total_downloads" \
  --arg npm_fmt "$formated_downloads" \
  --arg npm_failed "$failed_count" \
  --arg npm_monthly "$monthly_total" \
  --arg npm_monthly_fmt "$(format_number $monthly_total)" \
  --arg npm_weekly "$weekly_total" \
  --arg npm_weekly_fmt "$(format_number $weekly_total)" \
  --arg rep "$reputation" \
  --arg rep_fmt "$(format_number $reputation)" \
  --arg rank "$rank" \
  --arg gold "$gold" \
  --arg silver "$silver" \
  --arg bronze "$bronze" \
  --arg gh_total "$stars_total" \
  --arg gh_mayank "$stars_mayank" \
  --arg gh_md2docx "$stars_md2docx" \
  --arg gh_react "$stars_react" \
  '{
    npm: { 
      total: ($npm|tonumber), 
      formatted: $npm_fmt,
      failed: ($npm_failed|tonumber),
      monthly: ($npm_monthly|tonumber), 
      monthly_formatted: $npm_monthly_fmt,
      weekly: ($npm_weekly|tonumber), 
      weekly_formatted: $npm_weekly_fmt
    },
    stackoverflow: {
      reputation: ($rep|tonumber),
      formatted: $rep_fmt,
      rank: $rank,
      badges: { gold: ($gold|tonumber), silver: ($silver|tonumber), bronze: ($bronze|tonumber) }
    },
    github: {
      total: ($gh_total|tonumber),
      mayank1513: ($gh_mayank|tonumber),
      "react18-tools": ($gh_react|tonumber),
      md2docx: ($gh_md2docx|tonumber)
    }
  }' > "metrics.json"

echo "Failed to get count for $failed_count packages"
echo "Total downloads $formated_downloads"
