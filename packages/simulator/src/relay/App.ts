import { graphql } from "relay-runtime";

graphql`
  query AppQuery @throwOnFieldError {
    user {
      ...User_fragment
      organizations {
        ...AppSelectOwner_fragment
      }
    }
  }
`;

graphql`
  fragment AppSelectOwner_fragment on OrganizationConnection @throwOnFieldError {
    edges {
      node {
        id
        name {
          value
        }
      }
    }
    totalCount
  }
`;

graphql`
  query AppSelectedOwnerQuery($id: ID!) @throwOnFieldError {
    node(id: $id) {
      ... on Organization {
        __typename
        id
        name {
          value
        }
      }
    }
    templates(owner: $id) {
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
  query AppSelectedTemplateQuery($id: ID!) @throwOnFieldError {
    node(id: $id) {
      ... on Task {
        __typename
        id
        name {
          value
        }
      }
    }
  }
`;
