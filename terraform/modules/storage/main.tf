resource "google_storage_bucket" "main" {
  project                  = var.project_id
  location                 = var.location
  name                     = var.name
  storage_class            = var.storage_class
  public_access_prevention = var.public_access_prevention
}

resource "google_storage_bucket_iam_member" "main" {
  for_each = { for idx, m in var.iam_members : "${m.role}-${m.member}" => m }

  bucket = google_storage_bucket.main.name
  role   = each.value.role
  member = each.value.member
}
