resource "google_storage_bucket_object" "function" {
  name                = format("%s.%s.zip", var.name, filesha256("${path.root}/../functions/${var.name}/dist/bundle.zip"))
  bucket              = var.bucket_name
  source              = "${path.root}/../functions/${var.name}/dist/bundle.zip"
  content_disposition = "attachment"
  content_encoding    = "gzip"
  content_type        = "application/zip"
}

resource "google_cloudfunctions_function" "function" {
  name                  = "${var.name}_${terraform.workspace}"
  description           = var.description
  runtime               = "python38"
  entry_point           = var.entry_point
  service_account_email = var.service_account_email

  available_memory_mb   = var.available_memory_mb
  source_archive_bucket = var.bucket_name
  source_archive_object = google_storage_bucket_object.function.name
  trigger_http          = true
  timeout               = 540

  timeouts {
    create = "15m"
    update = "15m"
  }
}

resource "google_cloudfunctions_function_iam_member" "function" {
  count = var.allow_unauthenticated_invocations ? 1 : 0

  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
