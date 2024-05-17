import {
  ClerkExpressWithAuth,
  type StrictAuthProp,
} from "@clerk/clerk-sdk-node";

declare global {
  namespace Express {
    interface Request extends StrictAuthProp {}
  }
}

export type Auth = StrictAuthProp["auth"];

export default {
  clerk() {
    return ClerkExpressWithAuth({
      //
    });
  },
};
