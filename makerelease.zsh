#!/bin/zsh

# Get the repository name (user/repo) from the Git remote URL
repo_url=$(git remote get-url origin)
repo_name=$(basename $repo_url .git)
user_name=$(echo $repo_url | sed -E 's/^git@github\.com:([^\/]+)\/.*/\1/')

# Get a list of existing tags
tags=$(git tag | sort -V | tail -n 3)

previous_tag=$(echo "$tags" | tail -n 3 | head -n 1)

# Loop through each tag and create a release
for tag in ${=tags}; do
  echo "Creating release for tag: $tag"
  
  # Check if the release already exists
  response=$(gh api \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$user_name/$repo_name/releases/tags/$tag)
  response=$(echo $response | jq -r ".message")
  if [[ "$response" != "Not Found" ]]; then
    echo "Release already exists for tag: $tag. Skipping..."
    previous_tag=$tag
    continue
  fi
  
  
  # Get the commit messages between the previous and current tags
  commit_messages=$(git log --pretty=format:"- %s" $previous_tag..$tag)
  
  # Create the release using GitHub CLI and use the commit messages as release notes
  gh release create $tag --title "Release $tag" --notes "$commit_messages"
  #echo $commit_messages
  
  # Set the previous tag for the next iteration
  previous_tag=$tag
done

