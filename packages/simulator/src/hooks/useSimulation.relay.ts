import { graphql } from "relay-runtime";

graphql`
  query useSimulationQuery($includeTime: Boolean = true) @throwOnFieldError {
    simulation @catch(to: NULL) {
      state
      ...useSimulationTime_fragment @include(if: $includeTime)
    }
  }
`;

graphql`
  query useSimulationActiveQuery($template: ID!, $withTaskState: [TaskStateName!]) @throwOnFieldError {
    instances: trackables(parent: $template, withImplementation: "Task", state: $withTaskState) {
      edges {
        node {
          id
          ...useTaskChain_fragment
          ...useTaskId_fragment
          ...useTaskName_fragment
          ...useTaskState_fragment
          ...useTaskTypes_fragment
          ...useSimulationInstance_fragment
          ... on Task {
            state {
              __typename
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
  fragment useSimulationTime_fragment on Simulation {
    time
  }
`;

graphql`
  fragment useSimulationInstance_fragment on Task @throwOnFieldError {
    id
    parent {
      ... on Location {
        name {
          value
        }
      }
    }
    ...useTaskChain_fragment
    ...useTaskId_fragment
    ...useTaskName_fragment
    ...useTaskState_fragment
    ...useTaskTypes_fragment
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
