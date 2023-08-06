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
# https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables
repo="${GITHUB_REPOSITORY}"
id="${GITHUB_RUN_ID}"
attempt="${GITHUB_RUN_ATTEMPT}"
[[ -z "$repo" ]]    && die "missing \$GITHUB_REPOSITORY"
[[ -z "$id" ]]      && die "missing \$GITHUB_RUN_ID"
[[ -z "$attempt" ]] && die "missing \$GITHUB_RUN_ATTEMPT"
echo "$repo"
echo "$id"
echo "$attempt"

# read jobs for workflow.
resp=$(curl -s "https://api.github.com/repos/$repo/actions/runs/$id/attempts/$attempt/jobs" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: bearer $token") \
  || die "failed curl to retrieve $repo $id jobs"
echo "$resp"
conclusions=$(<<< "$resp" jq -r '.jobs[]
  | select(.status == "completed")
  | [.conclusion]
  | @csv') \
  || die "failed to parse response when retrieving $repo $id jobs"
conclusions=$(<<< "$conclusions" tr -d '"') \
  || die "failed to remove quotes from response when retrieving $repo $id jobs"

# determine conclusion from jobs.
successes=0; failures=0; skipped=0; cancellations=0
for c in $conclusions; do
  case "$c" in
    success) ((successes++)) ;;
    failure) ((failures++)) ;;
    skipped) ((skipped++)) ;;
    cancelled) ((cancellations++)) ;;
  esac
done
conclusion="failure"
[[ $failures -eq 0 ]] && conclusion="success"

# print breakdown.
echo "##[group]Breakdown of results for $repo $id"
echo "successes: $successes"
echo "failures: $failures"
echo "skipped: $skipped"
echo "cancellations: $cancellations"
echo "##[endgroup]"

# fail early, on no conclusion
[[ $successes -eq 0 && $failures -eq 0 &&
  $skipped -eq 0 && $cancellations -eq 0 ]] \
  && die "failed to determine conclusion; successes, failures, skipped, and cancellations are ALL zero"

# print conclusion.
echo "##[group]Conclusion for $repo $id"
echo "conclusion: $conclusion"
echo "##[endgroup]"
if [[ -n "$CI" ]]; then
  echo "conclusion=$conclusion" >> "$GITHUB_OUTPUT"
fi
