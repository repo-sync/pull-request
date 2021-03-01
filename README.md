# GitHub Pull Request

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-13-orange.svg?style=flat-square)](#contributors-)
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
        token: ${{ secrets.GITHUB_TOKEN }}
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
        repository: ${{ github.repository }}              # repository with owner, can be another repository than currently checked out when using a PAT during checkout that has access to the other repo.
        pr_title: "Pulling ${{ github.ref }} into master" # Title of pull request
        pr_body: |                                        # Full markdown support, requires pr_title to be set
          :crown: *An automated PR*
          :arrow_heading_up: Closes: #issueid <!-- your issue -->
          
          **Describe the Change** <!-- A longer description  -->
          "Put a description here"
        pr_template: ".github/PULL_REQUEST_TEMPLATE.md"   # Path to pull request template, requires pr_title to be set, excludes pr_body
        pr_reviewer: "wei,worker"                         # Comma-separated list (no spaces)
        pr_assignee: "wei,worker"                         # Comma-separated list (no spaces)
        pr_label: "auto-pr"                               # Comma-separated list (no spaces)
        pr_milestone: "Milestone 1"                       # Milestone name
        pr_draft: true                                    # Creates pull request as draft
        pr_allow_empty: true                              # Creates pull request even if there are no changes
        token: ${{ secrets.GITHUB_PERSONAL_ACTION_TOKEN }}
        debug: false                                      # bash set -x verbose debugging output
```

### Outputs

The following outputs are available: `pr_url`, `pr_number`, `has_changed_files ("true"|"false")`.

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
        token: ${{ secrets.GITHUB_TOKEN }}
    - name: output-url
      run: echo ${{steps.open-pr.outputs.pr_url}}
    - name: output-number
      run: echo ${{steps.open-pr.outputs.pr_number}}
    - name: output-has-changed-files
      run: echo ${{steps.open-pr.outputs.has_changed_files}}

```

### Example: Pull-Request on another repo
This example demonstrates how to create a pull-request in another repo. There are a few caveats such as the requirement of checking out the code with a [Github Personal Action Token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token). There are some pretty advanced use cases for this such as building an app on every push to develop, updating the docker image tag and repo url in the config repo, and creating a pull-request to the config repo. After the pr in the config repo is merged a deployment is kicked off.
```yaml
on:
  push:
    branches:
    - 'develop'
jobs:
  draft-new-pr:
    name: "Create PR in my-apps-config-repo"
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
          token: ${{ secrets.ACTIONS_WORKFLOW_PAT }}
      - name: Create Alt Repo Pull-Request
        uses: ./.github/actions/actions-create-pull-request
        with:
          source_branch: 'develop'
          destination_branch: 'master'
          repository: '${{ github.repository_owner }}/my-apps-config-repo'
          pr_title: "Pulling 'release/${{ steps.ver.outputs.version-after }}' into master"
          pr_body: |
            :crown: *An automated PR*
            
            This PR was created in response to a manual trigger of the release workflow here: https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }}.
            ..And creates a pr in this other repo here: https://github.com/${{ github.repository_owner }}/my-apps-config-repo.

            "Put a description here"
            'Quotes are being handled'
          pr_label: "some-label,another-label"
          pr_allow_empty: false
          token: ${{ secrets.ACTIONS_WORKFLOW_PAT }}
          debug: false
```

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://whe.me"><img src="https://avatars3.githubusercontent.com/u/5880908?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Wei He</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=wei" title="Code">💻</a> <a href="https://github.com/repo-sync/pull-request/commits?author=wei" title="Documentation">📖</a> <a href="#design-wei" title="Design">🎨</a> <a href="#ideas-wei" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="http://zeke.sikelianos.com"><img src="https://avatars1.githubusercontent.com/u/2289?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Zeke Sikelianos</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=zeke" title="Documentation">📖</a> <a href="#ideas-zeke" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="https://github.com/Goobles"><img src="https://avatars3.githubusercontent.com/u/8776771?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Gobius Dolhain</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=Goobles" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/jamesnetherton"><img src="https://avatars2.githubusercontent.com/u/4721408?v=4?s=100" width="100px;" alt=""/><br /><sub><b>James Netherton</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=jamesnetherton" title="Code">💻</a></td>
    <td align="center"><a href="https://christophshyper.github.io/"><img src="https://avatars3.githubusercontent.com/u/45788587?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Krzysztof Szyper</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=ChristophShyper" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/michalkoza"><img src="https://avatars1.githubusercontent.com/u/2995498?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Michał Koza</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=michalkoza" title="Code">💻</a></td>
    <td align="center"><a href="https://ca.linkedin.com/in/jacktonye"><img src="https://avatars2.githubusercontent.com/u/17484350?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Tonye Jack</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=jackton1" title="Documentation">📖</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://jamesmgreene.github.io/"><img src="https://avatars2.githubusercontent.com/u/417751?v=4?s=100" width="100px;" alt=""/><br /><sub><b>James M. Greene</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=JamesMGreene" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/simon300000"><img src="https://avatars1.githubusercontent.com/u/12656264?v=4?s=100" width="100px;" alt=""/><br /><sub><b>simon3000</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/issues?q=author%3Asimon300000" title="Bug reports">🐛</a> <a href="https://github.com/repo-sync/pull-request/commits?author=simon300000" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/PabloBarrenechea-Reflektion"><img src="https://avatars3.githubusercontent.com/u/62668221?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Pablo Barrenechea</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/issues?q=author%3APabloBarrenechea-Reflektion" title="Bug reports">🐛</a> <a href="https://github.com/repo-sync/pull-request/commits?author=PabloBarrenechea-Reflektion" title="Code">💻</a></td>
    <td align="center"><a href="https://openspur.org/~atsushi.w/"><img src="https://avatars3.githubusercontent.com/u/8390204?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Atsushi Watanabe</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/issues?q=author%3Aat-wat" title="Bug reports">🐛</a> <a href="https://github.com/repo-sync/pull-request/commits?author=at-wat" title="Code">💻</a></td>
    <td align="center"><a href="http://twitter.com/christhekeele"><img src="https://avatars0.githubusercontent.com/u/1406220?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Christopher Keele</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=christhekeele" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/rachmari"><img src="https://avatars.githubusercontent.com/u/9831992?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Rachael Sewell</b></sub></a><br /><a href="https://github.com/repo-sync/pull-request/commits?author=rachmari" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
