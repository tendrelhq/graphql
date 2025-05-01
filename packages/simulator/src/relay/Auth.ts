import { graphql } from "relay-runtime";

graphql`
  fragment Auth_fragment on User @throwOnFieldError {
    organizations {
      edges {
        node {
          id
          name {
            value
          }
          activatedAt
        }
      }
      totalCount
    }
  }
`;
