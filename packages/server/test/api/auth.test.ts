import { describe, expect, test } from "bun:test";
import config from "@/config";

describe("/api/token", () => {
  test("login", async () => {
    const url = new URL("/api/v1/login", config.base_url);
    const res1 = await fetch(url, {
      method: "POST",
      headers: {
        "X-Tendrel-User": "fake-for-testing",
      },
    });

    const login = await res1.json();
    expect(login).toEqual({
      access_token: expect.any(String),
      issued_token_type: "urn:ietf:params:oauth:token-type:jwt",
      token_type: "Bearer",
    });

    const res2 = await fetch(
      new URL("/api/v1/rpc/token_introspect", config.base_url),
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${login.access_token}`,
        },
        body: JSON.stringify({
          token: login.access_token,
        }),
      },
    );
    const introspection = await res2.json();
    expect(introspection).toEqual({
      active: true,
      exp: expect.any(Number),
      iat: expect.any(Number),
      iss: "urn:tendrel:test", // Bleh. An artefact of pg_dump :/
      nbf: expect.any(Number),
      owner: null,
      role: "authenticated",
      scope: null,
      sub: "fake-for-testing",
    });
  });
});
