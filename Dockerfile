# Build the manager binary
# Versión exacta de la base: "v1.26" es una etiqueta que se mueve. v1.26.1 es la
# base de la imagen oficial v0.2.2 que corre en el clúster de la UCT.
FROM quay.io/operator-framework/helm-operator:v1.26.1@sha256:e1dd3710bc06a41a2ab44c58212981189212e4b27b77fb91ea8d1c3f8cb371f9

ENV HOME=/opt/helm
COPY watches.yaml ${HOME}/watches.yaml
COPY helm-charts  ${HOME}/helm-charts
WORKDIR ${HOME}
