import type { Loader as NameLoader } from "./schema/name";
import type { Loader as OrganizationLoader } from "./schema/organization";
import type { Loader as UserLoader } from "./schema/user";

export type AuthContext = {
  userId: string;
};

export type Context = {
  auth: AuthContext;
  //
  loaders: {
    name: NameLoader;
    organization: OrganizationLoader;
    user: UserLoader;
  };
};

export interface Node {
  id: string;
}
