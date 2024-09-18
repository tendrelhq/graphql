// @ts-nocheck
// Doc Day Data (d3)
// Sorry to disappoint you.

import { randomUUID } from "node:crypto";
import type {
  Activatable,
  ActiveInput,
  Assignable,
  Assignee,
  AssigneeInput,
  Auditable,
  AuditableInput,
  Checklist,
  ChecklistClosed,
  ChecklistClosedInput,
  ChecklistInProgress,
  ChecklistInProgressInput,
  ChecklistInput,
  ChecklistItemInput,
  ChecklistOpen,
  ChecklistOpenInput,
  ChecklistResult,
  ChecklistResultInput,
  ChecklistResultValue,
  ChecklistResultValueInput,
  ChecklistStatusInput,
  Counter,
  CronSchedule,
  Description,
  DescriptionInput,
  DisplayName,
  DisplayNameInput,
  DynamicString,
  DynamicStringInput,
  Flag,
  Identity,
  InputMaybe,
  Instant,
  OnceSchedule,
  Register,
  ScheduleInput,
  Sop,
  SopInput,
  TemporalInput,
  ZonedDateTime,
  ZonedDateTimeInput,
} from "@/schema";
import { encodeGlobalId } from "@/schema/system";
import { Temporal } from "@js-temporal/polyfill";
import { mergeAndConcat } from "merge-anything";
import { NOW, testGlobalId } from "./prelude";

function makeWorker(
  firstName: string,
  lastName: string,
  options?: { active: boolean },
) {
  return {
    __typename: "Worker" as const,
    id: encodeGlobalId({ type: "workerinstance", id: randomUUID() }),
    active: {
      __typename: "ActivationStatus",
      active: options?.active ?? true,
      activatedAt: new Date().toISOString(),
      deactivatedAt: options?.active ? undefined : new Date().toISOString(),
    },
    displayName: `${firstName} ${lastName}`,
    firstName,
    lastName,
  };
}

export const WORKERS = {
  Bot: makeWorker("Beep", "Boop"),
  Akash: makeWorker("Akash", "Nandi"),
  Connor: makeWorker("Connor", "Smith"),
  Fed: makeWorker("Federico", "Rozenberg"),
  Karsten: makeWorker("Karsten", "Kell", { active: false }),
  Mark: makeWorker("Mark", "Keller"),
  Mike: makeWorker("Mike", "Heavner"),
  Murphy: makeWorker("Jonathan", "Murphy"),
  Ross: makeWorker("Ross", "Arkin"),
  Rugg: makeWorker("Will", "Ruggiano"),
  Twait: makeWorker("Will", "Twait"),
};

export function makeAssignable(id: string): Assignable {
  // biome-ignore lint/style/noNonNullAssertion:
  return Object.values(WORKERS).find(e => e.id === id)!;
}

export function makeIdentity(id: string): Identity {
  // biome-ignore lint/style/noNonNullAssertion:
  return Object.values(WORKERS).find(e => e.id === id)!;
}

export function makeTemporal(input: TemporalInput) {
  if (input.instant) return makeInstant(new Date(Number(input.instant)));
  if (input.zdt) return makeZonedDateTime(input.zdt);
  throw "invariant violation - temporal";
}

export function makeInstant(d: Date) {
  return {
    __typename: "Instant" as const,
    epochMilliseconds: d.valueOf().toString(),
  } as Instant;
}

export function makeZonedDateTime(input: ZonedDateTimeInput) {
  const zdt = Temporal.Instant.fromEpochMilliseconds(
    Number(input.epochMilliseconds),
  ).toZonedDateTimeISO(input.timeZone);
  return {
    __typename: "ZonedDateTime" as const,
    epochMilliseconds: input.epochMilliseconds,
    timeZone: input.timeZone,
    millisecond: zdt.millisecond,
    second: zdt.second,
    minute: zdt.minute,
    hour: zdt.hour,
    day: zdt.day,
    month: zdt.month,
    year: zdt.year,
  } as ZonedDateTime;
}

export function makeActive(input: ActiveInput) {
  return {
    id: input.id,
    active: input.active,
    updatedAt: makeTemporal(input.updatedAt),
  } satisfies Activatable;
}

export function makeAssignee(input: AssigneeInput): Assignee {
  return {
    __typename: "Assignee" as const,
    id: input.id,
    assignedAt: makeTemporal(input.assignAt),
    assignedTo: makeAssignable(input.assignTo),
  } satisfies Assignee;
}

export function makeAuditable(input: AuditableInput) {
  return {
    __typename: "Auditable" as const,
    id: input.id,
    enabled: input.enabled,
    auditable: input.enabled,
  } satisfies Auditable;
}

export function makeDescription(input: DescriptionInput) {
  return {
    __typename: "Description" as const,
    id: encodeGlobalId({
      type: "workdescription",
      id: randomUUID(),
    }),
    value: makeDynamicString(input.value),
    description: makeDynamicString(input.value),
  } satisfies Description;
}

export function makeDisplayName(input: DisplayNameInput) {
  return {
    __typename: "DisplayName" as const,
    id: input.id,
    value: makeDynamicString(input.value),
    name: makeDynamicString(input.value),
  } satisfies DisplayName;
}

export function makeDynamicString(input: DynamicStringInput) {
  return {
    __typename: "DynamicString" as const,
    locale: input.locale,
    value: input.value,
  } satisfies DynamicString;
}

export function makeSchedule(input: ScheduleInput) {
  if (input.cron) return makeCronSchedule(input.cron);
  if (input.once) return makeOnceSchedule(input.once);
  throw "invariant violation - schedule";
}

export function makeOnceSchedule(input: TemporalInput) {
  return {
    __typename: "OnceSchedule" as const,
    once: makeTemporal(input),
  } satisfies OnceSchedule;
}

export function makeCronSchedule(cron: string) {
  return {
    __typename: "CronSchedule" as const,
    cron,
  } satisfies CronSchedule;
}

export function makeSop(input: SopInput) {
  return {
    id: input.id,
    link: input.link.toString(),
    sop: input.link.toString(),
  } satisfies Sop;
}

export function makeStatus(input: InputMaybe<ChecklistStatusInput>) {
  if (!input) return;
  if (input.open) return makeOpen(input.open);
  if (input.inProgress) return makeInProgress(input.inProgress);
  if (input.closed) return makeClosed(input.closed);
}

export function makeOpen(input: ChecklistOpenInput) {
  return {
    __typename: "ChecklistOpen" as const,
    id: input.id,
    openedAt: makeTemporal(input.at),
    openedBy: input.by ? makeIdentity(input.by) : undefined,
  } satisfies ChecklistOpen;
}

export function makeInProgress(input: ChecklistInProgressInput) {
  return {
    __typename: "ChecklistInProgress" as const,
    id: input.id,
    inProgressAt: makeTemporal(input.at),
    inProgressBy: input.by ? makeIdentity(input.by) : undefined,
  } satisfies ChecklistInProgress;
}

export function makeClosed(input: ChecklistClosedInput) {
  return {
    __typename: "ChecklistClosed" as const,
    id: input.id,
    closedAt: makeTemporal(input.at),
    closedBy: input.by ? makeIdentity(input.by) : undefined,
    closedBecause: input.because
      ? {
          code: input.because.code,
          note: input.because.note
            ? makeDynamicString(input.because.note)
            : undefined,
        }
      : undefined,
  } satisfies ChecklistClosed;
}

export function makeEdge<T extends { id: string }>(node: T) {
  return {
    node,
    cursor: node.id,
  };
}

export function makeConnection<T extends { id: string }>(nodes?: T[]) {
  return {
    edges: nodes?.map(makeEdge) ?? [],
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
    },
    totalCount: nodes?.length ?? 0,
  };
}

export function makeCounter(count: number) {
  return {
    __typename: "Counter" as const,
    count,
  } satisfies Counter;
}

export function makeFlag(enabled = true) {
  return {
    __typename: "Flag" as const,
    enabled,
  } satisfies Flag;
}

export function makeRegister(binary: string) {
  return {
    __typename: "Register" as const,
    binary,
  } satisfies Register;
}

export function makeResult(input: ChecklistResultInput): ChecklistResult {
  return {
    __typename: "ChecklistResult" as const,
    id: input.id,
    assignees: makeConnection(input.assignees.map(makeAssignee)),
    auditable: makeAuditable(input.auditable),
    attachments: makeConnection([]),
    name: makeDisplayName(input.name),
    required: input.required,
    status: makeStatus(input.status),
    value: input.value ? makeValue(input.value) : undefined,
  } satisfies ChecklistResult;
}

export function makeValue(
  input: ChecklistResultValueInput,
): ChecklistResultValue {
  if (typeof input.counter !== "undefined") {
    return {
      __typename: "Counter",
      count: input.counter,
    };
  }
  if (typeof input.flag !== "undefined") {
    return {
      __typename: "Flag",
      enabled: input.flag,
    };
  }
  if (typeof input.register !== "undefined") {
    return {
      __typename: "Register",
      binary: input.register,
    };
  }
  throw "invariant violation - value";
}

export function makeChecklist(input: ChecklistInput): Checklist {
  return {
    __typename: "Checklist" as const,
    id: input.id,
    active: makeActive(input.active),
    assignees: makeConnection(input.assignees?.map(makeAssignee)),
    attachments: makeConnection([]),
    auditable: makeAuditable(input.auditable),
    children: makeConnection([]),
    description: input.description
      ? makeDescription(input.description)
      : undefined,
    items: makeConnection(input.items?.map(makeChecklistItem)),
    metadata: {
      updatedAt: makeInstant(new Date("2024-08-01T00:00:00")),
    },
    name: makeDisplayName(input.name),
    required: input.required,
    schedule: input.schedule ? makeSchedule(input.schedule) : undefined,
    sop: input.sop ? makeSop(input.sop) : undefined,
    status: makeStatus(input.status),
  } satisfies Checklist;
}

export function makeChecklistItem(input: ChecklistItemInput) {
  if (input.checklist) return makeChecklist(input.checklist);
  if (input.result) return makeResult(input.result);
  throw "invariant violation - item";
}

const KELLER_TODOLIST = makeChecklist({
  id: testGlobalId(),
  active: {
    id: testGlobalId(),
    active: true,
    updatedAt: {
      instant: NOW.valueOf().toString(),
    },
  },
  assignees: [
    {
      id: testGlobalId(),
      assignAt: {
        instant: NOW.valueOf().toString(),
      },
      assignTo: WORKERS.Mark.id,
    },
  ],
  auditable: {
    id: testGlobalId(),
    enabled: false,
  },
  customerId: testGlobalId(),
  description: {
    id: testGlobalId(),
    value: {
      locale: "en",
      value: "A Day in the Life of Keller (abridged, volume 3.82)",
    },
  },
  items: [
    {
      result: {
        id: testGlobalId(),
        assignees: [],
        auditable: {
          id: testGlobalId(),
          enabled: true,
        },
        name: {
          id: testGlobalId(),
          value: {
            locale: "en",
            value: "Read people's standup notes",
          },
        },
        required: true,
        status: {
          open: {
            id: testGlobalId(),
            at: {
              instant: NOW.valueOf().toString(),
            },
            by: WORKERS.Bot.id,
          },
        },
        value: {
          flag: false,
        },
      },
    },
    {
      result: {
        id: testGlobalId(),
        assignees: [],
        auditable: {
          id: testGlobalId(),
          enabled: true,
        },
        name: {
          id: testGlobalId(),
          value: {
            locale: "en",
            value: "Write some arcane SQL procedure code",
          },
        },
        required: true,
        status: {
          open: {
            id: testGlobalId(),
            at: {
              instant: NOW.valueOf().toString(),
            },
            by: WORKERS.Bot.id,
          },
        },
        value: {
          flag: false,
        },
      },
    },
    {
      result: {
        id: testGlobalId(),
        assignees: [],
        auditable: {
          id: testGlobalId(),
          enabled: true,
        },
        name: {
          id: testGlobalId(),
          value: {
            locale: "en",
            value: "Note how many alarms are firing",
          },
        },
        required: true,
        status: {
          open: {
            id: testGlobalId(),
            at: {
              instant: NOW.valueOf().toString(),
            },
            by: WORKERS.Bot.id,
          },
        },
        value: {
          counter: 0,
        },
      },
    },
    {
      result: {
        id: testGlobalId(),
        assignees: [],
        auditable: {
          id: testGlobalId(),
          enabled: true,
        },
        name: {
          id: testGlobalId(),
          value: {
            locale: "en",
            value: "Fix the SQL code and ensure alarms settle",
          },
        },
        required: true,
        status: {
          open: {
            id: testGlobalId(),
            at: {
              instant: NOW.valueOf().toString(),
            },
            by: WORKERS.Bot.id,
          },
        },
        value: {
          flag: false,
        },
      },
    },
  ],
  name: {
    id: testGlobalId(),
    value: {
      locale: "en",
      value: "Keller's Personal Todos",
    },
  },
  required: true,
  schedule: {
    cron: "0 08,18 * * 1-5",
  },
  sop: {
    id: testGlobalId(),
    link: "https://www.youtube.com/watch?v=Vofkw9-O18c&list=PLi1CK-rsvz1Nfz83RMBp_9YaIgBWd0l9x",
  },
  status: {
    open: {
      id: testGlobalId(),
      at: {
        instant: NOW.valueOf().toString(),
      },
      by: WORKERS.Bot.id,
    },
  },
});

const GREENHOUSE_CHECK_OPEN = makeChecklist({
  id: testGlobalId(),
  active: {
    id: testGlobalId(),
    active: true,
    updatedAt: {
      instant: NOW.valueOf().toString(),
    },
  },
  assignees: [
    {
      id: testGlobalId(),
      assignAt: {
        instant: NOW.valueOf().toString(),
      },
      assignTo: WORKERS.Mark.id,
    },
  ],
  auditable: {
    id: testGlobalId(),
    enabled: false,
  },
  customerId: testGlobalId(),
  description: {
    id: testGlobalId(),
    value: {
      locale: "en",
      value: "Make sure the Greenhouse is in shape",
    },
  },
  items: [
    {
      result: {
        id: testGlobalId(),
        assignees: [],
        auditable: {
          id: testGlobalId(),
          enabled: true,
        },
        name: {
          id: testGlobalId(),
          value: {
            locale: "en",
            value: "Doors locked properly?",
          },
        },
        required: true,
        status: {
          open: {
            id: testGlobalId(),
            at: {
              instant: NOW.valueOf().toString(),
            },
            by: WORKERS.Bot.id,
          },
        },
        value: {
          flag: false,
        },
      },
    },
    {
      result: {
        id: testGlobalId(),
        assignees: [],
        auditable: {
          id: testGlobalId(),
          enabled: true,
        },
        name: {
          id: testGlobalId(),
          value: {
            locale: "en",
            value: "Count of broken panels",
          },
        },
        required: true,
        status: {
          open: {
            id: testGlobalId(),
            at: {
              instant: NOW.valueOf().toString(),
            },
            by: WORKERS.Bot.id,
          },
        },
        value: {
          counter: 0,
        },
      },
    },
  ],
  name: {
    id: testGlobalId(),
    value: {
      locale: "en",
      value: "Greenhouse Check",
    },
  },
  required: true,
  schedule: {
    cron: "0 08,18 * * 1-5",
  },
  sop: {
    id: testGlobalId(),
    link: "http://big-green.uk/greenhouse-checks",
  },
  status: {
    open: {
      id: testGlobalId(),
      at: {
        instant: NOW.valueOf().toString(),
      },
      by: WORKERS.Bot.id,
    },
  },
});

const ONCALL_DAILY = makeChecklist({
  id: testGlobalId(),
  active: {
    id: testGlobalId(),
    active: true,
    updatedAt: {
      instant: NOW.valueOf().toString(),
    },
  },
  assignees: [
    {
      id: testGlobalId(),
      assignAt: {
        instant: NOW.valueOf().toString(),
      },
      assignTo: WORKERS.Mike.id,
    },
  ],
  auditable: {
    id: testGlobalId(),
    enabled: true,
  },
  customerId: testGlobalId(),
  description: {
    id: testGlobalId(),
    value: {
      locale: "en",
      value: "Do these things every day",
    },
  },
  items: [
    {
      result: {
        id: testGlobalId(),
        assignees: [],
        auditable: {
          id: testGlobalId(),
          enabled: true,
        },
        name: {
          id: testGlobalId(),
          value: {
            locale: "en",
            value: "Alarm monitoring",
          },
        },
        required: true,
        status: {
          open: {
            id: testGlobalId(),
            at: {
              instant: NOW.valueOf().toString(),
            },
            by: WORKERS.Bot.id,
          },
        },
        value: {
          flag: false,
        },
      },
    },
    {
      result: {
        id: testGlobalId(),
        assignees: [],
        auditable: {
          id: testGlobalId(),
          enabled: true,
        },
        name: {
          id: testGlobalId(),
          value: {
            locale: "en",
            value: "Pipeline Health",
          },
        },
        required: true,
        status: {
          open: {
            id: testGlobalId(),
            at: {
              instant: NOW.valueOf().toString(),
            },
            by: WORKERS.Bot.id,
          },
        },
        value: {
          flag: false,
        },
      },
    },
    {
      result: {
        id: testGlobalId(),
        assignees: [],
        auditable: {
          id: testGlobalId(),
          enabled: true,
        },
        name: {
          id: testGlobalId(),
          value: {
            locale: "en",
            value: "Ticket Queue Monitoring",
          },
        },
        required: true,
        status: {
          open: {
            id: testGlobalId(),
            at: {
              instant: NOW.valueOf().toString(),
            },
            by: WORKERS.Bot.id,
          },
        },
        value: {
          counter: 0,
        },
      },
    },
    {
      result: {
        id: testGlobalId(),
        assignees: [],
        auditable: {
          id: testGlobalId(),
          enabled: true,
        },
        name: {
          id: testGlobalId(),
          value: {
            locale: "en",
            value: "DB/Data Warehouse Monitoring",
          },
        },
        required: true,
        status: {
          open: {
            id: testGlobalId(),
            at: {
              instant: NOW.valueOf().toString(),
            },
            by: WORKERS.Bot.id,
          },
        },
        value: {
          flag: false,
        },
      },
    },
    {
      result: {
        id: testGlobalId(),
        assignees: [],
        auditable: {
          id: testGlobalId(),
          enabled: true,
        },
        name: {
          id: testGlobalId(),
          value: {
            locale: "en",
            value: "Release Management",
          },
        },
        required: true,
        status: {
          open: {
            id: testGlobalId(),
            at: {
              instant: NOW.valueOf().toString(),
            },
            by: WORKERS.Bot.id,
          },
        },
        value: {
          flag: true,
        },
      },
    },
  ],
  name: {
    id: testGlobalId(),
    value: {
      locale: "en",
      value: "Daily Oncall Checks",
    },
  },
  required: true,
  schedule: {
    cron: "0 08,18 * * 1-5",
  },
  sop: {
    id: testGlobalId(),
    link: "https://www.notion.so/tendrel/Oncall-Responsibilities-c57c310cf24a48078bf76b8f7213330c",
  },
  status: {
    open: {
      id: testGlobalId(),
      at: {
        instant: NOW.valueOf().toString(),
      },
      by: WORKERS.Bot.id,
    },
  },
});

export let CHECKLISTS: Checklist[] = [
  KELLER_TODOLIST,
  GREENHOUSE_CHECK_OPEN,
  ONCALL_DAILY,
];

export function appendChecklist(input: ChecklistInput) {
  const c = makeChecklist(input);
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
