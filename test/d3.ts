// Doc Day Data (d3)
// Sorry to disappoint you.

import { randomUUID } from "node:crypto";
import type {
  Assignable,
  Assignee,
  Checklist,
  ChecklistResult,
  Temporal,
  User,
  Worker,
} from "@/schema";
import { decodeGlobalId, encodeGlobalId } from "@/schema/system";
import { CronExpression } from "@/schema/system/scalars";
import { mergeAndConcat } from "merge-anything";
import z from "myzod";

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

const BOT = makeUser("Beep", "Boop");

export const USERS = {
  Akash: makeUser("Akash", "Nandi"),
  Connor: makeUser("Connor", "Smith"),
  Fed: makeUser("Federico", "Rozenberg"),
  Karsten: makeUser("Karsten", "Kell", { active: false }),
  Mark: makeUser("Mark", "Keller"),
  Mike: makeUser("Mike", "Heavner"),
  Murphy: makeUser("Jonathan", "Murphy"),
  Ross: makeUser("Ross", "Arkin"),
  Rugg: makeUser("Will", "Ruggiano"),
  Twait: makeUser("Will", "Twait"),
};
type USER = (typeof USERS)[keyof typeof USERS];

function makeActingIdentity(user: USER) {
  return {
    __typename: "Worker" as const,
    id: encodeGlobalId({
      type: "workerinstance",
      id: user.id as string,
    }),
    firstName: user.firstName,
    lastName: user.lastName,
    displayName: user.displayName,
  } as Worker;
}

function makeInstant(d: Date) {
  return {
    __typename: "Instant" as const,
    epochMilliseconds: d.valueOf().toString(),
  } as Temporal;
}

// FIXME: globally unique id violation.
// Our fake data returns the same gid for Active and Sop. This is a violation of
// the server specification and needs to be fixed. This is an interesting case.
// One could argue that we could separate SOP and Active *in the database* and
// use foreign keys instead, but right now sop and active are both columns in
// the worktemplate table. This is in the case where we want to treat Active and
// Sop as *components*, rather than just raw data. If we were to say they are
// just types, rather than components, neither would have an entity reference
// and thus avoid this problem all together.
function makeActive(id: string, active = true, updatedAt = new Date()) {
  return {
    id: encodeGlobalId({ type: "worktemplate", id, suffix: ["active"] }),
    active,
    updatedAt: makeInstant(updatedAt),
  };
}

function makeAssignee({ at, to }: { at: Date; to: USER["id"] }): Assignee {
  const user = Object.values(USERS).find(u => u.id === to);
  return {
    __typename: "Assignee" as const,
    id: encodeGlobalId({
      type: "workresultinstance",
      id: randomUUID(),
    }),
    assignedAt: makeInstant(at),
    assignedTo: {
      __typename: "Worker" as const,
      id: encodeGlobalId({
        type: "workerinstance",
        id: to as string,
      }),
      firstName: user?.firstName,
      lastName: user?.lastName,
      displayName: user?.displayName,
    } as Assignable,
  };
}

function makeAuditable(id: string, enabled = true) {
  return {
    id: encodeGlobalId({ type: "worktemplate", id, suffix: "auditable" }),
    enabled,
  };
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

const ScheduleInput = z.union([
  z.object(
    {
      type: z.literal("CronSchedule"),
      repr: z.string().map(CronExpression.parseValue),
    },
    { allowUnknown: true },
  ),
  z.object(
    {
      type: z.literal("OnceSchedule"),
      repr: z.string(),
    },
    { allowUnknown: true },
  ),
]);

export function parseScheduleInput(input: { type: string; repr: unknown }) {
  const schedule = ScheduleInput.parse(input);
  switch (schedule.type) {
    case "CronSchedule":
      return makeCronSchedule(schedule.repr);
    case "OnceSchedule":
      return makeOnceSchedule(new Date(schedule.repr));
  }
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

function makeSop(id: string, link: string | URL) {
  return {
    id: encodeGlobalId({ type: "worktemplate", id, suffix: "sop" }),
    link: link.toString(),
  };
}

const StatusInput = z.union(
  [
    z.object(
      {
        type: z.literal("ChecklistOpen"),
        repr: z.object(
          {
            id: z.string(),
            openedAt: z.object(
              {
                epochMilliseconds: z.number({ coerce: true }),
              },
              {
                allowUnknown: true,
              },
            ),
            openedBy: z.object(
              {
                id: z.string(),
              },
              { allowUnknown: true },
            ),
          },
          { allowUnknown: true },
        ),
      },
      { allowUnknown: true },
    ),
    z.object(
      {
        type: z.literal("ChecklistInProgress"),
        repr: z.object(
          {
            id: z.string(),
            inProgressAt: z.object(
              {
                epochMilliseconds: z.number({ coerce: true }),
              },
              { allowUnknown: true },
            ),
            inProgressBy: z.object(
              {
                id: z.string(),
              },
              { allowUnknown: true },
            ),
          },
          { allowUnknown: true },
        ),
      },
      { allowUnknown: true },
    ),
    z.object(
      {
        type: z.literal("ChecklistClosed"),
        repr: z.object(
          {
            id: z.string(),
            closedAt: z.object(
              {
                epochMilliseconds: z.number({ coerce: true }),
              },
              { allowUnknown: true },
            ),
            closedBy: z.object(
              {
                id: z.string(),
              },
              { allowUnknown: true },
            ),
            closedBecause: z
              .object(
                {
                  code: z.union([z.literal("success"), z.literal("error")]),
                  note: z.object(
                    {
                      locale: z.string(),
                      value: z.string(),
                    },
                    { allowUnknown: true },
                  ),
                },
                { allowUnknown: true },
              )
              .optional(),
          },
          { allowUnknown: true },
        ),
      },
      { allowUnknown: true },
    ),
  ],
  {
    strict: false,
  },
);

export function parseStatusInput(input: { type: string; repr: unknown }) {
  const status = StatusInput.parse({
    ...input,
    repr: typeof input.repr === "string" ? JSON.parse(input.repr) : input.repr,
  });
  switch (status.type) {
    case "ChecklistOpen":
      return makeOpen({
        at: new Date(status.repr.openedAt.epochMilliseconds),
        by: USERS.Rugg,
      });
    case "ChecklistInProgress":
      return makeInProgress({
        at: new Date(status.repr.inProgressAt.epochMilliseconds),
        by: USERS.Rugg,
      });
    case "ChecklistClosed":
      return makeClosed({
        at: new Date(status.repr.closedAt.epochMilliseconds),
        by: USERS.Rugg,
        success: status.repr.closedBecause?.code !== "error",
      });
  }
}

export function makeOpen({ at, by }: { at: Date; by: USER }) {
  return {
    __typename: "ChecklistOpen" as const,
    id: encodeGlobalId({
      type: "systag",
      id: randomUUID(),
    }),
    openedAt: makeInstant(at),
    openedBy: makeActingIdentity(by),
  };
}

function makeInProgress({ at, by }: { at: Date; by: USER }) {
  return {
    __typename: "ChecklistInProgress" as const,
    id: encodeGlobalId({
      type: "systag",
      id: randomUUID(),
    }),
    inProgressAt: makeInstant(at),
    inProgressBy: makeActingIdentity(by),
  };
}

function makeClosed({
  at,
  by,
  success,
}: { at: Date; by: USER; success: boolean }) {
  return {
    __typename: "ChecklistClosed" as const,
    id: encodeGlobalId({
      type: "systag",
      id: randomUUID(),
    }),
    closedAt: makeInstant(at),
    closedBy: makeActingIdentity(by),
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

const ChecklistItemInput = z.union([
  z.object(
    {
      type: z.literal("ChecklistResult"),
      repr: z.object(
        {
          id: z.string(),
          auditable: z.object(
            {
              enabled: z.boolean(),
            },
            { allowUnknown: true },
          ),
          name: z.object(
            {
              value: z.object({
                value: z.string(),
              }),
            },
            { allowUnknown: true },
          ),
          required: z.boolean().optional(),
          status: z.string().map(StatusInput.parse).or(StatusInput),
          value: z
            .union([
              z.object(
                {
                  count: z.number(),
                },
                { allowUnknown: true },
              ),
              z.object(
                {
                  enabled: z.boolean(),
                },
                { allowUnknown: true },
              ),
              z.object(
                {
                  binary: z.string(),
                },
                { allowUnknown: true },
              ),
            ])
            .optional(),
        },
        { allowUnknown: true },
      ),
    },
    { allowUnknown: true },
  ),
]);

export function parseChecklistItemInput(input: {
  type: string;
  repr: unknown;
}) {
  const item = ChecklistItemInput.parse({
    ...input,
    repr: typeof input.repr === "string" ? JSON.parse(input.repr) : input.repr,
  });
  switch (item.type) {
    case "ChecklistResult":
      return makeResult({
        assignees: [],
        name: item.repr.name.value.value,
        required: item.repr.required ?? false,
        status: parseStatusInput(item.repr.status),
        value: item.repr.value
          ? "count" in item.repr.value
            ? makeCounter(item.repr.value.count)
            : "enabled" in item.repr.value
              ? makeFlag(item.repr.value.enabled)
              : makeRegister(item.repr.value.binary)
          : undefined,
      });
  }
}

function makeResult({
  assignees,
  name,
  required,
  status,
  value,
}: {
  assignees: ReturnType<typeof makeAssignee>[];
  name: string;
  required: boolean;
  status:
    | ReturnType<typeof makeOpen>
    | ReturnType<typeof makeInProgress>
    | ReturnType<typeof makeClosed>;
  value?:
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
    status,
    value,
  };
}

function makeChecklist({
  active,
  activeAt,
  assignees,
  auditable,
  children,
  description,
  items,
  name,
  required,
  schedule,
  sop,
  status,
  ...rest
}: {
  id?: string;
  active: boolean;
  activeAt: Date;
  assignees: Parameters<typeof makeAssignee>[0][];
  auditable?: boolean;
  children: ReturnType<typeof makeChecklist>[];
  description?: string;
  items: (ReturnType<typeof makeChecklist> | ReturnType<typeof makeResult>)[];
  name: string;
  required?: boolean;
  schedule?:
    | ReturnType<typeof makeOnceSchedule>
    | ReturnType<typeof makeCronSchedule>;
  sop?: string | URL;
  status?:
    | ReturnType<typeof makeOpen>
    | ReturnType<typeof makeInProgress>
    | ReturnType<typeof makeClosed>;
}): Checklist {
  const id = rest.id ? decodeGlobalId(rest.id).id : randomUUID();
  return {
    __typename: "Checklist" as const,
    id:
      rest.id ??
      encodeGlobalId({
        type: "worktemplate",
        id,
      }),
    active: makeActive(id, active, activeAt),
    assignees: makeConnection(assignees.map(makeAssignee)),
    attachments: makeConnection([]),
    auditable: makeAuditable(id, auditable),
    children: makeConnection(children),
    description: description ? makeDescription(description) : undefined,
    items: makeConnection(items),
    metadata: {
      updatedAt: makeInstant(new Date("2024-08-01T00:00:00")),
    },
    name: makeDisplayName(name),
    required,
    schedule,
    sop: sop ? makeSop(id, sop) : undefined,
    status,
  };
}

const KELLER_TODOLIST = makeChecklist({
  active: true,
  activeAt: new Date("2024-08-01T00:00:00"),
  assignees: [{ at: new Date("2024-08-15T08:00:00"), to: USERS.Mark.id }],
  children: [],
  description: "A Day in the Life of Keller (abridged, volume 3.82)",
  items: [
    makeResult({
      name: "Read people's standup notes",
      assignees: [],
      required: true,
      status: makeOpen({
        at: new Date("2024-08-15T08:00:00"),
        by: BOT,
      }),
      value: makeFlag(false),
    }),
    makeResult({
      name: "Write some arcane SQL procedure code",
      assignees: [],
      required: true,
      status: makeOpen({
        at: new Date("2024-08-15T08:00:00"),
        by: BOT,
      }),
      value: makeFlag(false),
    }),
    makeResult({
      name: "Note how many alarms are firing",
      assignees: [],
      required: true,
      status: makeOpen({
        at: new Date("2024-08-15T08:00:00"),
        by: BOT,
      }),
      value: makeCounter(0),
    }),
    makeResult({
      name: "Fix the SQL code and ensure alarms recover",
      assignees: [],
      required: true,
      status: makeOpen({
        at: new Date("2024-08-15T08:00:00"),
        by: BOT,
      }),
      value: makeFlag(false),
    }),
  ],
  name: "Keller's Personal Todos",
  required: true,
  schedule: makeCronSchedule("0 08,18 * * 1-5"),
  sop: "https://www.youtube.com/watch?v=Vofkw9-O18c&list=PLi1CK-rsvz1Nfz83RMBp_9YaIgBWd0l9x",
  status: makeOpen({ at: new Date("2024-08-15T08:00:00"), by: BOT }),
});

const GREENHOUSE_CHECK_OPEN = makeChecklist({
  active: true,
  activeAt: new Date("2024-08-01T00:00:00"),
  assignees: [{ at: new Date("2024-08-15T08:00:00"), to: USERS.Murphy.id }],
  children: [],
  description: "Make sure the greenhouse is in shape",
  items: [
    makeResult({
      name: "Doors locked properly?",
      assignees: [],
      required: true,
      status: makeOpen({
        at: new Date("2024-08-15T08:00:00"),
        by: BOT,
      }),
      value: makeFlag(false),
    }),
    makeResult({
      name: "Count of broken panels",
      assignees: [],
      required: true,
      status: makeOpen({
        at: new Date("2024-08-15T08:00:00"),
        by: BOT,
      }),
      value: makeCounter(0),
    }),
  ],
  name: "Greenhouse Check",
  required: true,
  schedule: makeCronSchedule("0 08,18 * * 1-5"),
  sop: "https://big-green.uk/sop/greenhouse-check",
  status: makeOpen({ at: new Date("2024-08-15T08:00:00"), by: BOT }),
});

const GREENHOUSE_CHECK_SUC = makeChecklist({
  active: true,
  activeAt: new Date("2024-08-01T00:00:00"),
  assignees: [{ at: new Date("2024-08-15T08:00:00"), to: USERS.Fed.id }],
  children: [],
  description: "Make sure the greenhouse is in shape",
  items: [
    makeResult({
      name: "Doors locked properly?",
      assignees: [],
      required: true,
      status: makeClosed({
        at: new Date("2024-08-13T08:11:05"),
        by: USERS.Fed,
        success: true,
      }),
      value: makeFlag(false),
    }),
    makeResult({
      name: "Count of broken panels",
      assignees: [],
      required: true,
      status: makeClosed({
        at: new Date("2024-08-13T08:11:14"),
        by: USERS.Fed,
        success: true,
      }),
      value: makeCounter(0),
    }),
  ],
  name: "Greenhouse Check",
  required: true,
  schedule: makeCronSchedule("*/30 * * * *"),
  sop: "https://big-green.uk/sop/greenhouse-check",
  status: makeClosed({
    at: new Date("2024-08-13T08:12:14"),
    by: USERS.Fed,
    success: true,
  }),
});

const GREENHOUSE_CHECK_ERR = makeChecklist({
  active: true,
  activeAt: new Date("2024-08-01T00:00:00"),
  assignees: [
    { at: new Date("2024-08-12T08:00:00"), to: USERS.Rugg.id },
    { at: new Date("2024-08-12T08:00:00"), to: USERS.Akash.id },
    { at: new Date("2024-08-12T08:00:00"), to: USERS.Connor.id },
    { at: new Date("2024-08-12T08:00:00"), to: USERS.Mark.id },
  ],
  children: [],
  description: "Make sure the greenhouse is in shape",
  items: [
    makeResult({
      name: "Doors locked properly?",
      assignees: [],
      required: true,
      status: makeClosed({
        at: new Date("2024-08-13T08:11:05"),
        by: USERS.Akash,
        success: true,
      }),
      value: makeFlag(false),
    }),
    makeResult({
      name: "Count of broken panels",
      assignees: [],
      required: true,
      status: makeClosed({
        at: new Date("2024-08-13T08:11:14"),
        by: USERS.Rugg,
        success: false,
      }),
      value: makeCounter(2),
    }),
  ],
  name: "Greenhouse Check",
  required: true,
  schedule: makeCronSchedule("*/30 * * * *"),
  sop: "https://big-green.uk/sop/greenhouse-check",
  status: makeClosed({
    at: new Date("2024-08-13T09:27:10"),
    by: USERS.Rugg,
    success: false,
  }),
});

const ONCALL_DAILY = makeChecklist({
  active: true,
  activeAt: new Date("2024-08-01T00:00:00"),
  assignees: [{ at: new Date("2024-08-15T08:00:00"), to: USERS.Twait.id }],
  description: "Do these things every day",
  items: [
    makeChecklist({
      active: true,
      activeAt: new Date("2024-08-01T00:00:00"),
      assignees: [],
      description: "Daily alarm monitoring",
      items: [
        makeResult({
          name: "Check Cloudwatch alarms",
          assignees: [],
          required: true,
          status: makeClosed({
            at: new Date("2024-08-15T08:02:36"),
            by: USERS.Twait,
            success: true,
          }),
          value: makeFlag(false),
        }),
        makeResult({
          name: "Check superset alarms",
          assignees: [],
          required: true,
          status: makeClosed({
            at: new Date("2024-08-15T08:07:36"),
            by: USERS.Twait,
            success: true,
          }),
          value: makeFlag(false),
        }),
      ],
      name: "Alarm Monitoring",
      required: true,
      schedule: makeCronSchedule("0 08,18 * * 1-5"),
      sop: "https://www.notion.so/tendrel/Oncall-Responsibilities-c57c310cf24a48078bf76b8f7213330c#f0d81e702e7c4f26804ea491a5ccb2f7",
      status: makeClosed({
        at: new Date("2024-08-15T08:07:45"),
        by: USERS.Twait,
        success: true,
      }),
      //
      children: [],
    }),
    makeChecklist({
      active: true,
      activeAt: new Date("2024-08-01T00:00:00"),
      assignees: [],
      description: "Daily OE tasks",
      items: [
        makeResult({
          name: "Check to see if there are failing tests",
          assignees: [],
          required: true,
          status: makeInProgress({
            at: new Date("2024-08-15T08:10:00"),
            by: USERS.Twait,
          }),
          value: makeFlag(false),
        }),
      ],
      name: "Pipeline health",
      required: true,
      schedule: makeCronSchedule("0 08,18 * * 1-5"),
      sop: "https://www.notion.so/tendrel/Oncall-Responsibilities-c57c310cf24a48078bf76b8f7213330c#f0d81e702e7c4f26804ea491a5ccb2f7",
      status: makeInProgress({
        at: new Date("2024-08-15T08:10:00"),
        by: USERS.Twait,
      }),
      //
      children: [],
    }),
    makeChecklist({
      active: true,
      activeAt: new Date("2024-08-01T00:00:00"),
      assignees: [],
      description: "Ticket queue monitoring",
      items: [
        makeResult({
          name: "Go through old tickets and make sure they are all in the right state",
          assignees: [],
          required: true,
          status: makeOpen({
            at: new Date("2024-08-15T08:10:00"),
            by: BOT,
          }),
          value: makeFlag(false),
        }),
      ],
      name: "Ticket queue monitoring",
      required: true,
      schedule: makeCronSchedule("0 08,18 * * 1-5"),
      sop: "https://www.notion.so/tendrel/Oncall-Responsibilities-c57c310cf24a48078bf76b8f7213330c#f0d81e702e7c4f26804ea491a5ccb2f7",
      status: makeOpen({ at: new Date("2024-08-15T08:00:00"), by: BOT }),
      //
      children: [],
    }),
    makeChecklist({
      active: true,
      activeAt: new Date("2024-08-01T00:00:00"),
      assignees: [],
      description: "Database / Datawarehouse monitoring",
      items: [
        makeResult({
          name: "Check that work data from today is flowing through to the dashboards",
          assignees: [],
          required: true,
          status: makeOpen({
            at: new Date("2024-08-15T08:10:00"),
            by: BOT,
          }),
          value: makeFlag(false),
        }),
      ],
      name: "DB/DW monitoring",
      required: true,
      schedule: makeCronSchedule("0 08,18 * * 1-5"),
      sop: "https://www.notion.so/tendrel/Oncall-Responsibilities-c57c310cf24a48078bf76b8f7213330c#f0d81e702e7c4f26804ea491a5ccb2f7",
      status: makeOpen({ at: new Date("2024-08-15T08:00:00"), by: BOT }),
      //
      children: [],
    }),
  ],
  name: "Daily Oncall Checks",
  required: true,
  schedule: makeCronSchedule("0 08,18 * * 1-5"),
  sop: "https://www.notion.so/tendrel/Oncall-Responsibilities-c57c310cf24a48078bf76b8f7213330c#f0d81e702e7c4f26804ea491a5ccb2f7",
  status: makeInProgress({
    at: new Date("2024-08-15T08:01:07"),
    by: USERS.Twait,
  }),
  //
  children: [
    //
  ],
});

export let CHECKLISTS: Checklist[] = [
  KELLER_TODOLIST,
  ONCALL_DAILY,
  {
    ...GREENHOUSE_CHECK_SUC,
    children: makeConnection([
      GREENHOUSE_CHECK_OPEN,
      GREENHOUSE_CHECK_SUC,
      GREENHOUSE_CHECK_ERR,
    ]),
  },
];

export function appendChecklist(args: Parameters<typeof makeChecklist>[0]) {
  const c = makeChecklist(args);
  const i = CHECKLISTS.findIndex(e => e.id === c.id);
  if (i !== -1) {
    CHECKLISTS = [
      ...CHECKLISTS.slice(0, i),
      mergeAndConcat(CHECKLISTS[i], c) as Checklist,
      ...CHECKLISTS.slice(i + 1),
    ];
  } else {
    CHECKLISTS.push(c);
  }
  return c;
}
