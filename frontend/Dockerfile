# dev stage
FROM node:20-alpine AS dev
RUN apk upgrade --no-cache
WORKDIR /app
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL
COPY package*.json ./
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]


FROM node:20-alpine AS builder
RUN apk upgrade --no-cache
WORKDIR /app
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL
COPY package*.json ./
# install all dependencies in the builder (including dev deps like vite)
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS test
RUN apk upgrade --no-cache
WORKDIR /app
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL
COPY package*.json ./
# install dev deps required for tests
RUN npm ci
COPY . .
# default command when using the `test` target: runs tests and exits with code 0/1
CMD ["npm", "test"]

FROM nginx:alpine AS prod
RUN apk upgrade --no-cache
# Replace default config with custom one
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
