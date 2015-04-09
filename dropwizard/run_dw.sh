#!/bin/bash
set -e
service="$SERVICE"

echo "Starting Dropwizard service $service..."

echo "Running with options: '$@'"
    exec java -jar $@ "${service}.jar" server dev.yml
fi
