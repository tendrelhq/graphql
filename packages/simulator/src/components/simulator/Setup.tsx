import { map } from "@/util";
import type { Faker } from "@faker-js/faker";
import { Box, Text, useInput } from "ink";
import SelectInput from "ink-select-input";
import TextInput from "ink-text-input";
import { useMemo, useState } from "react";
import { useFragment } from "react-relay";
import { createCustomer } from "../../../corpus/runtime/batch.config";
import UserFragment, {
  type User_fragment$key,
} from "../../__generated__/User_fragment.graphql";
import { createTestContext } from "@/test/prelude";
import Loading from "../Loading";

// FIXME: shouldn't need this!
const ctx = await createTestContext();

interface Props {
  faker: Faker;
  onSelect: (customerId: string) => void;
  user: User_fragment$key;
}

export default function Setup(props: Props) {
  const user = useFragment(UserFragment, props.user);
  const [generating, setGenerating] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");

  const items = useMemo(() => {
    return user.organizations.edges
      .flatMap(e => {
        const i = e.node.name.value
          .toLowerCase()
          .indexOf(searchTerm.toLowerCase());
        if (i !== -1) {
          const prefix = e.node.name.value.substring(0, i);
          const match = e.node.name.value.substring(i, i + searchTerm.length);
          const suffix = e.node.name.value.substring(i + searchTerm.length);
          return {
            key: e.node.id,
            label: e.node.id,
            value: {
              node: e.node,
              prefix,
              match,
              suffix,
            },
          };
        }
        return [];
      })
      .slice(0, 10);
  }, [searchTerm, user]);

  type Item = (typeof items)[number];

  useInput((input, key) => {
    if (key.ctrl && input === "g") {
      setGenerating(true);
      createCustomer(props.faker.company.name(), ctx).then(customer =>
        props.onSelect(customer.id),
      );
    }
  });

  return (
    <Box flexDirection="column">
      <Box gap={1}>
        <Text color="blue">Select a customer:</Text>
        {generating ? (
          <Loading message="" />
        ) : (
          <TextInput value={searchTerm} onChange={setSearchTerm} />
        )}
      </Box>
      {!generating && (
        <Box flexDirection="column" gap={1}>
          <SelectInput
            items={items}
            itemComponent={item => (
              <Box gap={1}>
                <Box minWidth="40%">
                  <Text>
                    {(item as Item).value.prefix}
                    <Text underline>{(item as Item).value.match}</Text>
                    {(item as Item).value.suffix}
                  </Text>
                </Box>
                {map((item as Item).value.node.activatedAt, t => (
                  <Text color="gray">
                    {new Date(Number(t)).toLocaleString()}
                  </Text>
                ))}
              </Box>
            )}
            onSelect={item => props.onSelect(item.value.node.id)}
          >
            {}
          </SelectInput>
          <Text color="gray">or press {"<C-g>"} to generate a new one.</Text>
        </Box>
      )}
    </Box>
  );
}
