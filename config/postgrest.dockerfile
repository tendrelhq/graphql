FROM nixos/nix:latest AS builder

COPY . /tmp/build
WORKDIR /tmp/build

RUN nix \
      --extra-experimental-features "nix-command flakes" \
      --accept-flake-config \
      build .#postgrest

RUN mkdir /tmp/nix-store-closure
RUN cp -R $(nix-store -qR result/) /tmp/nix-store-closure

FROM scratch
WORKDIR /app
COPY --from=builder /tmp/nix-store-closure /nix/store
COPY --from=builder /tmp/build/result /app

HEALTHCHECK --start-period=30s --start-interval=1s CMD ["/app/bin/healthcheck"]
ENTRYPOINT ["/app/bin/entrypoint"]
