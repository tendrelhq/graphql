import { beforeAll, describe, expect, test } from "bun:test";
import Negotiator from "negotiator";
import { getAvailableLanguages } from "./i18n";

describe("i18n", () => {
  let availableLanguages: string[];

  beforeAll(async () => {
    availableLanguages = await getAvailableLanguages();
    availableLanguages = availableLanguages.slice(0, -2);
  });

  test("valid", () => {
    const n = new Negotiator({
      headers: {
        "accept-language": "en;q=0.8, es, pt",
      },
    });
    expect(n.language(availableLanguages)).toBe("es");
  });

  test("*", () => {
    const n = new Negotiator({
      headers: {
        "accept-language": "*",
      },
    });
    expect(n.language(availableLanguages)).toBe("af");
  });
});
