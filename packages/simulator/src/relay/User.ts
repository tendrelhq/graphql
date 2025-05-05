import { graphql } from "relay-runtime";

graphql`
  fragment User_fragment on User @throwOnFieldError {
    displayName
    organizations {
      edges {
        node {
          id
          activatedAt
          name {
            value
          }
        }
      }
      totalCount
    }
  }
`;
