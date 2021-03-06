#!/usr/bin/env bash
# determines the workflow conclusion for a workflow; aiming for this to be run
# when a workflow is running.

# funcs.
die() { echo "$1" >&2; exit "${2:-1}"; }

# check bash version.
[[ "${BASH_VERSION:0:1}" -lt 4 ]] \
  && die "bash version 4+ required"

# check deps.
deps=(curl jq)
for dep in "${deps[@]}"; do
  hash "$dep" 2>/dev/null || missing+=("$dep")
done
if [[ ${#missing[@]} -ne 0 ]]; then
  s=""; [[ ${#missing[@]} -gt 1 ]] && { s="s"; }
  die "missing dep${s}: ${missing[*]}"
fi

# check required parameters are given.
token="$INPUT_TOKEN"
missing=()
[[ -z "$token" ]] && { missing+=("token"); }
if [[ ${#missing[@]} -ne 0 ]]; then
  [[ ${#missing[@]} -gt 1 ]] && { s="s"; }
  die "missing input parameter${s}: ${missing[*]}"
fi

# vars.
repo="${GITHUB_REPOSITORY}"
id="${GITHUB_RUN_ID}"
attempt="${GITHUB_RUN_ATTEMPT}"
[[ -z "$repo" ]]    && die "missing \$GITHUB_REPOSITORY"
[[ -z "$id" ]]      && die "missing \$GITHUB_RUN_ID"
[[ -z "$attempt" ]] && die "missing \$GITHUB_RUN_ATTEMPT"

# read jobs for workflow.
resp=$(curl -s "https://api.github.com/repos/$repo/actions/runs/$id/attempts/$attempt/jobs" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: bearer $token") \
  || die "failed curl to retrieve $repo $id jobs"
conclusions=$(<<< "$resp" jq -r '.jobs[]
  | select(.status == "completed")
  | [.conclusion]
  | @csv' | tr -d '"') \
  || die "failed to parse response when retrieving $repo $id jobs"

# determine conclusion from jobs.
conclusion="success"
for c in $conclusions; do
  [[ "$c" != "success" ]] && { conclusion="failure"; }
done

# print result.
echo "##[group]Found conclusion for $repo $id"
echo "$conclusion"
echo "##[endgroup]"
echo "::set-output name=conclusion::$conclusion"
