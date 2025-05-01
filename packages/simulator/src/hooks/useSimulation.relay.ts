import { graphql } from "relay-runtime";

graphql`
  query useSimulationQuery @throwOnFieldError {
    simulation @catch(to: NULL) {
      state
      time
    }
  }
`;

graphql`
  query useSimulationActiveQuery($template: ID!) @throwOnFieldError {
    instances: trackables(parent: $template, withImplementation: "Task") {
      edges {
        node {
          id
          ...useTaskChain_fragment
          ...useTaskId_fragment
          ...useTaskName_fragment
          ...useTaskState_fragment
          ...useTaskTypes_fragment
          ... on Task {
            parent {
              ... on Location {
                name {
                  value
                }
              }
            }
          }
        }
      }
      totalCount
    }
    simulation @catch(to: NULL) {
      state
      time
    }
  }
`;

graphql`
  query useSimulationStateMachineQuery($root: ID!) @throwOnFieldError {
    node(id: $root) {
      ... on Task {
        __typename
        fsm {
          active {
            hash
            id
            ...useTaskName_fragment
            ...useTaskState_fragment
          }
          transitions {
            edges {
              id
              node {
                ...useTaskName_fragment
              }
            }
            totalCount
          }
        }
        hash
        id
        state {
          __typename
        }
      }
    }
    simulation @catch(to: NULL) {
      state
    }
  }
`;
