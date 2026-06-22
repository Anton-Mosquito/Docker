# docker/frontend.Dockerfile
# Build context: project root (.)
# Usage: docker build -f docker/frontend.Dockerfile .

# ── Shared rolldown binding fix ────────────────────────────────────────────────
# Vite 6+ uses rolldown which has platform-native bindings as optional deps.
# npm ci follows package-lock.json strictly — when the lockfile was generated on
# macOS, it only records @rolldown/binding-darwin-arm64. Running on Linux/Docker
# means @rolldown/binding-linux-{arch}-musl is missing (npm bug #4828).
# Fix: after npm ci, detect arch and install the correct Linux musl binding.
# This 2-liner is repeated in every stage that runs Vite (dev/builder/test).

# ── dev stage ────────────────────────────────────────────────────────────────
FROM node:20-alpine AS dev
ARG TARGETPLATFORM
RUN echo "Building for: $TARGETPLATFORM"
RUN apk upgrade --no-cache
WORKDIR /app
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

# Copy package.json files for layer caching
COPY package.json package-lock.json ./
COPY apps/frontend/package.json ./apps/frontend/
COPY packages/shared/package.json ./packages/shared/

# Install + rolldown native binding fix (see comment at top)
RUN npm ci
RUN ARCH=$(uname -m | sed 's/x86_64/x64/;s/aarch64/arm64/') && \
    npm install --no-save "@rolldown/binding-linux-${ARCH}-musl" 2>/dev/null || true

# Copy the rest of the code
COPY apps/frontend ./apps/frontend
COPY packages/shared ./packages/shared

WORKDIR /app/apps/frontend
RUN chown -R node:node /app
USER node
EXPOSE 3000
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]

# ── builder stage ─────────────────────────────────────────────────────────────
FROM node:20-alpine AS builder
ARG TARGETPLATFORM
RUN echo "Building for: $TARGETPLATFORM"
RUN apk upgrade --no-cache
WORKDIR /app
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

COPY package.json package-lock.json ./
COPY apps/frontend/package.json ./apps/frontend/
COPY packages/shared/package.json ./packages/shared/

# Install + rolldown native binding fix (see comment at top)
RUN npm ci
RUN ARCH=$(uname -m | sed 's/x86_64/x64/;s/aarch64/arm64/') && \
    npm install --no-save "@rolldown/binding-linux-${ARCH}-musl" 2>/dev/null || true

COPY apps/frontend ./apps/frontend
COPY packages/shared ./packages/shared

WORKDIR /app/apps/frontend
RUN npm run build

# ── test stage ────────────────────────────────────────────────────────────────
FROM node:20-alpine AS test
ARG TARGETPLATFORM
RUN echo "Building for: $TARGETPLATFORM"
RUN apk upgrade --no-cache
WORKDIR /app
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

COPY package.json package-lock.json ./
COPY apps/frontend/package.json ./apps/frontend/
COPY packages/shared/package.json ./packages/shared/

# Install + rolldown native binding fix (see comment at top)
RUN npm ci
RUN ARCH=$(uname -m | sed 's/x86_64/x64/;s/aarch64/arm64/') && \
    npm install --no-save "@rolldown/binding-linux-${ARCH}-musl" 2>/dev/null || true

COPY apps/frontend ./apps/frontend
COPY packages/shared ./packages/shared

WORKDIR /app/apps/frontend
RUN chown -R node:node /app
USER node
CMD ["npm", "test"]

# ── prod stage ────────────────────────────────────────────────────────────────
# nginx only — no Node.js, no rolldown, no fix needed
FROM nginx:alpine AS prod
ARG TARGETPLATFORM
RUN echo "Building for: $TARGETPLATFORM"
RUN apk upgrade --no-cache
COPY apps/frontend/nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app/apps/frontend/dist /usr/share/nginx/html
USER nginx
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
