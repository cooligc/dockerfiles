#!/bin/bash
set -e
service="$SERVICE"

echo "Starting Dropwizard service $service..."

echo "Running with options: '$@'"
if [ -z "$JAVA_OPTS" ]; then
  exec java -jar $@ "${service}.jar" server dev.yml
else
  echo "Running with JAVA_OPTS: '$JAVA_OPTS'"
  exec java $JAVA_OPTS -jar $@ "${service}.jar" server dev.yml
fi
