#!/usr/bin/env bash

set -Eeuo pipefail

# --- Constants ---
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_NAME="$(basename -- "${BASH_SOURCE[0]}")"

source "$SCRIPT_DIR/utils.sh"

trap 'log_error "Failed on line $LINENO"' ERR

# --- Usage ---
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

Authenticate with GCP (user login + application-default credentials).

Options:
    -h, --help    Show this help message
EOF
    exit "${1:-0}"
}

# --- Argument parsing ---
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
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

    log_info "Authenticating with GCP..."

    gcloud auth login
    gcloud auth application-default login

    log_info "Authentication complete"
}

main "$@"
