import { randomUUID } from "node:crypto";
import { type Customer, Language, type Location } from "@/schema/types";

export let customers: Customer[] = [
  {
    id: randomUUID(),
    name: "Tendrel",
    defaultLanguage: Language.En,
  },
  {
    id: randomUUID(),
    name: "Demo",
    defaultLanguage: Language.En,
  },
  {
    id: randomUUID(),
    name: "Keller",
    defaultLanguage: Language.Es,
  },
];

const sites: Location[] = [
  {
    id: randomUUID(),
    customerId: customers[0].id,
    parentId: null,
    name: "Tendrel - A",
    tags: [
      {
        id: randomUUID(),
        name: "A",
        type: "type",
      },
    ],
  },
  {
    id: randomUUID(),
    customerId: customers[1].id,
    parentId: null,
    name: "Demo - A",
    tags: [],
  },
  {
    id: randomUUID(),
    customerId: customers[2].id,
    parentId: null,
    name: "Keller - A",
    tags: [],
  },
];

export let locations = [
  ...sites,
  {
    id: randomUUID(),
    customerId: customers[0].id,
    parentId: sites[0].id,
    name: "Tendrel - AB",
    tags: [],
  },
  {
    id: randomUUID(),
    customerId: customers[1].id,
    parentId: sites[1].id,
    name: "Demo - AB",
    tags: [],
  },
  {
    id: randomUUID(),
    customerId: customers[2].id,
    parentId: sites[2].id,
    name: "Keller - AB",
    tags: [],
  },
];
