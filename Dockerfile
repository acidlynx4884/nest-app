# syntax=docker/dockerfile:1

FROM node:22-alpine AS base

RUN corepack enable && corepack prepare pnpm@10.33.2 --activate

WORKDIR /app

FROM base AS deps

COPY package.json pnpm-lock.yaml ./

RUN pnpm install --frozen-lockfile

FROM base AS builder

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Prisma generate only needs a valid URL shape, not a live database.
ENV DATABASE_URL="postgresql://postgres:postgres@localhost:5432/app?schema=public"

RUN pnpm exec prisma generate
RUN pnpm run build
RUN pnpm prune --prod

FROM base AS production

ENV NODE_ENV=production

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json

USER node

EXPOSE 3000

CMD ["node", "dist/src/main.js"]
