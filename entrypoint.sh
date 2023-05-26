#!/usr/bin/env bash

set -e
set -o pipefail

###################
# Helper Functions
reset_color="\\e[0m"
color_red="\\e[31m"
color_green="\\e[32m"
color_yellow="\\e[33m"
color_blue="\\e[36m"
color_gray="\\e[37m"
echo_blue() { printf "%b\n" "${color_blue}$(printf "%s\n" "$*")${reset_color}"; }
echo_green() { printf "%b\n" "${color_green}$(printf "%s\n" "$*")${reset_color}"; }
echo_red() { printf "%b\n" "${color_red}$(printf "%s\n" "$*")${reset_color}"; }
echo_yellow() { printf "%b\n" "${color_yellow}$(printf "%s\n" "$*")${reset_color}"; }
echo_gray() { printf "%b\n" "${color_gray}$(printf "%s\n" "$*")${reset_color}"; }
echo_grey() { printf "%b\n" "${color_gray}$(printf "%s\n" "$*")${reset_color}"; }
echo_info() { printf "%b\n" "${color_blue}ℹ $(printf "%s\n" "$*")${reset_color}"; }
echo_error() { printf "%b\n" "${color_red}✖ $(printf "%s\n" "$*")${reset_color}"; }
echo_warning() { printf "%b\n" "${color_yellow}✔ $(printf "%s\n" "$*")${reset_color}"; }
echo_success() { printf "%b\n" "${color_green}✔ $(printf "%s\n" "$*")${reset_color}"; }
echo_fail() { printf "%b\n" "${color_red}✖ $(printf "%s\n" "$*")${reset_color}"; }
enable_debug() {
  if [[ "${INPUT_DEBUG}" == "true" ]]; then
    echo_info "Enabling debug mode."
    set -x
  fi
}
disable_debug() {
  if [[ "${INPUT_DEBUG}" == "true" ]]; then
    set +x
  fi
}

# work with repository in subdirectory
if [[ -n "$INPUT_WORKING_DIRECTORY" ]]; then
  echo "Changing working directory to $INPUT_WORKING_DIRECTORY"
  cd "$INPUT_WORKING_DIRECTORY"
fi

# Fix for the unsafe repo error: https://github.com/repo-sync/pull-request/issues/84
git config --global --add safe.directory $(pwd)

##############################
echo "::group::Gather Inputs"

if [[ -z "$GITHUB_TOKEN" ]]; then
  if [[ ! -z "$INPUT_GITHUB_TOKEN" ]]; then
    GITHUB_TOKEN="$INPUT_GITHUB_TOKEN"
    echo "::add-mask::$INPUT_GITHUB_TOKEN"
    echo_info "INPUT_GITHUB_TOKEN=$INPUT_GITHUB_TOKEN"
  else
    echo_fail "Set the GITHUB_TOKEN environment variable."
    exit 1
  fi
fi

# enable debug after token handling
enable_debug

if [[ ! -z "$INPUT_SOURCE_BRANCH" ]]; then
  SOURCE_BRANCH="$INPUT_SOURCE_BRANCH"
elif [[ ! -z "$GITHUB_REF" ]]; then
  SOURCE_BRANCH=${GITHUB_REF/refs\/heads\//}  # Remove branch prefix
else
  echo_fail "Set the INPUT_SOURCE_BRANCH environment variable or trigger from a branch."
  exit 1
fi
echo_info "SOURCE_BRANCH=$SOURCE_BRANCH"

DESTINATION_BRANCH="${INPUT_DESTINATION_BRANCH:-"master"}"
echo_info "DESTINATION_BRANCH=$DESTINATION_BRANCH"

# Determine repository url
if [[ -z "$INPUT_DESTINATION_REPOSITORY" ]]; then
  # Try to query local repository's remote url if INPUT_DESTINATION_REPOSITORY is null
  CHECKOUT_REPOSITORY=$(git remote get-url origin | sed -r -e 's:(\.git$)::g' -e 's:https\://([^/]+)/([^/]+)/(.*):\2\/\3:g' -e 's:git@([^/]+)\:([^/]+)/(.*):\2\/\3:g')
fi

# Fallback to GITHUB_REPOSITORY if both INPUT_DESTINATION_REPOSITORY and CHECKOUT_REPOSITORY are unavailable
DESTINATION_REPOSITORY="${INPUT_DESTINATION_REPOSITORY:-${CHECKOUT_REPOSITORY:-${GITHUB_REPOSITORY}}}"

echo_gray "INPUT_DESTINATION_REPOSITORY=$INPUT_DESTINATION_REPOSITORY"
echo_gray "CHECKOUT_REPOSITORY=$CHECKOUT_REPOSITORY"
echo_gray "GITHUB_REPOSITORY=$GITHUB_REPOSITORY"
echo_info "DESTINATION_REPOSITORY=$DESTINATION_REPOSITORY"

echo "::endgroup::"

##############################
echo "::group::Configure git"

# Github actions no longer auto set the username and GITHUB_TOKEN
git remote set-url origin "https://x-access-token:$GITHUB_TOKEN@${GITHUB_SERVER_URL#https://}/$DESTINATION_REPOSITORY"

# Pull all branches references down locally so subsequent commands can see them
git fetch origin '+refs/heads/*:refs/heads/*' --update-head-ok

# Print out all branches
git --no-pager branch -a -vv

echo "::endgroup::"

#########################################################
echo "::group::Ensure pull-request contains differences"

if [ "$(git rev-parse --revs-only "$SOURCE_BRANCH")" = "$(git rev-parse --revs-only "$DESTINATION_BRANCH")" ]; then
  echo_info "Source and destination branches are the same."
  exit 0
fi

# Do not proceed if there are no file differences, this avoids PRs with just a merge commit and no content
LINES_CHANGED=$(git diff --name-only "$DESTINATION_BRANCH" "$SOURCE_BRANCH" -- | wc -l | awk '{print $1}')
if [[ "$LINES_CHANGED" = "0" ]] && [[ ! "$INPUT_PR_ALLOW_EMPTY" ==  "true" ]]; then
  echo_info "No file changes detected between source and destination branches."
  exit 0
fi

echo "::endgroup::"

#############################################
echo "::group::Assemble hub pr parameters"
# Workaround for `hub` auth error https://github.com/github/hub/issues/2149#issuecomment-513214342
export GITHUB_USER="$GITHUB_ACTOR"

PR_ARG=(-b "$DESTINATION_BRANCH" -h "$SOURCE_BRANCH" --no-edit)

if [[ ! -z "$INPUT_PR_TITLE" ]]; then
  PR_ARG+=(-m "$INPUT_PR_TITLE")
  if [[ ! -z "$INPUT_PR_TEMPLATE" ]]; then
    sed -i 's/`/\\`/g; s/\$/\\\$/g' "$INPUT_PR_TEMPLATE"
    PR_ARG+=(-m "$(echo -e "$(cat "$INPUT_PR_TEMPLATE")")")
  elif [[ ! -z "$INPUT_PR_BODY" ]]; then
    PR_ARG+=(-m "$INPUT_PR_BODY")
  fi
fi

if [[ ! -z "$INPUT_PR_REVIEWER" ]]; then
  PR_ARG+=(-r "$INPUT_PR_REVIEWER")
fi

if [[ ! -z "$INPUT_PR_ASSIGNEE" ]]; then
  PR_ARG+=(-a "$INPUT_PR_ASSIGNEE")
fi

if [[ ! -z "$INPUT_PR_LABEL" ]]; then
  PR_ARG+=(-l "$INPUT_PR_LABEL")
fi

if [[ ! -z "$INPUT_PR_MILESTONE" ]]; then
  PR_ARG+=(-M "$INPUT_PR_MILESTONE")
fi

if [[ "$INPUT_PR_DRAFT" ==  "true" ]]; then
  PR_ARG+=(-d)
fi

echo_info "${PR_ARG[@]}"
echo "::endgroup::"

##########################################################################
echo "::group::Create pull request $SOURCE_BRANCH -> $DESTINATION_BRANCH"

COMMAND="hub pull-request "${PR_ARG[@]}" 2> /tmp/pull-request.stderr.log || true"
echo_info "$COMMAND"

PR_URL=$(hub pull-request "${PR_ARG[@]}" 2> /tmp/pull-request.stderr.log || true)
STD_ERROR="$(cat /tmp/pull-request.stderr.log || true)"
echo_error "STD_ERROR=$STD_ERROR"

echo "::endgroup::"


################################################
echo "::group::Retrieving pull request details"

PR_CREATED="true"
# determine success / failure
# since various things can go wrong such as bad user input or non-existant branches, there is a need to handle outputs to determine if the pr was successfully created or not.
if [[ -z "$PR_URL" ]]; then
  PR_CREATED="false"
  if echo "$STD_ERROR" | grep -q "already exists"; then
    echo_yellow "Pull request already exists. This is the stderr output:"
    echo_yellow "$STD_ERROR"
  else
    echo_fail "Pull request command failed. This is the stderr output:"
    echo_red "$STD_ERROR"
    exit 1
  fi
else
  echo_success "Pull request was successfully created"
  echo_success "PR_URL=$PR_URL"
fi

# attempt to obtain the pull-request details - pr already exists.
if [[ -z "$PR_URL" ]]; then
  PR_URL=$(\
    hub pr list -h $SOURCE_BRANCH -b $DESTINATION_BRANCH -f %U \
    2>"./get-pull-request.stderr.log" || true \
  )
  STD_ERROR="$(cat "./get-pull-request.stderr.log" || true)"

  if [[ -z "$PR_URL" ]]; then
      echo_fail "Pull Request Already Exists, but was unable to retrieve url. This is the stderr output:"
      echo_red "$STD_ERROR"
  else
    echo_success "Pull request details successfully obtained"
    echo_success "PR_URL=${PR_URL}"
  fi
fi

echo "::endgroup::"

############################
echo "::group::Set outputs"

echo "pr_url=${PR_URL}" >> $GITHUB_OUTPUT
echo "pr_number=${PR_URL##*/}" >> $GITHUB_OUTPUT
echo "pr_created=${PR_CREATED}" >> $GITHUB_OUTPUT

if [[ "$LINES_CHANGED" = "0" ]]; then
  echo "has_changed_files=false" >> $GITHUB_OUTPUT
else
  echo "has_changed_files=true" >> $GITHUB_OUTPUT
fi

cat $GITHUB_OUTPUT

echo "::endgroup::"
