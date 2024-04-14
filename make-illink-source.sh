#!/bin/bash

# Define package names and output JSON file
packages=("microsoft.net.illink" "microsoft.net.illink.tasks" "microsoft.net.illink.analyzers")
output_json="sources/illink-sources.json"
temp_folder="packages-temp"
package_folder="nuget-sources"

# Create a directory to store the downloaded NuGet packages
mkdir -p $temp_folder

# Prepare the JSON file
echo "[" > $output_json

# Helper function to fetch the latest package version using NuGet API
function get_latest_version {
    curl -s "https://api.nuget.org/v3-flatcontainer/$1/index.json" | jq -r '.versions[-1]'
}

# Loop through each package
for pkg in "${packages[@]}"; do
    # Get the latest version of the package
    version=$(get_latest_version $pkg)
    
    # Build the package URL
    url="https://api.nuget.org/v3-flatcontainer/$pkg/$version/$pkg.$version.nupkg"

    # Download the package
    curl -s -o "$temp_folder/$pkg.$version.nupkg" $url

    # Calculate SHA512 hash
    sha512=$(sha512sum "$temp_folder/$pkg.$version.nupkg" | awk '{print $1}')

    # Append the package information to the JSON file
    echo "    {" >> $output_json
    echo "        \"type\": \"file\"," >> $output_json
    echo "        \"url\": \"$url\"," >> $output_json
    echo "        \"sha512\": \"$sha512\"," >> $output_json
    echo "        \"dest\": \"$package_folder\"," >> $output_json
    echo "        \"dest-filename\": \"$pkg.$version.nupkg\"" >> $output_json
    echo "    }," >> $output_json
done

# Remove the last comma and close the JSON array
sed -i '$ s/,$//' $output_json
echo "]" >> $output_json

echo "JSON file created: $output_json"

# Clean up: remove the temporary folder and all its contents
rm -rf $temp_folder
echo "Temporary files cleaned up."

