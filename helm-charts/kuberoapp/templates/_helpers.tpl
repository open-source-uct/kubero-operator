{{/*
Expand the name of the chart.
*/}}
{{- define "kuberoapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kuberoapp.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "kuberoapp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kuberoapp.labels" -}}
helm.sh/chart: {{ include "kuberoapp.chart" . }}
{{ include "kuberoapp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kuberoapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kuberoapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kuberoapp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kuberoapp.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "kuberoapp.clone_url" -}}
{{- if .Values.gitrepo.admin }}
{{- .Values.gitrepo.ssh_url  }}
{{- else }}
{{- .Values.gitrepo.clone_url }}
{{- end }}
{{- end }}

{{/*
Estrategia de reemplazo de los pods. Un volumen ReadWriteOnce solo se conecta a
un nodo a la vez: con la actualización progresiva, el pod nuevo (a veces en otro
nodo) esperaba el volumen que seguía usando el pod viejo, y el viejo no se
apagaba hasta que el nuevo estuviera listo (Multi-Attach error). Con Recreate se
apaga el viejo primero. Las apps sin esos volúmenes no cambian.
rollingUpdate: null es necesario: al pasar un Deployment existente a Recreate,
Kubernetes rechaza el cambio si el campo rollingUpdate sigue presente.
*/}}
{{- define "kuberoapp.strategy" -}}
{{- $exclusive := false }}
{{- range .Values.extraVolumes }}
{{- if and (not .emptyDir) (or (has "ReadWriteOnce" (.accessModes | default list)) (has "ReadWriteOncePod" (.accessModes | default list))) }}
{{- $exclusive = true }}
{{- end }}
{{- end }}
{{- if $exclusive }}
strategy:
  type: Recreate
  rollingUpdate: null
{{- end }}
{{- end }}
