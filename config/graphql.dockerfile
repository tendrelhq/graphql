FROM oven/bun:latest AS base
WORKDIR /usr/src/app

# Install dependencies into a temporary directory.
# This will will cache them and speed up future builds.
FROM base AS install
RUN mkdir -p /tmp/dev
COPY package.json bun.lockb /tmp/dev
RUN cd /tmp/dev && bun install --frozen-lockfile --ignore-scripts

# Production build.
FROM base AS build
ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV
COPY --from=install /tmp/dev/node_modules node_modules
COPY . .
RUN bun generate
RUN bun build --target=bun --outfile=dist/app.js ./bin/app.ts

# Runtime image.
FROM oven/bun:latest
COPY --from=build /usr/src/app/dist/app.js .
EXPOSE 4000/tcp
CMD ["bun", "app.js"]
