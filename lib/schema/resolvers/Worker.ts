import type { WorkerResolvers } from "@/schema";

export const Worker: WorkerResolvers = {
  language(parent, _, ctx) {
    return ctx.orm.language.load(parent.language_id as string);
  },
  tags() {
    return [];
  },
};
