FROM oven/bun:latest AS base
WORKDIR /usr/src/app

# install dependencies into a temporary directory.
# this will will cache them and speed up future builds.
FROM base AS install
RUN mkdir -p /tmp/dev
COPY package.json bun.lockb .env* /tmp/dev
RUN cd /tmp/dev && bun install --frozen-lockfile

# copy production dependencies into temporary directory.
# "production" =: exclude devDependencies
RUN mkdir -p /tmp/prod
COPY package.json bun.lockb .env* /tmp/prod
RUN cd /tmp/prod && bun install --frozen-lockfile --production

# copy node_modules from temporary directory.
# then copy all (non-ignored) project files into the image
FROM base AS prerelease
COPY --from=install /tmp/dev/node_modules node_modules
COPY . .

# test and build
ARG NODE_ENV=production
RUN bun compile
RUN CI=true DATABASE_URL=postgres://localhost:5432/postgres bun test

# copy production dependencies and source code into final image.
FROM base AS release
COPY --from=prerelease /usr/src/app .

# run the app
USER bun
EXPOSE 4000/tcp
CMD ["bun", "start+tracing"]
