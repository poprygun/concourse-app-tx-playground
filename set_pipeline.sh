#!/bin/bash

__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PIPELINE_NAME=${2:-chachkies}
ALIAS=${3:-my-target}
CREDENTIALS=${4:-credentials.yml}

fly -t "${ALIAS}" sp -p "${PIPELINE_NAME}" -c "${__DIR}/pipeline.yml" -l "${__DIR}/${CREDENTIALS}" -n
