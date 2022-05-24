<!-- markdownlint-disable MD041 MD010 MD034 -->
[![determine-workflow-conclusion](https://github.com/jmpa-io/determine-workflow-conclusion/actions/workflows/cicd.yml/badge.svg)](https://github.com/jmpa-io/determine-workflow-conclusion/actions/workflows/cicd.yml)
[![determine-workflow-conclusion](https://github.com/jmpa-io/determine-workflow-conclusion/actions/workflows/README.yml/badge.svg)](https://github.com/jmpa-io/determine-workflow-conclusion/actions/workflows/README.yml)

# `determine-workflow-conclusion`

```diff
+ 🐋 A GitHub Action for determining the status of a workflow when run inside a
+ pipeline. Largely used to post workflow statuses to Slack via
+ https://github.com/jmpa-io/notify-slack.
```

* Inspired by https://github.com/technote-space/workflow-conclusion-action.
* To learn about creating a custom GitHub Action like this, see [this doc](https://docs.github.com/en/free-pro-team@latest/actions/creating-actions/creating-a-docker-container-action).

## Usage

basic usage:
```yaml
  determine-conclusion:
    runs-on: ubuntu-20.04
    outputs:
      conclusion: ${{ steps.determine.outputs.conclusion }}
    steps:
      - id: determine
        uses: jmpa-io/determine-workflow-conclusion@v0.0.1
        with:
          token: ${{ secrets.github-token }}

  do-something-else:
    needs: [determine-conclusion]
    runs-on: ubuntu-20.04
    steps:
      - run: |
        echo "${{ needs.determine-conclusion.outputs.conclusion }}"
```

## Inputs

### (required) `token`

A GitHub personal access token; used to determine
the workflow conclusion via the GitHub API.

## Pushing new tag?

Using a <kbd>terminal</kbd>, run:

```bash
git tag v<version>
git push origin v<version>

# for example
git tag v0.0.1
git push origin v0.0.1
```
