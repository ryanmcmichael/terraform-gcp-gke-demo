resource "google_pubsub_topic" "hasura-topic" {
  name = "backup-hasura"
}

resource "google_cloud_scheduler_job" "job" {
  name        = "backup-hasura"
  description = "Hasura backup"
  schedule    = "* */12 * * *"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.hasura-topic.id
    data       = base64encode("test")
  }
}

resource "google_pubsub_topic" "bt-topic" {
  name = "backup-bt"
}

resource "google_cloud_scheduler_job" "job2" {
  name        = "backup-bt"
  description = "BT backup"
  schedule    = "* */12 * * *"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.bt-topic.id
    data       = base64encode("test")
  }
}
