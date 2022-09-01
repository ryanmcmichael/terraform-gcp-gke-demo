data "google_secret_manager_secret_version" "datadog_api_key" {
  secret = "datadog-api-key"
}

data "google_secret_manager_secret_version" "datadog_application_key" {
  secret = "datadog-application-key"
}

provider "datadog" {
  api_key = data.google_secret_manager_secret_version.datadog_api_key.secret_data
  app_key = data.google_secret_manager_secret_version.datadog_application_key.secret_data
}

resource "helm_release" "datadog_agent" {
  name       = "datadog-agent"
  chart      = "datadog"
  repository = "https://helm.datadoghq.com"
  version    = "2.10.1"
  namespace  = kubernetes_namespace.functions_namespace.metadata.0.name

  set {
    name  = "service.annotations.container\\.apparmor\\.security\\.beta\\.kubernetes\\.io/system-probe"
    value = "unconfined"
    type  = "string"
  }

  set_sensitive {
    name  = "datadog.apiKey"
    value = data.google_secret_manager_secret_version.datadog_api_key.secret_data
  }

  set {
    name  = "datadog.logs.enabled"
    value = true
  }

  set {
    name  = "datadog.logs.containerCollectAll"
    value = true
  }

  set {
    name  = "datadog.leaderElection"
    value = true
  }

  set {
    name  = "datadog.collectEvents"
    value = true
  }

  set {
    name  = "clusterAgent.enabled"
    value = true
  }

  set {
    name  = "clusterAgent.metricsProvider.enabled"
    value = true
  }

  set {
    name  = "networkMonitoring.enabled"
    value = true
  }

  set {
    name  = "systemProbe.enableTCPQueueLength"
    value = true
  }

  set {
    name  = "systemProbe.enableOOMKill"
    value = true
  }

  set {
    name  = "securityAgent.runtime.enabled"
    value = true
  }

  set {
    name  = "datadog.hostVolumeMountPropagation"
    value = "HostToContainer"
  }

  set {
    name  = "datadog.apm.enabled"
    value = true
  }

  set {
    name  = "datadog.apm.portEnabled"
    value = true
  }

  set {
    name  = "agent.apm.enabled"
    value = true
  }

  set {
    name  = "agents.containers.traceAgent.logLevel"
    value = "info"
  }

  set {
    name  = "datadog.dogstatsd.port"
    value = 8125
  }

  set {
    name  = "datadog.dogstatsd.nonLocalTraffic"
    value = true
  }

  set {
    name  = "datadog.dogstatsd.useHostPort"
    value = true
  }

  set {
    name  = "datadog.logLevel"
    value = "INFO"
  }
}
