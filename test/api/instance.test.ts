import { describe, expect, test } from "bun:test";
import { baseurl } from "@/test/api/constants";
import { pg } from "../prelude";

describe.skip("/api/instance", () => {
  test("create", async () => {
    const response = await pg
      .from("entity_instance")
      .insert({
        owner: "f90d618d-5de7-4126-8c65-0afb700c6c61",
        template: "0b9f3142-e7ed-4f78-8504-ccd2eb505075",
        name: "My first instance!",
        type: "67af22cb-3183-4e6e-8542-7968f744965a",
      })
      .select("id,name")
      .rollback();
    expect(response).toMatchObject({
      data: expect.arrayContaining([
        {
          id: expect.any(String),
          name: "My first instance!",
        },
      ]),
      status: 201,
    });
  });

  test.skip("read", async () => {
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

  test.skip("delete", async () => {
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
