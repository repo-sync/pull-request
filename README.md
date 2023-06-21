# GitHub Pull Request

**We are in process of archiving this repository.** This Action was created before GitHub CLI was an option. We believe there are now better options for creating pull requests using GitHub Actions.

We recommend using GitHub CLI directly in your workflow file. See: [`gh pr create`](https://cli.github.com/manual/gh_pr_create)

For example:

```yaml
# File: .github/workflows/pull-request.yml

on:
  push:
    branches:
      - feature-1

permissions:
  pull-requests: write

jobs:
  pull-request:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: pull-request
        run: |
          gh_pr_up() { gh pr create $* || gh pr edit $* }
          gh_pr_up --title "My pull request" --body "Description"
```

Refer to the [`gh pr create`](https://cli.github.com/manual/gh_pr_create) docs for further options. Read ["Defining outputs for jobs"](https://docs.github.com/en/actions/using-jobs/defining-outputs-for-jobs) to define outputs. As a result of ["GitHub Actions – Updating the default GITHUB_TOKEN permissions to read-only"](https://github.blog/changelog/2023-02-02-github-actions-updating-the-default-github_token-permissions-to-read-only/), you will need both the `permissions:` entry and to update your repository settings.

Thank you to the many contributors of this repository.
