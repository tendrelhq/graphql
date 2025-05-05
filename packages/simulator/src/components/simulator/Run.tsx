import { Box, Text } from "ink";
import { useLazyLoadQuery } from "react-relay";
import QueryNode, {
  type SimulatorPrepareQuery as QueryType,
} from "../../__generated__/SimulatorPrepareQuery.graphql";
import Loading from "../Loading";

interface Props {
  customerId: string;
  templateId: string;
}

export default function Run(props: Props) {
  const data = useLazyLoadQuery<QueryType>(QueryNode, props);

  if (
    data.customer.__typename !== "Organization" ||
    data.template.__typename !== "Task"
  ) {
    throw "invariant violated";
  }
  return (
    <Box flexDirection="column">
      <Text color="gray">Customer: {data.customer.name.value}</Text>
      <Text color="gray">Template: {data.template.name.value}</Text>
      <Loading message="Starting simulation..." />
    </Box>
  );
}
