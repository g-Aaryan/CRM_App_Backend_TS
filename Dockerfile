# =========================
# Stage 1: Builder
# =========================

FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install all dependencies
RUN npm ci

# Copy source code
COPY . .

RUN npx prisma generate

# Compile TypeScript → dist/
RUN npm run build

# Remove development dependencies
RUN npm prune --omit=dev


# =========================
# Stage 2: Production
# =========================

FROM gcr.io/distroless/nodejs20-debian12

WORKDIR /app

# Copy production dependencies
COPY --from=builder /app/node_modules ./node_modules

# Copy compiled application
COPY --from=builder /app/dist ./dist

# Container port
EXPOSE 5000

# Start application
CMD ["dist/index.js"]