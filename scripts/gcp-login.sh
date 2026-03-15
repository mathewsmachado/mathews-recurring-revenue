#!/usr/bin/env bash

set -Eeuo pipefail

# --- Constants ---
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_NAME="$(basename -- "${BASH_SOURCE[0]}")"
readonly DEFAULT_PROJECT="mathews-mrr-dev"
readonly DEFAULT_ACCOUNT="mathews.machadoamorim@gmail.com"

source "$SCRIPT_DIR/utils.sh"

trap 'log_error "Failed on line $LINENO"' ERR

# --- Usage ---
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

Authenticate with GCP and configure project/account defaults.

Options:
    -p, --project ID      GCP project ID (default: $DEFAULT_PROJECT)
    -a, --account EMAIL   GCP account email (default: $DEFAULT_ACCOUNT)
    -h, --help            Show this help message
EOF
    exit "${1:-0}"
}

# --- Argument parsing ---
parse_args() {
    PROJECT_ID="$DEFAULT_PROJECT"
    ACCOUNT_ID="$DEFAULT_ACCOUNT"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--project)
                PROJECT_ID="$2"
                shift 2
                ;;
            -a|--account)
                ACCOUNT_ID="$2"
                shift 2
                ;;
            -h|--help)
                usage 0
                ;;
            --)
                shift
                break
                ;;
            *)
                log_error "Unknown option: $1"
                usage 1
                ;;
        esac
    done
}

# --- Main ---
main() {
    parse_args "$@"
    check_dependencies "gcloud"

    local current_account current_project
    current_account=$(gcloud config get account 2>/dev/null || true)
    current_project=$(gcloud config get project 2>/dev/null || true)

    if [[ "$current_account" == "$ACCOUNT_ID" && "$current_project" == "$PROJECT_ID" ]]; then
        log_info "Already logged in as ${ACCOUNT_ID} on project ${PROJECT_ID}"
        exit 0
    fi

    log_info "Authenticating with GCP (project: ${PROJECT_ID}, account: ${ACCOUNT_ID})"

    gcloud auth login
    gcloud auth application-default login
    gcloud config set project "$PROJECT_ID"
    gcloud config set account "$ACCOUNT_ID"

    log_info "Done. Active configuration:"
    gcloud config list
}

main "$@"
