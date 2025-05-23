import assert from "node:assert";
import { Box, Text, useInput, useStdin } from "ink";
import { Suspense, useCallback, useEffect, useState } from "react";
import {
  commitLocalUpdate,
  useClientQuery,
  useFragment,
  useLazyLoadQuery,
} from "react-relay";
import { match } from "ts-pattern";
import ActiveQueryNode, {
  type useSimulationActiveQuery as ActiveQuery,
  type TaskStateName,
} from "../__generated__/useSimulationActiveQuery.graphql";
import InstanceFragment, {
  type useSimulationInstance_fragment$key as InstanceFragment$key,
} from "../__generated__/useSimulationInstance_fragment.graphql";
import SimulationQueryNode, {
  type SimulationState,
  type useSimulationQuery as SimulationQuery,
} from "../__generated__/useSimulationQuery.graphql";
import TimeFragment, {
  type useSimulationTime_fragment$key as TimeFragment$key,
} from "../__generated__/useSimulationTime_fragment.graphql";
import Loading from "../components/Loading";
import { TaskChain, TaskId, TaskName } from "../components/Task";
import config from "../config";
import { formatDuration } from "../lib";
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
  const data = useClientQuery<SimulationQuery>(SimulationQueryNode, {
    includeTime: false,
  });
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

  const Main = useCallback(() => {
    if (!data.simulation) {
      return <Loading />;
    }

    return match(data.simulation.state)
      .with("starting", () => <Starting {...props} />)
      .otherwise(() => <Running {...props} />);
  }, [data.simulation, props]);

  return <Main />;
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

  const rex = useRex();
  useEffect(() => {
    return rex.addSystem(stopSimulation, {
      request: ActiveQueryNode,
      variables: props,
    });
  }, [props, rex]);

  const stdin = useStdin();
  if (stdin.isRawModeSupported && !config.force_raw_mode) {
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
  }

  return (
    <Box flexDirection="column">
      <Box gap={1}>
        <Text>[{simulation.state ?? "-"}]</Text>
        <Time simulation={simulation} />
      </Box>
      <Suspense>
        <InstancesOf
          chainLagN={chainLagN}
          showFullChain={showFullChain}
          {...props}
        />
        {stdin.isRawModeSupported && !config.force_raw_mode && (
          <>
            <Box height={1} />
            <Text color="gray">
              <Text bold>chain_lag_n={chainLagN}</Text> : use +/- to change
            </Text>
            <Text color="gray">
              <Text bold>show_full_chain={Number(showFullChain)}</Text> : use v
              to toggle
            </Text>
            <Text color="gray">use = to reset to defaults</Text>
          </>
        )}
      </Suspense>
    </Box>
  );
}

function Time(props: { simulation: TimeFragment$key }) {
  const data = useFragment(TimeFragment, props.simulation);
  const rex = useRex();
  const sys = data.time ?? "-";
  const usr = formatDuration(rex.time.elapsed);

  const stdin = useStdin();
  if (!stdin.isRawModeSupported || config.force_raw_mode) {
    console.log(`t=${sys}, usr=${usr}`);
    return null;
  }

  return (
    <Text>
      t={sys}, usr={usr}
    </Text>
  );
}

const startSimulation: System<ActiveQuery> = function (query) {
  assert(query.simulation?.state === "starting");
  return [
    async () => {
      commitLocalUpdate(this.rex.environment, store => {
        const r = store
          .getRoot()
          .getLinkedRecord("simulation")
          ?.setValue("running" satisfies SimulationState, "state");
        assert(r, "no simulation to start?");
      });
    },
    async () => {
      this.rex.addSystem(syncTime, {
        request: SimulationQueryNode,
        variables: {},
        fetchPolicy: "store-or-network",
      });
    },
    async () => {
      for (const instance of query.instances.edges) {
        this.rex.addSystem(taskChainSimulation, {
          request: TaskChainSimulationQuery,
          variables: {
            root: instance.node.id,
          },
        });
      }
    },
    async () => {
      if (config.timeout) {
        setTimeout(() => {
          commitLocalUpdate(this.rex.environment, store => {
            store
              .getRoot()
              .getLinkedRecord("simulation")
              ?.setValue("stopping" satisfies SimulationState, "state");
          });
          this.rex.stop();
          // TODO: we can do better here
          setTimeout(() => process.exit(124), 0);
        }, config.timeout);
      }
    },
  ];
};

const stopSimulation: System<ActiveQuery> = function (query) {
  assert(query.simulation?.state === "running");

  // Only proceed if everything is closed.
  if (
    query.instances.edges.some(
      ({ node }) => node.state?.__typename !== "Closed",
    )
  ) {
    return [];
  }

  return [
    async () => {
      commitLocalUpdate(this.rex.environment, store => {
        const r = store
          .getRoot()
          .getLinkedRecord("simulation")
          ?.setValue("stopping" satisfies SimulationState, "state");
        assert(r, "no simulation to stop?");

        this.rex.stop();
        setTimeout(() => process.exit(124), 0);
      });
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
      {data.instances?.edges?.map(e => (
        <Instance key={e.node.id} instance={e.node} />
      ))}
    </Box>
  );
}

function Instance(props: { instance: InstanceFragment$key }) {
  const node = useFragment(InstanceFragment, props.instance);
  const state = useTaskState(node);
  const stdin = useStdin();

  if (!stdin.isRawModeSupported || config.force_raw_mode) {
    console.log(
      `${node.id} @ ${node.parent?.name?.value} -> ${state?.__typename}`,
    );
  }

  return (
    <Box flexDirection="column">
      <Box gap={1}>
        <TaskId task={node} />
        <TaskName task={node} />
        <Text>@</Text>
        <Text>{node.parent?.name?.value}</Text>
        <Text>
          {match(state?.__typename)
            .with("Open", () => "📬")
            .with("InProgress", () => "🚧")
            .with("Closed", () => "✅")
            .otherwise(() => "🤷")}
        </Text>
      </Box>
      <TaskChain task={node} {...props} />
    </Box>
  );
}
