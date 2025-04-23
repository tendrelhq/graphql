import { graphql } from "relay-runtime";

graphql`
  fragment Field_fragment on Field @throwOnFieldError {
    id
    name {
      value
    }
    value {
      __typename
      ... on BooleanValue {
        boolean
      }
      ... on EntityValue {
        entity {
          __typename
          id
        }
      }
      ... on NumberValue {
        number
      }
      ... on StringValue {
        string
      }
      ... on TimestampValue {
        timestamp
      }
    }
    valueType
  }
`;
