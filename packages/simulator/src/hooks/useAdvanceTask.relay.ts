import { graphql } from "relay-runtime";

graphql`
  mutation useAdvanceTaskMutation($root: AdvanceTaskOptions!, $choice: AdvanceTaskOptions!) {
    advance(opts: { fsm: $root, task: $choice }) {
      diagnostics {
        code
        message
      }
      instantiations {
        node {
          id
        }
      }
      root {
        ...useTaskChain_fragment
        ...useTaskId_fragment
        ...useTaskName_fragment
      }
    }
  }
`;
