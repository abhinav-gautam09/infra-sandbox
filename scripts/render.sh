#!/bin/sh
set -eu

values="helm-overrides/non-prod/dso/ap-south-1/hello-web/values.yaml"
helm template hello-web helm-charts/hello-web -f "$values"
