import { map } from "@/util";
import { Box, Text, type TextProps } from "ink";
import { useMemo } from "react";
import { match } from "ts-pattern";
import config from "../config";
import { useLag } from "../hooks/useLag";
import {
  type UseTaskChainKey,
  type UseTaskIdKey,
  type UseTaskNameKey,
  type UseTaskStateKey,
  type UseTaskTypesKey,
  useTaskChain,
  useTaskId,
  useTaskName,
  useTaskState,
  useTaskTypes,
} from "../hooks/useTask";
import { Id, type IdProps } from "./Id";

interface TaskChainProps {
  chainLagN?: number;
  showFullChain?: boolean;
  task: UseTaskChainKey;
}

export function TaskChain({
  chainLagN = config.chain_lag_n,
  showFullChain = config.show_full_chain,
  ...props
}: TaskChainProps) {
  const chain = useTaskChain(props.task);

  const Chain = match(showFullChain)
    .with(true, () => () => (
      <Box flexDirection="column">
        {chain.edges.map(e => (
          <Box gap={1} key={e.node.id} marginLeft={1}>
            <Text color="gray">{"└─"}</Text>
            <TaskChainNode task={e.node} />
          </Box>
        ))}
      </Box>
    ))
    .with(false, () => () => {
      const visible = useLag(chain.edges, chainLagN);
      return (
        <Box flexDirection="column">
          {map(chain.edges.at(0), e => (
            <Box gap={1} marginLeft={1}>
              <Text color="gray">{"└─"}</Text>
              <TaskChainNode task={e.node} />
            </Box>
          ))}
          {chain.edges.length - 1 > visible.length && (
            <Box gap={1} marginLeft={1}>
              <Text color="gray">
                {"└─"} ... {chain.edges.length - visible.length - 1} hidden
              </Text>
            </Box>
          )}
          {visible.map(e => (
            <Box gap={1} key={e.node.id} marginLeft={1}>
              <Text color="gray">{"└─"}</Text>
              <TaskChainNode task={e.node} />
            </Box>
          ))}
        </Box>
      );
    })
    .exhaustive();

  return <Chain />;
}

interface TaskChainNodeProps {
  level?: number;
  task: UseTaskIdKey & UseTaskNameKey & UseTaskStateKey & UseTaskTypesKey;
}

export function TaskChainNode(props: TaskChainNodeProps) {
  return (
    <Box gap={1}>
      <TaskId {...props} />
      <TaskName
        {...props}
        typesConfig={{
          Runtime: { color: "green" },
          Downtime: { color: "red" },
          "Idle Time": { color: "yellow" },
        }}
      />
      <TaskState {...props} />
    </Box>
  );
}

interface TaskIdProps extends Omit<IdProps, "id"> {
  task: UseTaskIdKey;
}

export function TaskId({ task, ...props }: TaskIdProps) {
  const id = useTaskId(task);
  return <Id id={id} {...props} />;
}

interface TaskNameProps {
  task: UseTaskNameKey & UseTaskTypesKey;
  typesConfig?: Record<string, TextProps>;
}

export function TaskName({ task, typesConfig = {} }: TaskNameProps) {
  const name = useTaskName(task);
  const types = useTaskTypes(task);
  // -1 for now because Trackable comes back with Run :/
  return (
    <Text {...(typesConfig[types[types.length - 1]] ?? {})}>{name.value}</Text>
  );
}

interface TaskStateProps {
  task: UseTaskStateKey;
}

export function TaskState(props: TaskStateProps) {
  const state = useTaskState(props.task);

  const text = useMemo(() => {
    switch (state?.__typename) {
      case "Open": {
        const open = new Date(state.openedAt.value);
        return `open, since ${open.toISOString()}`;
      }
      case "InProgress": {
        const start = new Date(state.inProgressAt.value);
        return start ? `in-progress, since ${start.toISOString()}` : "-";
      }
      case "Closed": {
        const start = map(state.inProgressAt?.value, Date.parse);
        const end = Date.parse(state.closedAt.value);
        return start && end
          ? `closed, took ${formatDuration(end - start)}`
          : "-";
      }
      default:
        return "-";
    }
  }, [state]);

  return <Text>{text}</Text>;
}

export function formatDuration(ms: number): string {
  if (ms <= 0) return "";
  if (ms < 1000) return `${ms}ms`; // <1s
  if (ms < 60_000) return `${ms / 1000}s`; // <60s
  return `${Math.floor(ms / 60_000)}m ${formatDuration(ms % 60_000)}`.trim();
}
