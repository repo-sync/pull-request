#!/bin/sh

set -e

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN environment variable."
  exit 1
fi

env

if [[ ! -z "$SOURCE_BRANCH" ]]; then
  SOURCE_BRANCH="$SOURCE_BRANCH"
elif [[ ! -z "$GITHUB_REF" ]]; then
  SOURCE_BRANCH=${GITHUB_REF/refs\/heads\//}  # Remove branch prefix
else
  echo "Set the SOURCE_BRANCH environment variable or trigger from a branch."
  exit 1
fi

DESTINATION_BRANCH="${DESTINATION_BRANCH:-"master"}"

# Github actions no longer auto set the username and GITHUB_TOKEN
git remote set-url origin "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY"

# Pull all branches references down locally so subsequent commands can see them
git fetch origin '+refs/heads/*:refs/heads/*'

if [ "$(git rev-parse --revs-only "$SOURCE_BRANCH")" = "$(git rev-parse --revs-only "$DESTINATION_BRANCH")" ]; then 
  echo "Source and destination branches are the same." 
fi

# Workaround for `hub` auth error https://github.com/github/hub/issues/2149#issuecomment-513214342
export GITHUB_USER="$GITHUB_ACTOR"

PR_ARG="$PR_TITLE"
if [[ ! -z "$PR_ARG" ]]; then
  PR_ARG="-m \"$PR_ARG\""

  if [[ ! -z "$PR_BODY" ]]; then
    PR_ARG="$PR_ARG -m \"$PR_BODY\""
  fi
fi

if [[ ! -z "$PR_REVIEWER" ]]; then
  PR_ARG="$PR_ARG -r \"$PR_REVIEWER\""
fi

if [[ ! -z "$PR_ASSIGNEE" ]]; then
  PR_ARG="$PR_ARG -a \"$PR_ASSIGNEE\""
fi

if [[ ! -z "$PR_LABEL" ]]; then
  PR_ARG="$PR_ARG -l \"$PR_LABEL\""
fi

if [[ ! -z "$PR_MILESTONE" ]]; then
  PR_ARG="$PR_ARG -M \"$PR_MILESTONE\""
fi

COMMAND="hub pull-request \
  -b $DESTINATION_BRANCH \
  -h $SOURCE_BRANCH \
  --no-edit \
  $PR_ARG \
  || true"

echo "$COMMAND"
sh -c "$COMMAND"
