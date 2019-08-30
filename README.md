# GitHub Pull Request

A GitHub Action for creating pull requests. 


## Features
 * Create pull requests
 * Add reviewers, assignees, labels, or milestones
 * Customize pull request title and body
 * Fail silently when a pull request already exists


## Usage

### GitHub Actions
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
    - name: pull-request
      uses: repo-sync/pull-request@v2
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
```

This will automatically create a pull request from `feature-1` to `master`.


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
      uses: repo-sync/pull-request@v2
      with:
        source_branch: ""                     # If blank, default: triggered branch
        destination_branch: "master"          # If blank, default: master
        pr_title: "Pulling ${{ github.ref }} into master"
        pr_body: ":crown: *An automated PR*"  # Full markdown support
        pr_reviewer: "wei,worker"             # Comma-separated list (no spaces)
        pr_assignee: "wei,worker"             # Comma-separated list (no spaces)
        pr_label: "auto-pr"                   # Comma-separated list (no spaces)
        pr_milestone: "Milestone 1"           # Milestone name
        github_token: ${{ secrets.GITHUB_TOKEN }}
```
