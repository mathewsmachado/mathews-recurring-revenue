module "service" {
  source = "../../modules/service"

  project_id = var.project_id
  services   = toset(local.shared.services)
}

module "artifact_registry" {
  source = "../../modules/artifact-registry"

  project_id    = var.project_id
  location      = local.shared.project_region
  repository_id = local.shared.artifact_registry.repository_id
  description   = local.shared.artifact_registry.description

  depends_on = [module.service]
}

module "bigquery" {
  source = "../../modules/bigquery"

  project_id    = var.project_id
  location      = local.shared.project_location
  dataset_id    = local.shared.bigquery.dataset_id
  friendly_name = local.shared.bigquery.friendly_name

  google_sheets_tables = {
    for key, table in local.shared.bigquery.tables : key => merge(table, {
      schema_json = file("../../shared/schemas/${key}.json")
    })
  }
}

module "dbt_project_bucket" {
  source = "../../modules/storage"

  project_id = var.project_id
  location   = local.shared.project_location
  name       = "${var.project_id}-${local.shared.storage.dbt_project_bucket_suffix}"
}

module "dbt_project_sa" {
  source = "../../modules/service-accounts"

  project_id   = var.project_id
  account_id   = local.shared.service_accounts.dbt_project.account_id
  display_name = local.shared.service_accounts.dbt_project.display_name
  description  = local.shared.service_accounts.dbt_project.description
  roles        = toset(local.shared.service_accounts.dbt_project.roles)
  workload_identity_members = [local.wif_member]

  depends_on = [module.service]
}

module "evidence_sa" {
  source = "../../modules/service-accounts"

  project_id   = var.project_id
  account_id   = local.shared.service_accounts.evidence.account_id
  display_name = local.shared.service_accounts.evidence.display_name
  description  = local.shared.service_accounts.evidence.description
  roles        = toset(local.shared.service_accounts.evidence.roles)
  workload_identity_members = [local.wif_member]

  depends_on = [module.service]
}
