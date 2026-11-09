ARG NODE_VERSION=24.13.1
FROM node:${NODE_VERSION}-slim AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate

FROM base AS prepare
WORKDIR /app
COPY package.json . 
RUN pnpm add -g turbo
COPY . .
RUN turbo prune backend --docker

FROM base AS builder
WORKDIR /app

COPY --from=prepare /app/out/json/ .
RUN pnpm install --frozen-lockfile

COPY --from=prepare /app/out/full/ .
# no build step since we will use tsx
RUN cd packages/database && pnpm exec prisma generate

FROM base AS runner
WORKDIR /app
RUN pnpm add -g tsx@4.21.0

# Don't run production as root , security problem
RUN addgroup --system --gid 1001 expressjs
RUN adduser --system --uid 1001 expressjs
USER expressjs
COPY --from=builder /app .

EXPOSE 3001
CMD ["tsx","apps/backend/src/index.ts"] 
