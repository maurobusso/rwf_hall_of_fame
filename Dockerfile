# ... (ARG and FROM base as before)

# 1. Optimize Base Packages
# Adding 'libpq5' explicitly ensures the runtime has the Postgres driver without the full dev headers
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    postgresql-client \
    libpq5 && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# ... (ENV settings as before)

FROM base AS build

# 2. Only install build-essential headers here
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    libyaml-dev \
    pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# ... (Bundle install and Copy code as before)

# 3. Final Stage: Ensure the Port is handled correctly
FROM base

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

# Create necessary dirs for Thruster/Rails cache
RUN mkdir -p /rails/tmp /rails/log && chown -R rails:rails /rails/tmp /rails/log

USER 1000:1000

COPY --chown=rails:rails --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --chown=rails:rails --from=build /rails /rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Use 8080 as the standard for Cloud Run
EXPOSE 8080

# If using Thruster, ensure Rails is running on its internal default
# so Thruster can wrap it and present it on $PORT
CMD ["./bin/thrust", "./bin/rails", "server"]