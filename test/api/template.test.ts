import { describe, expect, test } from "bun:test";
import { baseurl } from "@/test/api/constants";
import { pg } from "../prelude";

describe("/api/template", () => {
  test("create", async () => {
    const response = await pg
      .from("entity_template")
      .insert({
        owner: "f90d618d-5de7-4126-8c65-0afb700c6c61",
        name: "My first template!",
      })
      .select("name")
      .rollback();
    expect(response).toMatchObject({
      data: expect.arrayContaining([
        {
          name: "My first template!",
        },
      ]),
      status: 201,
    });
  });

  test.skip("read", async () => {
    const url = new URL(
      "/template?select=id,display_name(value),fields(id,display_name(value),type(id,display_name(value)))&order=id",
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
      `/template?id=eq.${template}&select=id,_order`,
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
    const owner = "f90d618d-5de7-4126-8c65-0afb700c6c61";
    const template = "0b9f3142-e7ed-4f78-8504-ccd2eb505075";
    const response = await pg
      .rpc("delete_entity_template", { owner, id: template })
      .select("id,_deleted")
      .rollback();
    expect(response).toMatchSnapshot();
  });
});
