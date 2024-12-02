import type { Context } from "@/schema/types";
import type { StateMachine } from "../fsm";
import type { Task } from "./task";

/**
 * Tasks can have an associated StateMachine, which defines a finite set of
 * states that the given Task can be in at any given time.
 *
 * @gqlField
 */
export async function fsm(
  t: Task,
  ctx: Context,
): Promise<StateMachine<Task> | null> {
  console.warn("Task.fsm is not yet implemented");
  return null;
}
