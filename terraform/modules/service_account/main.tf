resource "google_service_account" "sa" {
  account_id   = "${var.account_id}-${terraform.workspace}"
  description  = var.description
  display_name = var.display_name
}

resource "google_project_iam_member" "sa" {
  count  = length(var.roles)
  role   = element(var.roles, count.index)
  member = "serviceAccount:${google_service_account.sa.email}"
}
