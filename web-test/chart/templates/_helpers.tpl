{{/*
  _helpers.tpl
  ------------
  This file contains reusable template "helper" functions for the chart.
  Helm uses the prefix "define" to create named templates that can be
  called from other template files like deployment.yaml, service.yaml, etc.

  The convention is to prefix all helper names with the chart name
  to avoid conflicts if this chart is used as a subchart later.
*/}}


{{/*
  test-website.name
  -----------------
  Returns the name of the chart.
  The "trunc 63" trims the name to 63 characters, which is the maximum
  length allowed for Kubernetes resource names.
  "trimSuffix" removes any trailing hyphens that might appear after trimming.
*/}}
{{- define "test-website.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
  test-website.fullname
  ---------------------
  Returns the full name used for Kubernetes resources like Deployments,
  Services, ConfigMaps, etc.

  It combines the Helm release name (e.g. "my-release") with the chart name
  (e.g. "test-website") to produce something like "my-release-test-website".

  If the release name already contains the chart name, it just uses the
  release name to avoid duplication like "test-website-test-website".

  This is the most commonly used helper in your templates.
  Example usage in deployment.yaml:
    name: {{ include "test-website.fullname" . }}
*/}}
{{- define "test-website.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}


{{/*
  test-website.chart
  ------------------
  Returns the chart name and version as a single string.
  Example output: "test-website-0.1.0"

  This is typically used as a label on Kubernetes resources so you can
  always tell which chart version deployed a given resource.
*/}}
{{- define "test-website.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
  test-website.labels
  -------------------
  Returns a standard set of Kubernetes labels to apply to all resources.
  Having consistent labels across all resources makes it easy to:
  - filter resources with kubectl (e.g. kubectl get all -l app.kubernetes.io/name=test-website)
  - identify which Helm release and chart version owns a resource
  - use selectors in Services and Deployments
*/}}
{{- define "test-website.labels" -}}
helm.sh/chart: {{ include "test-website.chart" . }}
{{ include "test-website.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
  test-website.selectorLabels
  ---------------------------
  Returns a minimal set of labels used specifically for pod selectors.
  These are used in:
  - spec.selector.matchLabels in the Deployment
  - spec.selector in the Service

  IMPORTANT: These labels should never change after the first deployment,
  because Kubernetes uses them to match pods to services and deployments.
*/}}
{{- define "test-website.selectorLabels" -}}
app.kubernetes.io/name: {{ include "test-website.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}