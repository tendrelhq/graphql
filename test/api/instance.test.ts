import { describe, expect, test } from "bun:test";
import { baseurl } from "@/test/api/constants";

describe("/api/instance", () => {
  test("create", async () => {
    const url = new URL("/instance?select=id", baseurl);
    const response = await fetch(url, {
      method: "POST",
      headers: {
        Prefer: "return=representation, tx=rollback",
      },
      body: JSON.stringify({
        name: "this is a test",
        owner: "70f200bd-1c92-481d-9f5c-e6cf6cd92cd0",
      }),
    });
    expect(response.json()).resolves.toEqual([
      {
        id: expect.any(String),
      },
    ]);
  });

  test("read", async () => {
    const url = new URL(
      "/instance?select=id,display_name(value),fields(id,display_name(value)),template(id,display_name(value))&order=id",
      baseurl,
    );
    const response = await fetch(url, {
      method: "GET",
      headers: {
        Range: "0-19",
      },
    });
    expect(response.json()).resolves.toMatchSnapshot();
  });

  test.skip("update", async () => {
    const template = "not-a-real-uuid"; // FIXME: need a demo customer
    const url = new URL(
      `/instance?id=eq.${template}&select=id,_order`,
      baseurl,
    );
    const response = await fetch(url, {
      method: "PATCH",
      headers: {
        Prefer: "return=representation",
      },
      body: JSON.stringify({ _order: 2 }),
    });
    expect(response.json()).resolves.toMatchSnapshot();
  });

  test("delete", async () => {
    const template = "0001570b-d98f-4617-9e21-d248c24dece5"; // FIXME: need a demo customer
    const url = new URL(
      `/instance?id=eq.${template}&select=id,_deleted`,
      baseurl,
    );
    const response = await fetch(url, {
      method: "DELETE",
      headers: {
        // Use tx=rollback here while we get the test suites up and running.
        // Eventually we should use a generated customer like we do in the
        // existing runtime test suites.
        Prefer: "return=representation, tx=rollback",
      },
    });
    expect(response.json()).resolves.toMatchSnapshot();
  });
});
