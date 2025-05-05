import { graphql } from "relay-runtime";

graphql`
  query SimulatorConfigureQuery($customerId: ID!, $templateTypes: [String!]!) @throwOnFieldError {
    customer: node(id: $customerId) {
      __typename
      ... on Organization {
        name {
          value
        }
      }
    }
    templates(owner: $customerId, type: $templateTypes) {
      edges {
        node {
          asTask {
            id
            name {
              value
            }
          }
        }
      }
      totalCount
    }
  }
`;

graphql`
  query SimulatorPrepareQuery($customerId: ID!, $templateId: ID!) @throwOnFieldError {
    customer: node(id: $customerId) {
      __typename
      ... on Organization {
        name {
          value
        }
      }
    }
    template: node(id: $templateId) {
      __typename
      ... on Task {
        name {
          value
        }
      }
    }
  }
`;
