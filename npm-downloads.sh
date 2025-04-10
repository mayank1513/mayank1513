#!/bin/bash

fetch_packages() {
    local user=$1
    local response=$(curl -s -H "Authorization:Bearer $NPM_TOKEN" "https://registry.npmjs.org/-/v1/search?text=maintainer:$user&size=100")
    [ $? -ne 0 ] && exit 1
    echo "$response" | jq -r '.objects[].package.name'
}

fetch_download_count() {
    local package=$1
    local response=$(curl -s -H "Authorization:Bearer $NPM_TOKEN" "https://api.npmjs.org/downloads/point/1970-01-01:3024-12-31/$(jq -rn --arg value "$package" '$value | @uri')")

    [ $? -ne 0 ] && exit 1

    local count=$(echo "$response" | jq -r '.downloads')
    [ "$count" == "null" ] && count=0
    echo "$count"
}

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

user="mayank1513"
packages=$(fetch_packages "$user")

if [ -z "$packages" ]; then
    echo "No packages found for user $user"
else
    total_downloads=0
    for package in $packages; do
        download_count=$(fetch_download_count "$package")
        total_downloads=$((total_downloads + download_count))
        echo "Download count for package $package: $download_count"
        sleep .2
    done

    formated_downloads=$(format_number $total_downloads)
    echo "Total downloads for packages published by $user: $total_downloads ~ $formated_downloads"
    echo "<svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' width='129' height='20' aria-label='downloads: $formated_downloads'><linearGradient id='b' x2='0' y2='100%'><stop offset='0' stop-color='#bbb' stop-opacity='.1'/><stop offset='1' stop-opacity='.1'/></linearGradient><clipPath id='a'><rect width='129' height='20' fill='#fff' rx='3'/></clipPath><g clip-path='url(#a)'><path fill='#555' d='M0 0h86v20H0z'/><path fill='#4c1' d='M86 0h67v20H86z'/><path fill='url(#b)' d='M0 0h129v20H0z'/></g><g fill='#fff' font-family='Verdana,Geneva,DejaVu Sans,sans-serif' font-size='110' text-anchor='middle' text-rendering='geometricPrecision'><image xlink:href='data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA0MCA0MCI+PHBhdGggZD0iTTAgMGg0MHY0MEgwVjB6IiBmaWxsPSIjY2IwMDAwIi8+PHBhdGggZmlsbD0iI2ZmZiIgZD0iTTcgN2gyNnYyNmgtN1YxNGgtNnYxOUg3eiIvPjwvc3ZnPg==' width='14' height='14' x='5' y='3'/><text x='525' y='150' fill='#010101' fill-opacity='.3' aria-hidden='true' textLength='590' transform='scale(.1)'>downloads</text><text x='525' y='140' textLength='590' transform='scale(.1)'>downloads</text><text x='978' y='142' fill='#010101' fill-opacity='.3' aria-hidden='true' transform='scale(.11)'>$formated_downloads</text><text x='968' y='135' transform='scale(.11)'>$formated_downloads</text></g></svg>" > .badges/npm-downloads.svg
fi
