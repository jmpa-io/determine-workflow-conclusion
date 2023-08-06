<!-- markdownlint-disable MD041 MD010 MD034 -->
[![README.yml](https://github.com/jmpa-io/determine-workflow-conclusion/actions/workflows/README.yml/badge.svg)](https://github.com/jmpa-io/determine-workflow-conclusion/actions/workflows/README.yml)
[![cicd.yml](https://github.com/jmpa-io/determine-workflow-conclusion/actions/workflows/cicd.yml/badge.svg)](https://github.com/jmpa-io/determine-workflow-conclusion/actions/workflows/cicd.yml)

# `determine-workflow-conclusion`

```diff
+ 🐋 A GitHub Action for determining the status of a workflow when run inside a
+ pipeline. Largely used to post workflow statuses to Slack via
+ https://github.com/jmpa-io/post-to-slack.
```

* Inspired by [`worfklow-conclusion-action` by `technote-space`](https://github.com/technote-space/workflow-conclusion-action); Created using [this doc](https://docs.github.com/en/free-pro-team@latest/actions/creating-actions/creating-a-docker-container-action) from GitHub.

## `usage`

General:

```yaml
  determine-conclusion:
    runs-on: ubuntu-latest
    outputs:
      conclusion: ${{ steps.determine.outputs.conclusion }}
    steps:
      - id: determine
        uses: jmpa-io/determine-workflow-conclusion@main
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

  do-something-else:
    needs: [determine-conclusion]
    runs-on: ubuntu-latest
    steps:
      - run: |
        echo "${{ needs.determine-conclusion.outputs.conclusion }}"
```

## `inputs`

### (required) `token`

A GitHub personal access token; used to determine
the workflow conclusion via the GitHub API.
