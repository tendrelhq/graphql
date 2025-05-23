import { graphql } from "relay-runtime";

graphql`
  fragment useTaskId_fragment on Task @throwOnFieldError {
    id
  }
`;

graphql`
  fragment useTaskName_fragment on Task @throwOnFieldError {
    name {
      value
    }
    ...useTaskTypes_fragment
  }
`;

graphql`
  fragment useTaskChain_fragment on Task @throwOnFieldError {
    chain {
      edges {
        node {
          id
          ...useTaskId_fragment
          ...useTaskName_fragment
          ...useTaskState_fragment
          ...useTaskTypes_fragment
        }
      }
    }
  }
`;

graphql`
  fragment useTaskState_fragment on Task @throwOnFieldError {
    state @catch(to: NULL) {
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
  }
`;

graphql`
  fragment useTaskTypes_fragment on Task @throwOnFieldError {
    types
  }
`;
