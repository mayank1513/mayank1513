#!/bin/bash

fetch_packages() {
    local user=$1
    local response=$(curl -s "https://registry.npmjs.org/-/v1/search?text=maintainer:$user&size=100")
    [ $? -ne 0 ] && exit 1
    echo "$response" | jq -r '.objects[].package.name'
}

fetch_download_count() {
    local package=$1
    local response=$(curl -s "https://api.npmjs.org/downloads/point/1970-01-01:3024-12-31/$(jq -rn --arg value "$package" '$value | @uri')")

    [ $? -ne 0 ] && exit 1

    local count=$(echo "$response" | jq -r '.downloads')
    [ "$count" == "null" ] && count=0
    echo "$count"
}

user="mayank1513"
packages=$(fetch_packages "$user")

if [ -z "$packages" ]; then
    echo "No packages found for user $user"
else
    total_downloads=0
    package_count=$(echo "$packages" | wc -l)
    counter=1
    while [ $counter -le $package_count ]; do
        package=$(echo "$packages" | sed -n "${counter}p")
        download_count=$(fetch_download_count "$package")
        total_downloads=$((total_downloads + download_count))
        echo "Download count for $package: $download_count"
        counter=$((counter + 1))
    done

    echo "Total downloads for packages published by $user: $total_downloads"
fi
