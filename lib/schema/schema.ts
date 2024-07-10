import { sql } from "@/datasources/postgres";
import {
  GraphQLBoolean,
  GraphQLNonNull,
  type GraphQLNullableType,
  GraphQLObjectType,
  GraphQLSchema,
  GraphQLString,
  GraphQLUnionType,
  printSchema,
} from "graphql";
import {
  connectionArgs,
  connectionDefinitions,
  connectionFromArray,
  connectionFromArraySlice,
  connectionFromPromisedArray,
  fromGlobalId,
  globalIdField,
  nodeDefinitions,
} from "graphql-relay";
import { match } from "ts-pattern";

function nonNull<T extends GraphQLNullableType>(t: T) {
  return new GraphQLNonNull(t);
}

type Id = string;
type Entity = {
  id: Id;
};

type ActivationState =
  | {
      parent: string;
      type: "ActivationState";
      isActive: true;
      activatedAt: string;
      deactivatedAt?: string;
    }
  | {
      parent: string;
      type: "ActivationState";
      isActive: false;
      activatedAt?: string;
      deactivatedAt: string;
    };

type Name = {
  parent: string;
  type: "Name";
  name: string;
};

type User = {
  id: Id;
  type: "User";
  name: string;
  createdAt: string;
  updatedAt: string;
  organizations: Id[];
};

const users: User[] = [
  {
    id: "1",
    type: "User",
    name: "Jerry Garcia",
    createdAt: "2024-07-21T20:51:26.203Z",
    updatedAt: "2024-07-21T20:51:26.203Z",
    organizations: ["1", "2", "3"],
  },
  {
    id: "2",
    type: "User",
    name: "Jason Bourne",
    createdAt: "2024-07-22T20:51:26.203Z",
    updatedAt: "2024-07-22T20:51:26.203Z",
    organizations: ["2"],
  },
  {
    id: "3",
    type: "User",
    name: "Bilbo Baggins",
    createdAt: "2024-07-23T20:51:26.203Z",
    updatedAt: "2024-07-23T20:51:26.203Z",
    organizations: ["3"],
  },
];

type Organization = {
  id: Id;
  type: "Organization";
  name: string;
  createdAt: string;
  updatedAt: string;
  templates: Id[];
};

const organizations: Organization[] = [
  {
    id: "1",
    type: "Organization",
    name: "Grateful Dead",
    createdAt: "2024-07-21T20:51:26.203Z",
    updatedAt: "2024-07-21T20:51:26.203Z",
    templates: ["1", "2"],
  },
  {
    id: "2",
    type: "Organization",
    name: "Bourne 2 Run",
    createdAt: "2024-07-22T20:51:26.203Z",
    updatedAt: "2024-07-22T20:51:26.203Z",
    templates: [],
  },
  {
    id: "3",
    type: "Organization",
    name: "Shire, co.",
    createdAt: "2024-07-23T20:51:26.203Z",
    updatedAt: "2024-07-23T20:51:26.203Z",
    templates: ["3"],
  },
];

type Template = {
  id: Id;
  type: "Template";
  createdAt: string;
  updatedAt: string;
  name: string;
};

const templates: Template[] = [
  {
    id: "1",
    type: "Template",
    createdAt: "2024-07-23T20:51:26.203Z",
    updatedAt: "2024-07-23T20:51:26.203Z",
    name: "A",
  },
  {
    id: "2",
    type: "Template",
    createdAt: "2024-07-23T20:51:26.203Z",
    updatedAt: "2024-07-23T20:51:26.203Z",
    name: "B",
  },
  {
    id: "3",
    type: "Template",
    createdAt: "2024-07-23T20:51:26.203Z",
    updatedAt: "2024-07-23T20:51:26.203Z",
    name: "C",
  },
];

const entities: Entity[] = [
  {
    id: "1",
  },
  {
    id: "2",
  },
  {
    id: "3",
  },
];

const components: (ActivationState | Name)[] = [
  {
    parent: "1",
    type: "ActivationState",
    isActive: true,
    activatedAt: new Date().toISOString(),
  },
  {
    parent: "1",
    type: "Name",
    name: "Number One",
  },
  {
    parent: "2",
    type: "Name",
    name: "Number Two",
  },
  {
    parent: "3",
    type: "ActivationState",
    isActive: false,
    deactivatedAt: new Date().toISOString(),
  },
];

function getExampleEntities() {
  return entities;
}

async function getCurrentUser() {
  const [u] = await sql<[User]>`
    SELECT
        workeruuid AS id,
        'User' AS type,
        workerfullname AS name,
        workercreateddate AS "createdAt",
        workermodifieddate AS "updatedAt"
    FROM public.worker
    WHERE workerfullname = 'Will Ruggiano';
  `;
  return u;
}

function getUser(id: string) {
  return users.find(e => e.id === id);
}

function getOrganization(id: string) {
  return organizations.find(e => e.id === id);
}

function getTemplate(id: string) {
  return templates.find(e => e.id === id);
}

type Archetype = Organization | User | Template;

const { nodeInterface, nodeField } = nodeDefinitions(
  gid => {
    const { type, id } = fromGlobalId(gid);
    return match(type as Archetype["type"])
      .with("Organization", () => getOrganization(id))
      .with("Template", () => getTemplate(id))
      .with("User", () => getUser(id))
      .exhaustive();
  },
  obj =>
    match(obj.type as Archetype["type"])
      .with("Organization", () => organizationType.name)
      .with("Template", () => templateType.name)
      .with("User", () => userType.name)
      .exhaustive(),
);

const userType: GraphQLObjectType = new GraphQLObjectType({
  name: "User",
  interfaces: [nodeInterface],
  fields: () => ({
    id: globalIdField(),
    createdAt: {
      type: nonNull(GraphQLString),
    },
    updatedAt: {
      type: nonNull(GraphQLString),
    },
    //
    name: {
      type: nonNull(GraphQLString),
    },
    //
    organizations: {
      type: organizationConnection,
      args: connectionArgs,
      async resolve(parent: User, args) {
        const orgs = await sql<Organization[]>`
          SELECT
              customeruuid AS id,
              'Organization' AS type,
              customername AS name,
              customercreateddate AS "createdAt",
              customermodifieddate AS "updatedAt"
          FROM public.workerinstance
          INNER JOIN public.customer
              ON workerinstancecustomerid = customerid
          WHERE workerinstanceworkerid = (
              SELECT workerid
              FROM public.worker
              WHERE workeruuid = ${parent.id}
          );
        `;
        return connectionFromArray(orgs, args);
      },
    },
  }),
});

const organizationType: GraphQLObjectType = new GraphQLObjectType({
  name: "Organization",
  interfaces: [nodeInterface],
  fields() {
    return {
      id: globalIdField(),
      createdAt: {
        type: nonNull(GraphQLString),
      },
      updatedAt: {
        type: nonNull(GraphQLString),
      },
      //
      name: {
        type: nonNull(GraphQLString),
      },
      //
      templates: {
        type: templateConnection,
        args: connectionArgs,
        async resolve(parent: Organization, args) {
          const templates = await sql<Template[]>`
            SELECT
                id,
                'Template' AS type,
                worktemplatecreateddate AS "createdAt",
                worktemplatemodifieddate AS "updatedAt",
                languagemastersource AS name
            FROM public.worktemplate
            INNER JOIN public.languagemaster
                ON worktemplatenameid = languagemasterid
            WHERE worktemplatecustomerid = (
                SELECT customerid
                FROM public.customer
                WHERE customeruuid = ${parent.id}
            );
          `;
          return connectionFromArray(templates, args);
        },
      },
    };
  },
});

const { connectionType: organizationConnection } = connectionDefinitions({
  nodeType: organizationType,
});

const templateType: GraphQLObjectType = new GraphQLObjectType({
  name: "Template",
  interfaces: [nodeInterface],
  fields() {
    return {
      id: globalIdField(),
      createdAt: {
        type: nonNull(GraphQLString),
      },
      updatedAt: {
        type: nonNull(GraphQLString),
      },
      //
      name: {
        type: nonNull(GraphQLString),
      },
      //
    };
  },
});

const { connectionType: templateConnection } = connectionDefinitions({
  nodeType: templateType,
});

const entityType: GraphQLObjectType = new GraphQLObjectType({
  name: "Entity",
  interfaces: [nodeInterface],
  fields() {
    return {
      id: globalIdField(),
      //
      components: {
        type: componentConnection,
        args: connectionArgs,
        resolve(parent, args, ctx, info) {
          return connectionFromArray(
            components.filter(v => v.parent === parent.id),
            args,
          );
        },
      },
    };
  },
});

const { connectionType: entityConnection } = connectionDefinitions({
  nodeType: entityType,
});

const nameComponentType: GraphQLObjectType = new GraphQLObjectType({
  name: "Name",
  interfaces: [nodeInterface],
  fields() {
    return {
      id: globalIdField(),
      name: {
        type: nonNull(GraphQLString),
      },
    };
  },
});

const activationStateComponentType: GraphQLObjectType = new GraphQLObjectType({
  name: "ActivationState",
  interfaces: [nodeInterface],
  fields() {
    return {
      id: globalIdField(),
      isActive: {
        type: nonNull(GraphQLBoolean),
      },
    };
  },
});

const componentType: GraphQLUnionType = new GraphQLUnionType({
  name: "Component",
  types: [activationStateComponentType, nameComponentType],
  resolveType(obj) {
    return obj.type;
  },
});

const { connectionType: componentConnection } = connectionDefinitions({
  nodeType: componentType,
});

const queryType = new GraphQLObjectType({
  name: "Query",
  fields: () => ({
    entity: nodeField,
    entities: {
      type: entityConnection,
      args: connectionArgs,
      resolve(_, args, __, info) {
        // TODO: this is where the magic will happen, or at least start to
        // happen :D
        // What we want is basically to extend/constraint the graphql spec in
        // such a way to model component relationships. So spreading a fragment,
        // for example, is like an INNER JOIN. Similarly we would have a
        // construct for a LEFT JOIN.
        // In practice, what we really want is a tree (i.e. given some root
        // node, such at the "current user") that is constructed using component
        // selections (i.e. inline fragments / INNER JOINs) and supports
        // bidirectional pagination and lazy loading (e.g. of connections).
        console.log(
          JSON.stringify({
            args,
            info,
          }),
        );
        return connectionFromArray(getExampleEntities(), args);
      },
    },
    user: {
      type: userType,
      resolve: async () => await getCurrentUser(),
    },
  }),
});

export const schema = new GraphQLSchema({
  query: queryType,
});

await Bun.write(`${__dirname}/relay.schema.gql`, printSchema(schema));
