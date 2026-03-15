#!/usr/bin/env bash

set -Eeuo pipefail

# --- Constants ---
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_NAME="$(basename -- "${BASH_SOURCE[0]}")"
readonly DEFAULT_PROJECT="mathews-mrr-dev"
readonly DEFAULT_ACCOUNT="mathews.machadoamorim@gmail.com"
readonly DEFAULT_LOCATION="us-central1"
readonly SA_NAME="terraform"

readonly -a SA_ROLES=(
    "roles/editor"
    "roles/bigquery.admin"
    "roles/iam.serviceAccountAdmin"
    "roles/iam.serviceAccountTokenCreator"
    "roles/resourcemanager.projectIamAdmin"
    "roles/storage.admin"
    "roles/serviceusage.serviceUsageAdmin"
)

source "$SCRIPT_DIR/utils.sh"

trap 'log_error "Failed on line $LINENO"' ERR

# --- Usage ---
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

Set up a GCP project for local Terraform development:
  - Enable IAM Credentials API
  - Create a GCS bucket for Terraform state
  - Create a Terraform service account with required roles
  - Configure service account impersonation

Options:
    -p, --project ID      GCP project ID (default: $DEFAULT_PROJECT)
    -a, --account EMAIL   GCP account email (default: $DEFAULT_ACCOUNT)
    -l, --location LOC    GCS bucket location (default: $DEFAULT_LOCATION)
    -h, --help            Show this help message
EOF
    exit "${1:-0}"
}

# --- Argument parsing ---
parse_args() {
    PROJECT_ID="$DEFAULT_PROJECT"
    ACCOUNT_ID="$DEFAULT_ACCOUNT"
    LOCATION="$DEFAULT_LOCATION"

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
            -l|--location)
                LOCATION="$2"
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

# --- Steps ---
enable_credentials_api() {
    log_info "Enabling IAM Credentials API..."
    gcloud services enable iamcredentials.googleapis.com --project "$PROJECT_ID"
    log_info "IAM Credentials API enabled"
}

create_terraform_bucket() {
    local -r bucket_name="gs://${PROJECT_ID}-terraform-bucket"

    if gcloud storage buckets describe "$bucket_name" --project="$PROJECT_ID" &>/dev/null; then
        log_info "Bucket ${bucket_name} already exists, skipping"
        return 0
    fi

    log_info "Creating Terraform state bucket ${bucket_name}..."
    gcloud storage buckets create "$bucket_name" \
        --project="$PROJECT_ID" \
        --location="$LOCATION" \
        --uniform-bucket-level-access \
        --public-access-prevention \
        --soft-delete-duration=7d
    log_info "Bucket ${bucket_name} created"
}

create_service_account() {
    local -r sa_email="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

    if gcloud iam service-accounts describe "$sa_email" --project="$PROJECT_ID" &>/dev/null; then
        log_info "Service account ${sa_email} already exists, skipping"
        return 0
    fi

    log_info "Creating service account ${SA_NAME}..."
    gcloud iam service-accounts create "$SA_NAME" \
        --project="$PROJECT_ID" \
        --display-name="Terraform Service Account"
    log_info "Service account ${sa_email} created"
}

bind_iam_roles() {
    local -r sa_email="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

    log_info "Binding IAM roles to ${sa_email}..."
    for role in "${SA_ROLES[@]}"; do
        log_info "  Binding ${role}..."
        gcloud projects add-iam-policy-binding "$PROJECT_ID" \
            --member="serviceAccount:${sa_email}" \
            --role="$role" \
            --quiet
    done
    log_info "All IAM roles bound"
}

allow_impersonation() {
    local -r sa_email="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

    log_info "Granting ${ACCOUNT_ID} permission to impersonate ${sa_email}..."
    gcloud iam service-accounts add-iam-policy-binding "$sa_email" \
        --project="$PROJECT_ID" \
        --member="user:${ACCOUNT_ID}" \
        --role="roles/iam.serviceAccountTokenCreator"
    log_info "Impersonation permission granted"
}

reauthenticate_with_impersonation() {
    local -r sa_email="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

    log_info "Reauthenticating with service account impersonation..."
    gcloud auth application-default login \
        --project="$PROJECT_ID" \
        --impersonate-service-account="$sa_email" \
        --scopes="https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/drive"
    log_info "Authentication configured with impersonation"
}

# --- Main ---
main() {
    parse_args "$@"
    check_dependencies "gcloud"

    log_info "Setting up Terraform for project ${PROJECT_ID} (account: ${ACCOUNT_ID})"

    enable_credentials_api
    create_terraform_bucket
    create_service_account
    bind_iam_roles
    allow_impersonation
    reauthenticate_with_impersonation

    log_info "Terraform local setup complete for project ${PROJECT_ID}"
}

main "$@"
