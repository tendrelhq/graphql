import { graphql } from "relay-runtime";

// Just a bunch of Relay fragments, so relay-compiler will work correctly.

graphql`
  query AppQuery($customerId: ID!, $batchTemplateId: ID!) @throwOnFieldError {
    customer: node(id: $customerId) {
      ... on Organization {
        me {
          displayName
          role {
            name {
              value
            }
          }
        }
        name {
          value
        }
      }
    }
    batches: trackables(parent: $customerId, withImplementation: "Batch") {
      ...AppSimulation_fragment
    }
    batchTemplate: node(id: $batchTemplateId) {
      ...AppBatchInput_fragment
    }
  }
`;

graphql`
  fragment AppSimulation_fragment on TrackableConnection @throwOnFieldError {
    __id
    edges {
      node {
        id
        ...AppBatch_fragment
      }
    }
    totalCount
  }
`;

graphql`
  fragment AppBatch_fragment on Task @throwOnFieldError {
    id
    fields {
      edges {
        node {
          id
          ...Field_fragment
        }
      }
    }
    fsm {
      active {
        name {
          value
        }
        parent {
          ... on Location {
            name {
              value
            }
          }
        }
      }
    }
    name {
      value
    }
    parent {
      ... on Location {
        name {
          value
        }
      }
    }
    state {
      __typename
    }
  }
`;

graphql`
  fragment AppBatchInput_fragment on Task @throwOnFieldError {
    fields {
      edges {
        node {
          id
          valueType
          ...Field_fragment
        }
      }
    }
  }
`;

graphql`
  mutation AppGenerateBatchMutation(
    $batchTemplateId: ID!
    $batchId: String!
    $fields: [FieldInput!]!
    $location: ID!
    $connections: [ID!]!
  ) {
    createInstance(
      template: $batchTemplateId
      location: $location
      name: $batchId
      fields: $fields
    ) {
      edge {
        node {
          asTask @appendNode(connections: $connections, edgeTypeName: "TrackableEdge") {
            ...AppBatch_fragment
          }
        }
      }
    }
  }
`;
