import { readFileSync } from "node:fs";

export const typeDefs = readFileSync(`${__dirname}/schema.graphql`, {
  encoding: "utf-8",
});

export type Context = {
  authScope?: string;
};
