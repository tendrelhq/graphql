import { Faker, base, en } from "@faker-js/faker";
import { z } from "zod";

export const seed = z
  .number({ coerce: true })
  .gt(0)
  .default(() => Date.now())
  .describe("Seed value used to initialize the PRNG")
  .parse(process.env.SEED);

export const faker = new Faker({ locale: [en, base], seed });

export function choose<T>(choices: readonly T[]) {
  return choices[faker.number.int(choices.length - 1)];
}
