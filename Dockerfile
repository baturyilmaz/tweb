FROM node:18-alpine AS builder

WORKDIR /app

RUN npm install -g pnpm@9.15.3

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm run build

FROM node:18-alpine AS production

RUN addgroup -g 1001 -S nodejs && \
    adduser -S app -u 1001

WORKDIR /app

RUN npm install -g pnpm@9.15.3

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile && \
    pnpm store prune

COPY --from=builder /app/public ./public
COPY --from=builder /app/server.js ./server.js

RUN chown -R app:nodejs /app

USER app

ENV PORT=3000
EXPOSE 3000

CMD ["sh", "-c", "node server.js '' ${PORT:-3000}"]