# Github Pull Request

A GitHub Action for creating pull requests. 


## Features
 * Create pull requests
 * Add reviewers, assignees, labels, or milestones
 * Customize pull request title and message
 * Fails silently when a pull request already exists


## Usage

### Github Actions
```
# File: .github/workflows/pull-request.yml

on:
  push:
    branches:
    - feature-1

jobs:
  pull-request:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: repo-sync
      uses: wei/pull-request@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        DESTINATION_BRANCH: "master"
```


## Advanced options
```
on:
  push:
    branches:
    - "feature/*"  # Support wildcard matching

jobs:
  pull-request:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: pull-request
      uses: wei/pull-request@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        DESTINATION_BRANCH: "master"
        SOURCE_BRANCH: ""                     # If blank, default: triggered branch
        PR_TITLE: "Pulling ${{ github.ref }} into master"
        PR_BODY: ":crown: *An automated PR*"  # Full markdown support
        PR_REVIEWER: "wei,worker"             # Comma-separated list (no spaces)
        PR_ASSIGNEE: "wei,worker"             # Comma-separated list (no spaces)
        PR_LABEL: "auto-pr"                   # Comma-separated list (no spaces)
        PR_MILESTONE: "Milestone 1"           # Milestone name
        HUB_VERBOSE: "1"                      # Enable hub logging
```


## Author
[Wei He](https://github.com/wei) _github@weispot.com_


## License
[MIT](https://wei.mit-license.org)
