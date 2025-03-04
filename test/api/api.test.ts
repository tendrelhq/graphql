import { describe, expect, test } from "bun:test";
import fs from "node:fs/promises";
import { baseurl } from "./constants";

const files = await fs.readdir(import.meta.dir);

// TODO: I'd really like to do it this way, by using .http files for the "test
// definition" and then executing them with `fetch` and using snapshots for test
// validation. Unfortunately there don't seem to be any .http parsers out there,
// nor any tools that can generically accomplish this so we have to implement
// the machinery ourselves :/
// This function therefore iterates over all .http files in the current
// directory. It creates a test suite for each file, and individual tests for
// each section in the http spec.
async function assembleTestSuite(file: string) {
  const contents = await Bun.file(`${import.meta.dir}/${file}`).text();
  const lines = contents.split("\n");
  const [method, url] = lines[1].split(" ", 2);

  describe.skip(file.replace(".http", ""), () => {
    test(`${method} /${url.split("/").at(-1)}`, async () => {
      const res = await fetch(url.replace("{{BASE_URL}}", baseurl), {
        method,
      });
      expect(res.json()).resolves.toMatchSnapshot();
    });
  });
}

for (const file of files) {
  if (file.endsWith(".http")) {
    await assembleTestSuite(file);
  }
}
