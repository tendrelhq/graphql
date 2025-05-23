import { graphql } from "relay-runtime";

graphql`
  fragment User_fragment on User @throwOnFieldError {
    displayName
  }
`;
