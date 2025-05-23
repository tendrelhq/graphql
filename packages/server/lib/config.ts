import { z } from "zod";

const e = process.env;

/**
 * The base url of the *gateway* (i.e. the nginx reverse proxy).
 */
export const base_url = z
  .string()
  .default("http://localhost:80")
  .transform(s => new URL(s))
  .parse(e.BASE_URL);

export const pgrst_url = new URL("/api/v1", base_url);

/**
 * Port that the graphql server listens on.
 */
export const port = z.number().default(4000).parse(e.PORT);

/**
 * The `iss` claim to set in the temporary JWT used for the OAuth token exchange.
 */
export const jwt_iss = z.string().default("urn:tendrel:dev").parse(e.JWT_ISS);

export default {
  base_url,
  jwt_iss,
  pgrst_url,
  port,
};
