# GitHub Pull Request

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-12-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END --> 

A GitHub Action for creating pull requests. 


## Features
 * Create pull requests
 * Add reviewers, assignees, labels, or milestones
 * Customize pull request title and body
 * Fail silently when a pull request already exists


## Usage

### GitHub Actions
```yaml
# File: .github/workflows/pull-request.yml

on:
  push:
    branches:
    - feature-1

jobs:
  pull-request:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: pull-request
      uses: repo-sync/pull-request@v2
      with:
        destination_branch: "main"
        github_token: ${{ secrets.GITHUB_TOKEN }}
```

This will automatically create a pull request from `feature-1` to `main`.


## Advanced options
```yaml
on:
  push:
    branches:
    - "feature/*"  # Support wildcard matching

jobs:
  pull-request:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: pull-request
      uses: repo-sync/pull-request@v2
      with:
        source_branch: ""                                 # If blank, default: triggered branch
        destination_branch: "master"                      # If blank, default: master
        pr_title: "Pulling ${{ github.ref }} into master" # Title of pull request
        pr_body: ":crown: *An automated PR*"              # Full markdown support, requires pr_title to be set
        pr_template: ".github/PULL_REQUEST_TEMPLATE.md"   # Path to pull request template, requires pr_title to be set, excludes pr_body
        pr_reviewer: "wei,worker"                         # Comma-separated list (no spaces)
        pr_assignee: "wei,worker"                         # Comma-separated list (no spaces)
        pr_label: "auto-pr"                               # Comma-separated list (no spaces)
        pr_milestone: "Milestone 1"                       # Milestone name
        pr_draft: true                                    # Creates pull request as draft
        pr_allow_empty: true                              # Creates pull request even if there are no changes
        github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Outputs

If given an `id`, the outcome of the pull-request step can be referenced in later steps. Two outputs are available: `pr_url` and `pr_number`.

```yaml
on:
  push:
    branches:
    - feature-1

jobs:
  pull-request:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: pull-request
      id: open-pr
      uses: repo-sync/pull-request@v2
      with:
        destination_branch: "main"
        github_token: ${{ secrets.GITHUB_TOKEN }}
    - name: output-url
      run: echo ${{steps.open-pr.outputs.pr_url}}
    - name: output-number
      run: echo ${{steps.open-pr.outputs.pr_number}}
    
```

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://whe.me"><img src="https://avatars3.githubusercontent.com/u/5880908?v=4" width="100px;" alt=""/><br /><sub><b>Wei He</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=wei" title="Code">💻</a> <a href="https://github.com/repo-sync/pull-request/commits?author=wei" title="Documentation">📖</a> <a href="#design-wei" title="Design">🎨</a> <a href="#ideas-wei" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="http://zeke.sikelianos.com"><img src="https://avatars1.githubusercontent.com/u/2289?v=4" width="100px;" alt=""/><br /><sub><b>Zeke Sikelianos</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=zeke" title="Documentation">📖</a> <a href="#ideas-zeke" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="https://github.com/Goobles"><img src="https://avatars3.githubusercontent.com/u/8776771?v=4" width="100px;" alt=""/><br /><sub><b>Gobius Dolhain</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=Goobles" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/jamesnetherton"><img src="https://avatars2.githubusercontent.com/u/4721408?v=4" width="100px;" alt=""/><br /><sub><b>James Netherton</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=jamesnetherton" title="Code">💻</a></td>
    <td align="center"><a href="https://christophshyper.github.io/"><img src="https://avatars3.githubusercontent.com/u/45788587?v=4" width="100px;" alt=""/><br /><sub><b>Krzysztof Szyper</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=ChristophShyper" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/michalkoza"><img src="https://avatars1.githubusercontent.com/u/2995498?v=4" width="100px;" alt=""/><br /><sub><b>Michał Koza</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=michalkoza" title="Code">💻</a></td>
    <td align="center"><a href="https://ca.linkedin.com/in/jacktonye"><img src="https://avatars2.githubusercontent.com/u/17484350?v=4" width="100px;" alt=""/><br /><sub><b>Tonye Jack</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=jackton1" title="Documentation">📖</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://jamesmgreene.github.io/"><img src="https://avatars2.githubusercontent.com/u/417751?v=4" width="100px;" alt=""/><br /><sub><b>James M. Greene</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=JamesMGreene" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/simon300000"><img src="https://avatars1.githubusercontent.com/u/12656264?v=4" width="100px;" alt=""/><br /><sub><b>simon3000</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/issues?q=author%3Asimon300000" title="Bug reports">🐛</a> <a href="https://github.com/repo-sync/pull-request/commits?author=simon300000" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/PabloBarrenechea-Reflektion"><img src="https://avatars3.githubusercontent.com/u/62668221?v=4" width="100px;" alt=""/><br /><sub><b>Pablo Barrenechea</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/issues?q=author%3APabloBarrenechea-Reflektion" title="Bug reports">🐛</a> <a href="https://github.com/repo-sync/pull-request/commits?author=PabloBarrenechea-Reflektion" title="Code">💻</a></td>
    <td align="center"><a href="https://openspur.org/~atsushi.w/"><img src="https://avatars3.githubusercontent.com/u/8390204?v=4" width="100px;" alt=""/><br /><sub><b>Atsushi Watanabe</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/issues?q=author%3Aat-wat" title="Bug reports">🐛</a> <a href="https://github.com/repo-sync/pull-request/commits?author=at-wat" title="Code">💻</a></td>
    <td align="center"><a href="http://twitter.com/christhekeele"><img src="https://avatars0.githubusercontent.com/u/1406220?v=4" width="100px;" alt=""/><br /><sub><b>Christopher Keele</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=christhekeele" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
