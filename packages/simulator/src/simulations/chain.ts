import assert from "node:assert";
import { commitMutation } from "react-relay";
import Query, {
  type useSimulationStateMachineQuery as QueryType,
} from "../__generated__/useSimulationStateMachineQuery.graphql.ts";
import config from "../config";
import {
  AdvanceTaskMutation,
  type UseAdvanceTaskMutation,
} from "../hooks/useAdvanceTask";
import type { System } from "../rex";
import { choose } from "../rng";

export { Query, type QueryType };

const system: System<QueryType> = function (query) {
  assert(query.node.__typename === "Task");
  if (query.node.state?.__typename === "Closed") {
    this.remove();
    return [];
  }

  const { active, transitions } = query.node.fsm ?? {};
  assert(active || transitions?.totalCount);

  const { hash, id } = query.node;

  if (active && config.active_probability()) {
    if (id === active.id && config.root_probability() === false) {
      // Sometimes it is helpful to delay the final close.
      return [];
    }

    // Do the active.
    return [
      () => {
        return new Promise((resolve, reject) => {
          commitMutation<UseAdvanceTaskMutation>(this.rex.environment, {
            mutation: AdvanceTaskMutation,
            variables: {
              root: { hash, id },
              choice: {
                hash: active.hash,
                id: active.id,
              },
            },
            onCompleted: resolve,
            onError: reject,
          });
        });
      },
    ];
  }

  if (transitions?.totalCount) {
    // Make a choice.
    const choice = choose(transitions.edges);
    return [
      () => {
        return new Promise((resolve, reject) => {
          commitMutation<UseAdvanceTaskMutation>(this.rex.environment, {
            mutation: AdvanceTaskMutation,
            variables: {
              root: { hash, id },
              choice: {
                hash: "", // doesn't matter right now
                id: choice.id,
              },
            },
            onCompleted: resolve,
            onError: reject,
          });
        });
      },
    ];
  }

  return [];
};

export default system;
