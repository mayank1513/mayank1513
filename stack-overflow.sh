#!/bin/bash

# Fetch rank HTML 9640177
user=9640177
rank=$(curl -s "https://stackoverflow.com/users/rank?userId=$user" | \
       grep -oP "(?<=\"_blank\">).*?(?=</a>)" | sed "s/<b>//" | sed "s/<\/b>//" ) # Replace <some-selector> with appropriate HTML tag or class

echo "rank: $rank"

# Fetch user data JSON
user_data=$(curl -s "https://api.stackexchange.com/2.2/users/$user?site=stackoverflow&filter=!--1nZv)deGu1")

# Parse JSON data using jq
name=$(echo "$user_data" | jq -r '.items[0].display_name')
reputation=$(echo "$user_data" | jq -r '.items[0].reputation')
gold=$(echo "$user_data" | jq -r '.items[0].badge_counts.gold')
silver=$(echo "$user_data" | jq -r '.items[0].badge_counts.silver')
bronze=$(echo "$user_data" | jq -r '.items[0].badge_counts.bronze')

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

