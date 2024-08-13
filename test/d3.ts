// Doc Day Data (d3)
// Sorry for disappointing you.

import { randomUUID } from "node:crypto";
import type {
  Actor,
  Assignee,
  Checklist,
  ChecklistResult,
  Temporal,
  User,
} from "@/schema";
import { encodeGlobalId } from "@/schema/system";

function makeUser(
  firstName: string,
  lastName: string,
  options?: { active: boolean },
): Omit<User, "language" | "organizations" | "tags"> {
  return {
    __typename: "User" as const,
    id: encodeGlobalId({
      type: "worker",
      id: randomUUID(),
    }),
    active: options?.active ?? true,
    displayName: `${firstName} ${lastName}`,
    firstName,
    lastName,
    languageId: encodeGlobalId({
      type: "systag",
      id: randomUUID(),
    }),
  };
}

const USERS = {
  Akash: makeUser("Akash", "Nandi"),
  Connor: makeUser("Connor", "?"),
  Fed: makeUser("Federico", "Rozenberg"),
  Karsten: makeUser("Karsten", "Kell", { active: false }),
  Mark: makeUser("Mark", "Keller"),
  Mike: makeUser("Mike", "Heavner"),
  Murphy: makeUser("Jonathan", "Murphy"),
  Ross: makeUser("Ross", "Arkin"),
  Rugg: makeUser("Will", "Ruggiano"),
};
type USER = (typeof USERS)[keyof typeof USERS];

function makeActor(user: USER): Actor {
  return {
    __typename: "Actor" as const,
    id: encodeGlobalId({
      type: "workerinstance",
      id: randomUUID(),
    }),
    user: user as User,
  };
}

function makeInstant(d: Date) {
  return {
    __typename: "Instant" as const,
    epochMilliseconds: d.valueOf().toString(),
  } as Temporal;
}

function makeActive(id: string, active = true, updatedAt = new Date()) {
  return {
    id,
    active,
    updatedAt: makeInstant(updatedAt),
  };
}

function makeAssignee(at: Date, to: USER): Assignee {
  return {
    __typename: "Assignee" as const,
    id: encodeGlobalId({
      type: "workresultinstance",
      id: randomUUID(),
    }),
    assignedAt: makeInstant(at),
    assignedTo: {
      __typename: "Actor" as const,
      id: encodeGlobalId({
        type: "workerinstance",
        id: to.id as string,
      }),
      user: to as User,
    },
  };
}

function makeAuditable(id: string, enabled = true) {
  return { id, enabled };
}

function makeDescription(value: string, locale = "en") {
  return {
    __typename: "Description" as const,
    id: encodeGlobalId({
      type: "workdescription",
      id: randomUUID(),
    }),
    value: {
      __typename: "DynamicString" as const,
      locale,
      value,
    },
  };
}

function makeDisplayName(value: string, locale = "en") {
  return {
    __typename: "DisplayName" as const,
    id: encodeGlobalId({
      type: "languagemaster",
      id: randomUUID(),
    }),
    value: { locale, value },
  };
}

function makeOnceSchedule(d: Date) {
  return {
    __typename: "OnceSchedule" as const,
    once: makeInstant(d),
  };
}

function makeCronSchedule(cron: string) {
  return {
    __typename: "CronSchedule" as const,
    cron,
  };
}

function makeSop(id: string, link: string) {
  return { id, link };
}

function makeOpen(at: Date, by: USER) {
  return {
    __typename: "ChecklistOpen" as const,
    id: encodeGlobalId({
      type: "systag",
      id: randomUUID(),
    }),
    openedAt: makeInstant(at),
    openedBy: makeActor(by),
  };
}

function makeInProgress(at: Date, by: USER) {
  return {
    __typename: "ChecklistInProgress" as const,
    id: encodeGlobalId({
      type: "systag",
      id: randomUUID(),
    }),
    inProgressAt: makeInstant(at),
    inProgressBy: makeActor(by),
  };
}

function makeClosed(at: Date, by: USER, success = true) {
  return {
    __typename: "ChecklistClosed" as const,
    id: encodeGlobalId({
      type: "systag",
      id: randomUUID(),
    }),
    closedAt: makeInstant(at),
    closedBy: makeActor(by),
    closedBecause: {
      code: success ? ("success" as const) : ("error" as const),
    },
  };
}

function makeEdge<T extends { id: string }>(node: T) {
  return {
    node,
    cursor: node.id,
  };
}

function makeConnection<T extends { id: string }>(nodes: T[]) {
  return {
    edges: nodes.map(makeEdge),
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: nodes.length,
  };
}

function makeCounter(count: number) {
  return {
    __typename: "Counter" as const,
    count,
  };
}

function makeFlag(enabled = true) {
  return {
    __typename: "Flag" as const,
    enabled,
  };
}

function makeRegister(binary: string) {
  return {
    __typename: "Register" as const,
    binary,
  };
}

function makeResult({
  assignees,
  name,
  required,
  value,
}: {
  assignees: ReturnType<typeof makeAssignee>[];
  name: string;
  required: boolean;
  value:
    | ReturnType<typeof makeCounter>
    | ReturnType<typeof makeFlag>
    | ReturnType<typeof makeRegister>;
}): ChecklistResult {
  return {
    __typename: "ChecklistResult" as const,
    id: encodeGlobalId({
      type: "workresultinstance",
      id: randomUUID(),
    }),
    assignees: makeConnection(assignees),
    attachments: makeConnection([]),
    auditable: makeAuditable(
      encodeGlobalId({
        type: "workresult",
        id: randomUUID(),
      }),
      true,
    ),
    name: makeDisplayName(name),
    required,
    value,
  };
}

function makeChecklist({
  active,
  activeAt,
  assignees,
  description,
  items,
  name,
  required,
  schedule,
  sop,
  status,
}: {
  active: boolean;
  activeAt: Date;
  assignees: ReturnType<typeof makeAssignee>[];
  description: string;
  items: (ReturnType<typeof makeChecklist> | ReturnType<typeof makeResult>)[];
  name: string;
  required: boolean;
  schedule:
    | ReturnType<typeof makeOnceSchedule>
    | ReturnType<typeof makeCronSchedule>;
  sop: string;
  status:
    | ReturnType<typeof makeOpen>
    | ReturnType<typeof makeInProgress>
    | ReturnType<typeof makeClosed>;
}): Checklist {
  const wi = encodeGlobalId({
    type: "workinstance",
    id: randomUUID(),
  });
  const wt = encodeGlobalId({
    type: "worktemplate",
    id: randomUUID(),
  });
  return {
    __typename: "Checklist" as const,
    id: wi,
    active: makeActive(wt, active, activeAt),
    assignees: makeConnection(assignees),
    attachments: makeConnection([]),
    auditable: makeAuditable(wt),
    children: makeConnection([]),
    description: makeDescription(description),
    items: makeConnection(items),
    name: makeDisplayName(name),
    required,
    schedule,
    sop: makeSop(wt, sop),
    status,
  };
}

// schedule: makeCronSchedule("0 14 * * 3"),

const GREENHOUSE_CHECK_OPEN = makeChecklist({
  active: true,
  activeAt: new Date("2024-08-01T00:00:00"),
  assignees: [makeAssignee(new Date("2024-08-15T08:00:00"), USERS.Murphy)],
  description: "Make sure the greenhouse is in shape",
  items: [
    makeResult({
      name: "Doors locked properly?",
      assignees: [],
      required: true,
      value: makeFlag(false),
    }),
    makeResult({
      name: "Count of broken panels",
      assignees: [],
      required: true,
      value: makeCounter(0),
    }),
  ],
  name: "Greenhouse Check",
  required: true,
  schedule: makeCronSchedule("0 08,18 * * 1-5"),
  sop: "https://big-green.uk/sop/greenhouse-check",
  status: makeOpen(new Date("2024-08-15T08:00:00"), USERS.Mark),
});

const GREENHOUSE_CHECK_PROG = {
  ...GREENHOUSE_CHECK_OPEN,
  status: makeInProgress(new Date("2024-08-15T08:02:30"), USERS.Murphy),
};

export const CHECKLISTS = [GREENHOUSE_CHECK_OPEN, GREENHOUSE_CHECK_PROG];
