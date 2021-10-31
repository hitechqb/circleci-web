
# Install dependencies only when needed
FROM node:alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --frozen-lockfile

# Rebuild the source code only when needed
FROM node:alpine AS builder
WORKDIR /usr/src/app
COPY . .
COPY --from=deps /usr/src/app/node_modules ./node_modules

RUN export NODE_OPTIONS=--openssl-legacy-provider && npm run build && npm install --production --ignore-scripts --prefer-offline

# Production image, copy all the files and run next
FROM node:alpine AS runner
WORKDIR /usr/src/app

ENV NODE_ENV production

RUN addgroup -g 1001 -S nodejs
RUN adduser -S hitechqb -u 1001
RUN chown -R 777 /usr/src/app

# You only need to copy next.config.js if you are NOT using the default configuration
#COPY --from=builder /app/static ./static
COPY --from=builder /usr/src/app/public ./public
COPY --from=builder --chown=hitechqb:nodejs /usr/src/app/.next ./.next
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/package.json ./package.json
COPY --from=builder /usr/src/app/next.config.js ./next.config.js

USER hitechqb

EXPOSE 6060

CMD ["npm", "start"]
