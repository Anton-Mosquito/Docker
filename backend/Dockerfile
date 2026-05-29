# backend/Dockerfile (multi-stage: install production deps only)
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
# install only production dependencies to keep final image small
RUN npm ci --production

FROM node:18-alpine AS runtime
WORKDIR /app
# copy production node_modules from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NODE_ENV=production
EXPOSE 5000
CMD ["node", "--inspect=0.0.0.0:9229", "index.js"]

# test stage for CI
FROM node:18-alpine AS test
WORKDIR /app
COPY package*.json ./
# install dev + prod deps for tests
RUN npm ci
COPY . .
# default command when using the `test` target: runs tests and exits with code 0/1
CMD ["npm", "test"]
