#!/bin/bash

set -euxo pipefail

podman start registry2

curl -k -u alvaro:mypass https://localhost:5000/v2/
