#!/bin/bash
set -e

# Run migrations
bin/rails db:prepare

# Precompile assets
bin/rails assets:precompile

# Start server
exec "$@"
