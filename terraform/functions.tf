# A common GCS bucket for storing ZIP files containing function libraries
resource "google_storage_bucket" "functions" {
  name = "functions-${var.project}-${terraform.workspace}"
}

module "google_gateway_hook" {
  source      = "../functions/google_gateway_hook"
  bucket_name = google_storage_bucket.functions.name
}
