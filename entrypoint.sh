#!/usr/bin/env bash

set -e
set -o pipefail

#####################################
# establish a few helper functions
reset_color="\\e[0m"
color_red="\\e[31m"
color_green="\\e[32m"
color_yellow="\\e[33m"
color_blue="\\e[36m"
color_gray="\\e[37m"
function echo_blue { echo -e "${color_blue}$*${reset_color}"; }
function echo_green { echo -e "${color_green}$*${reset_color}"; }
function echo_red { echo -e "${color_red}$*${reset_color}"; }
function echo_yellow { echo -e "${color_yellow}$*${reset_color}"; }
function echo_gray { echo -e "${color_gray}$*${reset_color}"; }
function echo_grey { echo -e "${color_gray}$*${reset_color}"; }
function echo_info { echo -e "${color_blue}info: $*${reset_color}"; }
function echo_error { echo -e "${color_red}error: $*${reset_color}"; }
function echo_warning { echo -e "${color_yellow}✔ $*${reset_color}"; }
function echo_success { echo -e "${color_green}✔ $*${reset_color}"; }
function echo_fail { echo -e "${color_red}✖ $*${reset_color}"; }
function enable_debug {
  if [[ "${INPUT_DEBUG}" == "true" ]]; then
    echo_info "Enabling debug mode."
    set -x
  fi
}
function disable_debug {
  if [[ "${INPUT_DEBUG}" == "true" ]]; then
    set +x
  fi
}
# no more helper functions.
###################################


echo "::group::Check inputs"
echo "::add-mask::$INPUT_TOKEN"
if [[ -z "$INPUT_TOKEN" ]]; then
  echo_fail "Set the INPUT_TOKEN environment variable."
  exit 1
fi

# enable debug after token handling
enable_debug

if [[ -z "$GITHUB_ACTOR" ]]; then
  echo_yellow "GITHUB_ACTOR is missing. This is usually provided as an environment variable by Github Actions."
  echo_yellow "Setting GITHUB_ACTOR to 'github-actions'"
  GITHUB_ACTOR='github-actions'
fi

if [[ -z "$INPUT_REPOSITORY" ]]; then
  echo_yellow "INPUT_REPOSITORY is empty to not set. Defaulting INPUT_REPOSITORY to GITHUB_REPOSITORY"
  if [[ -z "$GITHUB_REPOSITORY" ]]; then
    echo_fail "GITHUB_REPOSITORY is missing. This is usually provided as an environment variable by Github Actions."
    echo_fail "Expected Format is generally <github_organization||github_user>/<repo_name>. i.e. aws-official/s3-sync"
    exit 1
  fi
  INPUT_REPOSITORY="$GITHUB_REPOSITORY"
fi

if [[ ! -z "$INPUT_SOURCE_BRANCH" ]]; then
  SOURCE_BRANCH="$INPUT_SOURCE_BRANCH"
elif [[ ! -z "$GITHUB_REF" ]]; then
  SOURCE_BRANCH=${GITHUB_REF/refs\/heads\//}  # Remove branch prefix
else
  echo_fail "Set the INPUT_SOURCE_BRANCH environment variable or trigger from a branch."
  exit 1
fi

DESTINATION_BRANCH="${INPUT_DESTINATION_BRANCH:-"master"}"
echo "::endgroup::"


echo "::group::Configure git"
# Github actions no longer auto set the username and GITHUB_TOKEN
GIT_ORIGIN_URL="$(git remote get-url origin)"
git remote set-url origin "https://$GITHUB_ACTOR:$INPUT_TOKEN@github.com/$INPUT_REPOSITORY"

# Pull all branches references down locally so subsequent commands can see them
git fetch origin '+refs/heads/*:refs/heads/*' --update-head-ok --prune
git fetch --prune

# Print out all branches
git --no-pager branch -a -vv
echo "::endgroup::"


echo "::group::Ensure pull-request contains differences"
if [ "$(git rev-parse --revs-only "$SOURCE_BRANCH")" = "$(git rev-parse --revs-only "$DESTINATION_BRANCH")" ]; then
  echo_blue "Source and destination branches are the same."
  exit 0
fi

# Do not proceed if there are no file differences, this avoids PRs with just a merge commit and no content
LINES_CHANGED=$(git diff --name-only "$DESTINATION_BRANCH" "$SOURCE_BRANCH" -- | wc -l | awk '{print $1}')
if [[ "$LINES_CHANGED" = "0" ]] && [[ ! "$INPUT_PR_ALLOW_EMPTY" ==  "true" ]]; then
  echo_blue "No file changes detected between source and destination branches."
  exit 0
fi
echo_yellow "Source and Destination Branches Contain Differences."
echo_yellow "Number of lines changed: $LINES_CHANGED"
echo "::endgroup::"


echo "::group::Establish hub cli parameters"
# Workaround for `hub` auth error https://github.com/github/hub/issues/2149#issuecomment-513214342
export GITHUB_USER="$GITHUB_ACTOR"
# set GITHUB_TOKEN envar so hub cli commands can authenticate.
export GITHUB_TOKEN="$INPUT_TOKEN"

if [[ ! -z "$DESTINATION_BRANCH" ]]; then
  FLAGS=(-b "$DESTINATION_BRANCH")
fi

if [[ ! -z "$SOURCE_BRANCH" ]]; then
  FLAGS+=(-h "$SOURCE_BRANCH")
fi

FLAGS+=(--no-edit)

if [[ ! -z "$INPUT_PR_TITLE" ]]; then
  FLAGS+=(-m "$INPUT_PR_TITLE")
  if [[ ! -z "$INPUT_PR_TEMPLATE" ]]; then
    sed -i 's/`/\\`/g; s/\$/\\\$/g' "$INPUT_PR_TEMPLATE"
    FLAGS+=(-m "$(echo -e "$(cat "$INPUT_PR_TEMPLATE")")")
  elif [[ ! -z "$INPUT_PR_BODY" ]]; then
    FLAGS+=(-m "$INPUT_PR_BODY")
  fi
fi

if [[ ! -z "$INPUT_PR_REVIEWER" ]]; then
  FLAGS+=(-r "$INPUT_PR_REVIEWER")
fi

if [[ ! -z "$INPUT_PR_ASSIGNEE" ]]; then
  FLAGS+=(-a "$INPUT_PR_ASSIGNEE")
fi

if [[ ! -z "$INPUT_PR_LABEL" ]]; then
  FLAGS+=(-l "$INPUT_PR_LABEL")
fi

if [[ ! -z "$INPUT_PR_MILESTONE" ]]; then
  FLAGS+=(-M "$INPUT_PR_MILESTONE")
fi

if [[ "$INPUT_PR_DRAFT" ==  "true" ]]; then
  FLAGS+=(-d)
fi

echo "${FLAGS[@]}"
echo "::endgroup::"


echo "::group::Create Pull-Request $SOURCE_BRANCH -> $DESTINATION_BRANCH"
RAND_UUID=$(cat /proc/sys/kernel/random/uuid)
COMMAND="hub pull-request "${FLAGS[@]}" 2>\"./create-pull-request.$RAND_UUID.stderr\" || true"
echo "$COMMAND"

PR_URL=$( \
  hub pull-request "${FLAGS[@]}" \
  2>"./create-pull-request.$RAND_UUID.stderr" || true \
)
STD_ERROR="$( cat "./create-pull-request.$RAND_UUID.stderr" || true )"
rm -rf "./create-pull-request.$RAND_UUID.stderr"
echo "::endgroup::"


echo "::group::Revert Git Config Changes"
# set origin back as was previously configured.
git remote set-url origin "$GIT_ORIGIN_URL"
git fetch origin '+refs/heads/*:refs/heads/*' --update-head-ok
git fetch --prune
echo "::endgroup::"


# determine success / failure
# since various things can go wrong such as bad user input or non-existant branches, there is a need to handle outputs to determine if the pr was successfully created or not.
if [[ -z "$PR_URL" ]]; then
  if [[ ! -z "$(echo "$STD_ERROR" | grep -oie "A pull request already exists for")" ]]; then 
    echo_yellow "Pull-Request Already Exists. This is the stderr output:"
    echo_yellow "$STD_ERROR"
  else
    echo_fail "Pull-Request Command Failed. This is the stderr output:"
    echo_red "$STD_ERROR"
    exit 1
  fi
else
  echo_success "Pull-Request was successfully created."
  echo_success "pr_url: ${PR_URL}"
fi

# attempt to obtain the pull-request details - pr already exists.
if [[ -z "$PR_URL" ]]; then
  echo "::group::Retrieving Pull-Request Details"
  RAND_UUID=$(cat /proc/sys/kernel/random/uuid)
  PR_URL=$( \
    hub pr list -h $SOURCE_BRANCH -b $DESTINATION_BRANCH -f %U \
    2>"./get-pull-request.$RAND_UUID.stderr" || true \
  )
  STD_ERROR="$( cat "./get-pull-request.$RAND_UUID.stderr" || true )"
  rm -rf "./get-pull-request.$RAND_UUID.stderr"

  if [[ -z "$PR_URL" ]]; then
      echo_fail "Pull-Request Already Exists, but was unable to retrieve url. This is the stderr output:"
      echo_red "$STD_ERROR"
  else
    echo_success "Pull-Request details successfully obtained."
    echo_success "pr_url: ${PR_URL}"
  fi
  echo "::endgroup::"
fi


echo "::group::Set Outputs"
echo "::set-output name=pr_url::${PR_URL}"
echo "::set-output name=pr_number::${PR_URL##*/}"
if [[ "$LINES_CHANGED" = "0" ]]; then
  echo "::set-output name=has_changed_files::false"
else
  echo "::set-output name=has_changed_files::true"
fi
echo_yellow "Outputs Set."
echo "::endgroup::"


# disable debug mode
disable_debug
