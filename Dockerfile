
# Install dependencies only when needed
FROM node:17-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json ./
RUN npm install --frozen-lockfile

# Rebuild the source code only when needed
FROM node:alpine AS builder
WORKDIR /app
COPY . .
COPY --from=deps /app/node_modules ./node_modules

RUN export NODE_OPTIONS=--openssl-legacy-provider && npm run build && npm install --production --ignore-scripts --prefer-offline

# Production image, copy all the files and run next
FROM node:alpine AS runner
WORKDIR /app

ENV NODE_ENV production

RUN addgroup -g 1001 -S nodejs
RUN adduser -S hitechqb -u 1001
RUN chown -R 777 /app

# You only need to copy next.config.js if you are NOT using the default configuration
#COPY --from=builder /app/static ./static
COPY --from=builder --chown=hitechqb:nodejs /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/next.config.js ./next.config.js

USER hitechqb

EXPOSE 8060

CMD ["npm", "start", "-p", "8060"]
