
# This file is a collection of bash functions that are helpers I have
# written to aid with developing git hooks.

# TODO: add documentation about this having to being run before cding to
# anything

# Get the path to the repository. This function returns it via stdout.
# Hence, this method is intended to be called using command
# substitution.
# ex: repo_path=$(get_repository_path)
function get_repository_path {
  echo $(pwd -P)
}

# TODO: adjust this method to take in a repository path and get the name
# of the repository

# Get the repository name. This function returns it via stdout. Hence,
# this method is intended to be called using command substitution.
# ex: repo_name=$(get_repository_name)
function get_repository_name {
  echo $(basename $(get_repository_path))
}

# TODO: adjust this method to take in a repository path and get the
# context of the repository

# Get the repository context. This function returns the context wrapping
# the repository via stdout. Hence, this method is intended to be called
# using command substitution.
# ex: repo_context=$(get_repository_context)
function get_repository_context {
  local repository_context_path=$(dirname $(get_repository_path))
  echo $(basename ${repository_context_path}) 
}

# Obtain the name of the currently checked out branch and 'return' it by
# echoing it to stdout. It is intended to be called using command
# substitution.
# ex: current_branch=$(get_current_branch)
function get_current_branch {
  local current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')
  echo "$current_branch"
}

# Attempt to fetch any jira issues from the provided branch name. If
# jira issues are found a jira issue is returned via stdout space
# separated. If no jira issues are found an empty string is returned via
# stdout. Hence, this function is intended to be called using command
# substitution.
# ex: jira_issues=$(get_jira_issues_from_branch_name "some_branch_name")
function get_jira_issues_from_branch_name {
  local branch_name=$1
  echo "$(echo "$branch_name" | grep -Eo '[A-Z]+-[0-9]+')"
}

# Attempt to fetch any issues from the provided branch name. If any
# github style issues are found an issue is returned via stdout space
# separated. If on issues are found an empty string is returned via
# stdout. Hence, this function is intended to be called using command
# substitution.
# ex: issues=$(get_issues_from_branch_name "some_branch_name")
function get_issues_from_branch_name {
  local branch_name=$1
  echo "$(echo "$branch_name" | grep -Eo '\-?([0-9]+)\-?' | sed -n 's/-//gp')"
}

# Build jira issue link given an issue identifier. This method returns
# the built jira issue link via stdout. Hence, it is intended to be
# called using command substitution.
# ex: jira_issue_link=$(build_jira_issue_link "WEB-23423")
function build_jira_issue_link {
  local jira_issue=$1
  echo "https://acorns.atlassian.net/browse/${jira_issue}"
}

# Build github style issue reference for the given issue identifier.
# This method returns the built issue reference via stdout. Hence, it is
# intended to be called using command substitution.
# ex: issue_reference=$(build_issue_reference "3222")
function build_issue_reference {
  local issue=$1
  echo "#${issue}"
}

# Insert the jira issue links given the jira issue identifiers and the
# commit message file to insert them into.
# ex: insert_issue_links_into_commit_message "WEB-23423\nOPS-2332" ".git/COMMIT_EDITMSG"
function insert_acorns_issue_links_into_commit_message {
  local jira_issues=$1
  local commit_message_file=$2

  local jira_issue_links=''
  for jira_issue in $jira_issues; do 
    local jira_issue_link=$(build_jira_issue_link $jira_issue)
    jira_issue_links="${jira_issue_links}"'\'$'\n'"Issue: ${jira_issue_link}"
  done

  sed -i.back '/^# Please enter the commit/i\'$'\n'"${jira_issue_links}"$'\n' $commit_message_file
}

# Insert the issue references given the issue identifiers and the
# commit message file to insert them into.
# ex: insert_issue_into_commit_message "23423 2332" ".git/COMMIT_EDITMSG"
function insert_issues_into_commit_message {
  local issues=$1
  local commit_message_file=$2

  local formatted_refs=$(echo "$issues" | sed -n 's/ /, /g')
  local issue_refs=''
  for issue in $issues; do 
    local issue_ref=$(build_issue_reference $issue)
    if [ "$issue_refs" ]; then
      issue_refs="${issue_refs}, ${issue_ref}"
    else
      issue_refs="${issue_refs}${issue_ref}"
    fi
  done
  issue_refs='\'$'\n'"Issues: ${issue_refs}"

  sed -i.back '/^# Please enter the commit/i\'$'\n'"${issue_refs}"$'\n' $commit_message_file
}
