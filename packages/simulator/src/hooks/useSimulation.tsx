import assert from "node:assert";
import { Box, Text, useInput } from "ink";
import { Suspense, useEffect, useState } from "react";
import {
  commitLocalUpdate,
  useClientQuery,
  useLazyLoadQuery,
} from "react-relay";
import { match } from "ts-pattern";
import ActiveQueryNode, {
  type useSimulationActiveQuery as ActiveQuery,
  type TaskStateName,
} from "../__generated__/useSimulationActiveQuery.graphql";
import SimulationQueryNode, {
  type SimulationState,
  type useSimulationQuery as SimulationQuery,
} from "../__generated__/useSimulationQuery.graphql";
import Loading from "../components/Loading";
import { TaskChain, TaskId, TaskName } from "../components/Task";
import config from "../config";
import { anyModifier } from "../lib/ink";
import type { System } from "../rex";
import taskChainSimulation, {
  Query as TaskChainSimulationQuery,
} from "../simulations/chain";
import { useRex } from "./useRex";
import { useTaskState } from "./useTask";

interface SimulatorProps {
  owner: string;
  template: string;
}

export function Simulator(props: SimulatorProps) {
  const data = useClientQuery<SimulationQuery>(SimulationQueryNode, {});
  const rex = useRex();

  useEffect(() => {
    if (!data.simulation) {
      commitLocalUpdate(rex.environment, store => {
        const r = store
          .getRoot()
          .getOrCreateLinkedRecord("simulation", "Simulation")
          .setValue("starting" satisfies SimulationState, "state")
          .setValue(0, "time");
        assert(r, "failed to create simulation");
      });

      rex.start();
    }
  }, [data, rex]);

  if (!data.simulation) {
    return <Loading />;
  }

  return match(data.simulation.state)
    .with("starting", () => <Starting {...props} />)
    .otherwise(() => <Running {...props} />);
}

function Starting(props: SimulatorProps) {
  const rex = useRex();

  useEffect(() => {
    return rex.addSystem(startSimulation, {
      request: ActiveQueryNode,
      variables: props,
    });
  }, [rex, props]);

  return <Loading message="Starting..." />;
}

function Running(props: SimulatorProps) {
  const { simulation } = useClientQuery<SimulationQuery>(
    SimulationQueryNode,
    {},
  );
  assert(simulation);

  const [chainLagN, setChainLagN] = useState(config.chain_lag_n);
  const [showFullChain, setShowFullChain] = useState(config.show_full_chain);

  useInput((input, key) => {
    switch (true) {
      case input === "+" && !anyModifier(key):
        setChainLagN(n => n + 1);
        break;
      case input === "-" && !anyModifier(key):
        setChainLagN(n => Math.max(n - 1, 0));
        break;
      case input === "=" && !anyModifier(key):
        setChainLagN(config.chain_lag_n);
        setShowFullChain(config.show_full_chain);
        break;
      case input === "v" && !anyModifier(key):
        setShowFullChain(b => !b);
        break;
    }
  });

  return (
    <Box flexDirection="column">
      <Box gap={1}>
        <Text>[{simulation.state ?? "-"}]</Text>
        <Text>t={simulation.time ?? "-"}</Text>
      </Box>
      <Suspense>
        <InstancesOf
          chainLagN={chainLagN}
          showFullChain={showFullChain}
          withState={["InProgress"]}
          {...props}
        />
        <Box height={1} />
        <Text color="gray">
          <Text bold>chain_lag_n={chainLagN}</Text> : use +/- to change
        </Text>
        <Text color="gray">
          <Text bold>show_full_chain={Number(showFullChain)}</Text> : use v to
          toggle
        </Text>
        <Text color="gray">use = to reset to defaults</Text>
      </Suspense>
    </Box>
  );
}

const startSimulation: System<ActiveQuery> = function (query) {
  assert(query.simulation?.state === "starting");
  return [
    async () => {
      // Hmm. Actually a note here: if there are multiple systems at
      // play, it will be possible for them to conflict. Consider: two
      // systems operate on the simulation in the 'starting' state.
      // One decides to promote the sim to 'active' while the other
      // decides to demote it to 'stopped'.
      commitLocalUpdate(this.rex.environment, store => {
        const r = store
          .getRoot()
          .getLinkedRecord("simulation")
          ?.setValue("running" satisfies SimulationState, "state");
        assert(r, "no simulation to start?");
      });

      // We also add a system that synchronizes our UI's view of time.
      this.rex.addSystem(syncTime, {
        request: SimulationQueryNode,
        variables: {},
        fetchPolicy: "store-or-network",
      });

      // Finally, we add the actual simulation logic.
      for (const instance of query.instances.edges) {
        // this.rex.addSystem(taskChainSimulation, {
        //   request: TaskChainSimulationQuery,
        //   variables: {
        //     root: instance.node.id,
        //   },
        // });
      }
    },
  ];
};

const syncTime: System<SimulationQuery> = function (query) {
  assert(query.simulation, "no simulation to sync time?");
  return [
    async () => {
      commitLocalUpdate(this.rex.environment, store => {
        const r = store
          .getRoot()
          .getLinkedRecord("simulation")
          ?.setValue(this.rex.time.now, "time");
        assert(r, "failed to sync time");
      });
    },
  ];
};

function InstancesOf(
  props: SimulatorProps & {
    chainLagN: number;
    showFullChain: boolean;
    withState?: TaskStateName[];
  },
) {
  const data = useLazyLoadQuery<ActiveQuery>(ActiveQueryNode, props);

  return (
    <Box flexDirection="column" gap={1}>
      <Text color="gray">{data.instances.totalCount} instances</Text>
      {data.instances?.edges?.map(e => {
        const state = useTaskState(e.node);
        return (
          <Box flexDirection="column" key={e.node.id}>
            <Box gap={1}>
              <TaskId task={e.node} />
              <TaskName task={e.node} />
              <Text>@</Text>
              <Text>{e.node.parent?.name?.value}</Text>
              <Text>
                {match(state?.__typename)
                  .with("Open", () => "📬")
                  .with("InProgress", () => "🚧")
                  .with("Closed", () => "✅")
                  .otherwise(() => "🤷")}
              </Text>
            </Box>
            <TaskChain task={e.node} {...props} />
          </Box>
        );
      })}
    </Box>
  );
}
