# GitHub Pull Request

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-19-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

A GitHub Action for creating pull requests.


## Features
 * Create pull requests
 * Create pull requests on other repos
 * Add reviewers, assignees, labels, or milestones
 * Customize pull request title and body
 * Retrieve the existing pull request url if a pull request already exists


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
    - uses: actions/checkout@v3
    - name: pull-request
      uses: repo-sync/pull-request@v2
      with:
        destination_branch: "main"
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
    - uses: actions/checkout@v3
    - name: pull-request
      uses: repo-sync/pull-request@v2
      with:
        source_branch: ""                                 # If blank, default: triggered branch
        destination_branch: "master"                      # If blank, default: master
        pr_title: "Pulling ${{ github.ref }} into master" # Title of pull request
        pr_body: |                                        # Full markdown support, requires pr_title to be set
          :crown: *An automated PR*

          _Created by [repo-sync/pull-request](https://github.com/repo-sync/pull-request)_
        pr_template: ".github/PULL_REQUEST_TEMPLATE.md"   # Path to pull request template, requires pr_title to be set, excludes pr_body
        pr_reviewer: "wei,worker"                         # Comma-separated list (no spaces)
        pr_assignee: "wei,worker"                         # Comma-separated list (no spaces)
        pr_label: "auto-pr"                               # Comma-separated list (no spaces)
        pr_milestone: "Milestone 1"                       # Milestone name
        pr_draft: true                                    # Creates pull request as draft
        pr_allow_empty: true                              # Creates pull request even if there are no changes
        github_token: ${{ secrets.CUSTOM_GH_TOKEN }}      # If blank, default: secrets.GITHUB_TOKEN
```

### Third-party repositories

Since it's possible to `checkout` third-party repositories, you can either define `destination_repository` manually or let
this action automatically pick up the checked out repository.

```yaml
jobs:
  pull-request:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
      with:
        repository: "octocat/hello-world"
    - name: pull-request
      uses: repo-sync/pull-request@v2
      with:
        destination_branch: "main"
        github_token: ${{ secrets.GITHUB_TOKEN }}
      # destination_repository: "octocat/hello-world" <- You can also do this but not necessary
```

**Priority will be set as follows:**

1. `destination_repository` (Manually set)
2. Checked out repository
3. Repository that triggered the action (`GITHUB_REPOSITORY`)

### Outputs

The following outputs are available: `pr_url`, `pr_number`, `pr_created ("true"|"false")`, `has_changed_files ("true"|"false")`.

```yaml
on:
  push:
    branches:
    - feature-1

jobs:
  pull-request:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
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
    - name: output-created
      run: echo ${{steps.open-pr.outputs.pr_created}}
    - name: output-has-changed-files
      run: echo ${{steps.open-pr.outputs.has_changed_files}}

```

## Docker Container Image Usage

Sometimes you might want to use a pre-built container image directly. This could result in faster runs and prevent needlessly rebuilding container images over-and-over on self-hosted runners.

```yml
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
      uses: docker://ghcr.io/repo-sync/pull-request:v2
      with:
        destination_branch: "main"
        github_token: ${{ secrets.GITHUB_TOKEN }}         # Required to use container image
```

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center"><a href="https://whe.me"><img src="https://avatars3.githubusercontent.com/u/5880908?v=4?s=100" width="100px;" alt="Wei He"/><br /><sub><b>Wei He</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=wei" title="Code">💻</a> <a href="https://github.com/repo-sync/pull-request/commits?author=wei" title="Documentation">📖</a> <a href="#design-wei" title="Design">🎨</a> <a href="#ideas-wei" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center"><a href="http://zeke.sikelianos.com"><img src="https://avatars1.githubusercontent.com/u/2289?v=4?s=100" width="100px;" alt="Zeke Sikelianos"/><br /><sub><b>Zeke Sikelianos</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=zeke" title="Documentation">📖</a> <a href="#ideas-zeke" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center"><a href="https://github.com/Goobles"><img src="https://avatars3.githubusercontent.com/u/8776771?v=4?s=100" width="100px;" alt="Gobius Dolhain"/><br /><sub><b>Gobius Dolhain</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=Goobles" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/jamesnetherton"><img src="https://avatars2.githubusercontent.com/u/4721408?v=4?s=100" width="100px;" alt="James Netherton"/><br /><sub><b>James Netherton</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=jamesnetherton" title="Code">💻</a></td>
      <td align="center"><a href="https://christophshyper.github.io/"><img src="https://avatars3.githubusercontent.com/u/45788587?v=4?s=100" width="100px;" alt="Krzysztof Szyper"/><br /><sub><b>Krzysztof Szyper</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=ChristophShyper" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/michalkoza"><img src="https://avatars1.githubusercontent.com/u/2995498?v=4?s=100" width="100px;" alt="Michał Koza"/><br /><sub><b>Michał Koza</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=michalkoza" title="Code">💻</a></td>
      <td align="center"><a href="https://ca.linkedin.com/in/jacktonye"><img src="https://avatars2.githubusercontent.com/u/17484350?v=4?s=100" width="100px;" alt="Tonye Jack"/><br /><sub><b>Tonye Jack</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=jackton1" title="Documentation">📖</a></td>
    </tr>
    <tr>
      <td align="center"><a href="https://jamesmgreene.github.io/"><img src="https://avatars2.githubusercontent.com/u/417751?v=4?s=100" width="100px;" alt="James M. Greene"/><br /><sub><b>James M. Greene</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=JamesMGreene" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/simon300000"><img src="https://avatars1.githubusercontent.com/u/12656264?v=4?s=100" width="100px;" alt="simon3000"/><br /><sub><b>simon3000</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/issues?q=author%3Asimon300000" title="Bug reports">🐛</a> <a href="https://github.com/repo-sync/pull-request/commits?author=simon300000" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/PabloBarrenechea-Reflektion"><img src="https://avatars3.githubusercontent.com/u/62668221?v=4?s=100" width="100px;" alt="Pablo Barrenechea"/><br /><sub><b>Pablo Barrenechea</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/issues?q=author%3APabloBarrenechea-Reflektion" title="Bug reports">🐛</a> <a href="https://github.com/repo-sync/pull-request/commits?author=PabloBarrenechea-Reflektion" title="Code">💻</a></td>
      <td align="center"><a href="https://openspur.org/~atsushi.w/"><img src="https://avatars3.githubusercontent.com/u/8390204?v=4?s=100" width="100px;" alt="Atsushi Watanabe"/><br /><sub><b>Atsushi Watanabe</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/issues?q=author%3Aat-wat" title="Bug reports">🐛</a> <a href="https://github.com/repo-sync/pull-request/commits?author=at-wat" title="Code">💻</a></td>
      <td align="center"><a href="http://twitter.com/christhekeele"><img src="https://avatars0.githubusercontent.com/u/1406220?v=4?s=100" width="100px;" alt="Christopher Keele"/><br /><sub><b>Christopher Keele</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=christhekeele" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/rachmari"><img src="https://avatars.githubusercontent.com/u/9831992?v=4?s=100" width="100px;" alt="Rachael Sewell"/><br /><sub><b>Rachael Sewell</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=rachmari" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/TheKoenig"><img src="https://avatars.githubusercontent.com/u/74304748?v=4?s=100" width="100px;" alt="TheKoenig"/><br /><sub><b>TheKoenig</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=TheKoenig" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center"><a href="https://github.com/hrtshu"><img src="https://avatars.githubusercontent.com/u/6995290?v=4?s=100" width="100px;" alt="Shuhei"/><br /><sub><b>Shuhei</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=hrtshu" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/jw-maynard"><img src="https://avatars.githubusercontent.com/u/23322066?v=4?s=100" width="100px;" alt="jw-maynard"/><br /><sub><b>jw-maynard</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=jw-maynard" title="Code">💻</a></td>
      <td align="center"><a href="https://hirok.io"><img src="https://avatars.githubusercontent.com/u/1075694?v=4?s=100" width="100px;" alt="hiroki osame"/><br /><sub><b>hiroki osame</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=privatenumber" title="Code">💻</a></td>
      <td align="center"><a href="https://variatix.net"><img src="https://avatars.githubusercontent.com/u/6711514?v=4?s=100" width="100px;" alt="Mahesh Bandara Wijerathna"/><br /><sub><b>Mahesh Bandara Wijerathna</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=m4heshd" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/arizonaherbaltea"><img src="https://avatars.githubusercontent.com/u/41610038?v=4?s=100" width="100px;" alt="Herbo"/><br /><sub><b>Herbo</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=arizonaherbaltea" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
