import { useFragment } from "react-relay";
import UseTaskChainFragment, {
  type useTaskChain_fragment$key as UseTaskChainKey,
} from "../__generated__/useTaskChain_fragment.graphql";
import UseTaskIdFragment, {
  type useTaskId_fragment$key as UseTaskIdKey,
} from "../__generated__/useTaskId_fragment.graphql";
import UseTaskNameFragment, {
  type useTaskName_fragment$key as UseTaskNameKey,
} from "../__generated__/useTaskName_fragment.graphql";
import UseTaskStateFragment, {
  type useTaskState_fragment$key as UseTaskStateKey,
} from "../__generated__/useTaskState_fragment.graphql";
import UseTaskTypesFragment, {
  type useTaskTypes_fragment$key as UseTaskTypesKey,
} from "../__generated__/useTaskTypes_fragment.graphql";

/**
 * Access a Task's chain.
 */
export function useTaskChain(task: UseTaskChainKey) {
  const { chain } = useFragment(UseTaskChainFragment, task);
  return chain;
}
export { UseTaskChainFragment, type UseTaskChainKey };

/**
 * Access a Task's unique identifier.
 */
export function useTaskId(task: UseTaskIdKey) {
  const { id } = useFragment(UseTaskIdFragment, task);
  return id;
}
export { UseTaskIdFragment, type UseTaskIdKey };

/**
 * Access a Task's (display) name.
 */
export function useTaskName(task: UseTaskNameKey) {
  const { name } = useFragment(UseTaskNameFragment, task);
  return name;
}
export { UseTaskNameFragment, type UseTaskNameKey };

/**
 * Access a Task's internal state.
 */
export function useTaskState(task: UseTaskStateKey) {
  const { state } = useFragment(UseTaskStateFragment, task);
  return state;
}
export { UseTaskStateFragment, type UseTaskStateKey };

/**
 * Access a Task's associated types.
 */
export function useTaskTypes(task: UseTaskTypesKey) {
  const { types } = useFragment(UseTaskTypesFragment, task);
  return types;
}
export { UseTaskTypesFragment, type UseTaskTypesKey };
