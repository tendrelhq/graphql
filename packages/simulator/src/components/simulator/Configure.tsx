import { Box, Text } from "ink";
import { useLazyLoadQuery } from "react-relay";
import SimulatorConfigureQueryNode, {
  type SimulatorConfigureQuery,
} from "../../__generated__/SimulatorConfigureQuery.graphql";
import { useMemo, useState } from "react";
import TextInput from "ink-text-input";
import SelectInput from "ink-select-input";

interface Props {
  customerId: string;
  onSelect: (templateId: string) => void;
}

export default function Configure(props: Props) {
  const data = useLazyLoadQuery<SimulatorConfigureQuery>(
    SimulatorConfigureQueryNode,
    {
      customerId: props.customerId,
      templateTypes: ["Batch", "Runtime"],
    },
  );
  const [searchTerm, setSearchTerm] = useState("");

  const items = useMemo(() => {
    return data.templates.edges
      .flatMap(e => {
        const t = e.node.asTask;
        const i = t.name.value.toLowerCase().indexOf(searchTerm.toLowerCase());
        if (i !== -1) {
          const prefix = t.name.value.substring(0, i);
          const match = t.name.value.substring(i, i + searchTerm.length);
          const suffix = t.name.value.substring(i + searchTerm.length);
          return {
            key: t.id,
            label: t.id,
            value: {
              node: t,
              prefix,
              match,
              suffix,
            },
          };
        }
        return [];
      })
      .slice(0, 10);
  }, [searchTerm, data.templates]);

  type Item = (typeof items)[number];

  if (data.customer.__typename !== "Organization") {
    throw "invariant violated";
  }

  return (
    <Box flexDirection="column">
      <Box gap={1}>
        <Text>Select a customer:</Text>
        <Text bold>{data.customer.name.value}</Text>
        <Text bold color="green">
          {"✓"}
        </Text>
      </Box>
      <Box gap={1}>
        <Text color="blue">Select a template:</Text>
        <TextInput value={searchTerm} onChange={setSearchTerm} />
      </Box>
      <SelectInput
        items={items}
        itemComponent={item => (
          <Box gap={1}>
            <Box minWidth="20%">
              <Text>
                {(item as Item).value.prefix}
                <Text underline>{(item as Item).value.match}</Text>
                {(item as Item).value.suffix}
              </Text>
            </Box>
            <Text color="gray">{(item as Item).value.node.id.slice(-8)}</Text>
          </Box>
        )}
        onSelect={item => props.onSelect(item.value.node.id)}
      >
        {}
      </SelectInput>
    </Box>
  );
}
