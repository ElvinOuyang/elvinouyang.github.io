#!/bin/bash
set -euo pipefail

# Only run in Claude Code on the web
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR"

# Use Ruby 3.2.6 (this project's github-pages gem is incompatible with 3.3+)
eval "$(rbenv init -)"
export RBENV_VERSION=3.2.6

# Persist Ruby version for the session
echo "export RBENV_VERSION=3.2.6" >> "$CLAUDE_ENV_FILE"
echo 'eval "$(rbenv init -)"' >> "$CLAUDE_ENV_FILE"

# Install bundler 2.x (required; bundler 4.x has CGI compatibility issues)
gem install bundler -v '~> 2.0' --no-document 2>/dev/null || true

# Install Ruby dependencies via Bundler
bundle install

# Verify Jekyll is available
bundle exec jekyll --version
