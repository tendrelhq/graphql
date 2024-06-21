import {
  GraphQLNonNull,
  type GraphQLNullableType,
  GraphQLObjectType,
  GraphQLSchema,
  GraphQLString,
} from "graphql";
import {
  connectionArgs,
  connectionDefinitions,
  connectionFromArray,
  fromGlobalId,
  globalIdField,
  nodeDefinitions,
} from "graphql-relay";
import { match } from "ts-pattern";

function nonNull<T extends GraphQLNullableType>(t: T) {
  return new GraphQLNonNull(t);
}

type Id = string;

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
  createdAt: string;
  updatedAt: string;
  name: string;
};

const templates: Template[] = [
  {
    id: "1",
    createdAt: "2024-07-23T20:51:26.203Z",
    updatedAt: "2024-07-23T20:51:26.203Z",
    name: "A",
  },
  {
    id: "2",
    createdAt: "2024-07-23T20:51:26.203Z",
    updatedAt: "2024-07-23T20:51:26.203Z",
    name: "B",
  },
  {
    id: "3",
    createdAt: "2024-07-23T20:51:26.203Z",
    updatedAt: "2024-07-23T20:51:26.203Z",
    name: "C",
  },
];

function getCurrentUser() {
  return users[0];
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

type Archetype = Organization | User;

const { nodeInterface, nodeField } = nodeDefinitions(
  gid => {
    const { type, id } = fromGlobalId(gid);
    return match(type as Archetype["type"])
      .with("Organization", () => getOrganization(id))
      .with("User", () => getUser(id))
      .exhaustive();
  },
  obj =>
    match(obj.type as Archetype["type"])
      .with("Organization", () => organizationType.name)
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
      resolve(root: User, args) {
        return connectionFromArray(
          root.organizations.map(getOrganization),
          args,
        );
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
        resolve(root: Organization, args) {
          return connectionFromArray(root.templates.map(getTemplate), args);
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

const queryType = new GraphQLObjectType({
  name: "Query",
  fields: () => ({
    user: {
      type: userType,
      resolve: () => getCurrentUser(),
    },
    // locations: {
    //   type: new GraphQLList(entityType),
    //   resolve: () => getLocations(),
    // },
    // workers: {
    //   type: new GraphQLList(entityType),
    //   resolve: () => getWorkers(),
    // },
    node: nodeField,
  }),
});

export const Schema = new GraphQLSchema({
  query: queryType,
});
