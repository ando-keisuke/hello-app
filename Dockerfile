FROM oven/bun:1 AS base
WORKDIR /app

# ---- deps: install dependencies ----
FROM base AS deps
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

# ---- builder: build the Next.js app ----
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# NEXT_PUBLIC_* variables are inlined at build time.
# Pass them here via --build-arg if needed:
#   ARG NEXT_PUBLIC_EXAMPLE
#   ENV NEXT_PUBLIC_EXAMPLE=$NEXT_PUBLIC_EXAMPLE

RUN bun run build

# ---- runner: minimal production image ----
FROM oven/bun:1-slim AS runner
WORKDIR /app

ENV NODE_ENV=production

RUN groupadd --system --gid 1001 nodejs \
 && useradd --system --uid 1001 --gid 1001 --no-create-home nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

# These can all be overridden by K8s ConfigMap / Secret env vars at runtime.
# DATABASE_URL must be provided externally (e.g. via a Secret).
ENV PORT=3000 \
    HOSTNAME=0.0.0.0

CMD ["bun", "server.js"]
