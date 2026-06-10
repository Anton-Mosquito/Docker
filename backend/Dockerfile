# backend/Dockerfile (multi-stage: install production deps only)
FROM node:20-alpine AS deps
RUN apk upgrade --no-cache && npm install -g npm@latest
WORKDIR /app
COPY --chown=node:node package*.json ./
# install only production dependencies to keep final image small
RUN npm ci --production

# test stage for CI
FROM node:20-alpine AS test
RUN apk upgrade --no-cache && npm install -g npm@latest
WORKDIR /app
COPY --chown=node:node package*.json ./
# install dev + prod deps for tests
RUN npm ci
COPY --chown=node:node . .
USER node
# default command when using the `test` target: runs tests and exits with code 0/1
CMD ["npm", "test"]

FROM node:20-alpine AS runtime
RUN apk upgrade --no-cache
WORKDIR /app
# copy production node_modules from deps stage
COPY --chown=node:node --from=deps /app/node_modules ./node_modules
COPY --chown=node:node . .
ENV NODE_ENV=production
EXPOSE 5000
USER node
CMD ["node", "--inspect=0.0.0.0:9229", "index.js"]
