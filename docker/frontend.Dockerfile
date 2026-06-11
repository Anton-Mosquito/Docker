# docker/frontend.Dockerfile
# Build context: project root (.)
# Usage: docker build -f docker/frontend.Dockerfile .

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

# Install dependencies (npm workspaces)
RUN npm ci

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

# install all dependencies (including dev deps like vite)
RUN npm ci

COPY apps/frontend ./apps/frontend
COPY packages/shared ./packages/shared

WORKDIR /app/apps/frontend
RUN npm run build
RUN chown -R node:node /app
USER node

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

# install dev deps required for tests
RUN npm ci

COPY apps/frontend ./apps/frontend
COPY packages/shared ./packages/shared

WORKDIR /app/apps/frontend
RUN chown -R node:node /app
USER node
# default command: runs tests and exits with code 0/1
CMD ["npm", "test"]

# ── prod stage ────────────────────────────────────────────────────────────────
FROM nginx:alpine AS prod
ARG TARGETPLATFORM
RUN echo "Building for: $TARGETPLATFORM"
RUN apk upgrade --no-cache
# Replace default config with custom one
COPY apps/frontend/nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app/apps/frontend/dist /usr/share/nginx/html
USER nginx
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
