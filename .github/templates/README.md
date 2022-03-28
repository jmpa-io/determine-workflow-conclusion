<!-- markdownlint-disable MD041 MD010 MD034 -->
%BADGES%

%LOGO%

%NAME%

```diff
%DESCRIPTION%
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

%SCRIPTS_TABLE%

%HOW_TO_USE_TEMPLATE%
