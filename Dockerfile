# 1. Use a stable, widely supported version (3.3.x is usually safer if you aren't strictly tied to 4)
# If you MUST use 4.0.1, ensure it's consistent:
ARG RUBY_VERSION=4.0.1
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Install base packages (removed LD_PRELOAD for now to test if it's causing the exit 1)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

FROM base AS build
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# Ensure the bin folder is executable
RUN chmod +x bin/*

RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

FROM base
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

# Ensure we copy the bundle to the exact same location
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# IMPORTANT: Fix ownership so the 'rails' user can read the files
RUN chown -R rails:rails /rails "${BUNDLE_PATH}"

USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 8080
# Use 'bin/rails server' directly first to bypass Thruster for debugging
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "8080"]