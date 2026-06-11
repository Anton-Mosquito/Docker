# docker/backend.Dockerfile
# Build context: project root (.)
# Usage: docker build -f docker/backend.Dockerfile .

# ── deps stage (prod-only deps) ───────────────────────────────────────────────
FROM node:20-alpine AS deps
ARG TARGETPLATFORM
RUN echo "Building for: $TARGETPLATFORM"
RUN apk upgrade --no-cache && npm install -g npm@latest
WORKDIR /app

# Copy package.json files for layer caching
COPY package.json package-lock.json ./
COPY apps/backend/package.json ./apps/backend/
COPY packages/shared/package.json ./packages/shared/

# install only production dependencies to keep final image small
RUN npm ci --omit=dev

# ── test stage (CI) ───────────────────────────────────────────────────────────
FROM node:20-alpine AS test
ARG TARGETPLATFORM
RUN echo "Building for: $TARGETPLATFORM"
RUN apk upgrade --no-cache && npm install -g npm@latest
WORKDIR /app

COPY package.json package-lock.json ./
COPY apps/backend/package.json ./apps/backend/
COPY packages/shared/package.json ./packages/shared/

# install dev + prod deps for tests
RUN npm ci

COPY apps/backend ./apps/backend
COPY packages/shared ./packages/shared

WORKDIR /app/apps/backend
USER node
# default command: runs tests and exits with code 0/1
CMD ["npm", "test"]

# ── runtime stage (production) ────────────────────────────────────────────────
FROM node:20-alpine AS runtime
ARG TARGETPLATFORM
RUN echo "Building for: $TARGETPLATFORM"
RUN apk upgrade --no-cache
WORKDIR /app

# copy production node_modules from deps stage
COPY --chown=node:node --from=deps /app/node_modules ./node_modules
# Also copy the app and shared code
COPY --chown=node:node apps/backend ./apps/backend
COPY --chown=node:node packages/shared ./packages/shared

WORKDIR /app/apps/backend
ENV NODE_ENV=production
EXPOSE 5000
USER node
CMD ["node", "index.js"]
