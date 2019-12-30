# GitHub Pull Request
[![All Contributors](https://img.shields.io/badge/all_contributors-2-orange.svg?style=flat-square)](#contributors)

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
    - uses: actions/checkout@v1
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
    - uses: actions/checkout@v1
    - name: pull-request
      uses: repo-sync/pull-request@v2
      with:
        source_branch: ""                     # If blank, default: triggered branch
        destination_branch: "master"          # If blank, default: master
        pr_title: "Pulling ${{ github.ref }} into master"
        pr_body: ":crown: *An automated PR*"  # Full markdown support, requires pr_title to be set
        pr_reviewer: "wei,worker"             # Comma-separated list (no spaces)
        pr_assignee: "wei,worker"             # Comma-separated list (no spaces)
        pr_label: "auto-pr"                   # Comma-separated list (no spaces)
        pr_milestone: "Milestone 1"           # Milestone name
        github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore -->
<table>
  <tr>
    <td align="center"><a href="https://whe.me"><img src="https://avatars3.githubusercontent.com/u/5880908?v=4" width="100px;" alt="Wei He"/><br /><sub><b>Wei He</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=wei" title="Code">💻</a> <a href="https://github.com/repo-sync/pull-request/commits?author=wei" title="Documentation">📖</a> <a href="#design-wei" title="Design">🎨</a> <a href="#ideas-wei" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="http://zeke.sikelianos.com"><img src="https://avatars1.githubusercontent.com/u/2289?v=4" width="100px;" alt="Zeke Sikelianos"/><br /><sub><b>Zeke Sikelianos</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=zeke" title="Documentation">📖</a> <a href="#ideas-zeke" title="Ideas, Planning, & Feedback">🤔</a></td>
  </tr>
</table>

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
