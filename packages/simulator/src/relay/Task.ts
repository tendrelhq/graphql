import { graphql } from "relay-runtime";

graphql`
  fragment TaskChain_fragment on TaskConnection @throwOnFieldError {
    edges {
      node {
        id
        name {
          value
        }
        state @catch(to: NULL) {
          ...TaskState_fragment
        }
        types
      }
    }
  }
`;

graphql`
  fragment TaskState_fragment on TaskState {
    __typename
    ... on Open {
      openedAt {
        value
      }
    }
    ... on InProgress {
      openedAt {
        value
      }
      inProgressAt {
        value
      }
    }
    ... on Closed {
      openedAt {
        value
      }
      inProgressAt {
        value
      }
      closedAt {
        value
      }
    }
  }
`;
