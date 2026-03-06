# Build stage for Vite frontend
FROM node:22-alpine AS builder
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy source code and build frontend
COPY . .
RUN npm run build

# Production stage for Express server
FROM node:22-alpine
WORKDIR /app

# Install only production dependencies
COPY package*.json ./
RUN npm ci --omit=dev && npm install tsx --save-dev

# Copy built frontend assets
COPY --from=builder /app/dist ./dist

# Copy backend files needed to run the server
COPY server.ts constants.ts ./
COPY utils ./utils
COPY services ./services

# Copy entrypoint script for injecting environment variables
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Cloud Run expects the app to listen on PORT (default 8080)
ENV NODE_ENV=production
ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Use tsx to run the TypeScript server directly
CMD ["npx", "tsx", "server.ts"]
