import type { ValueInput } from "@/schema/system/component";
import { Temporal } from "@js-temporal/polyfill";
import { Box, Text, useFocus } from "ink";
import { UncontrolledTextInput as TextInput } from "ink-text-input";
import { useState } from "react";
import { useFragment } from "react-relay";
import { P, match } from "ts-pattern";
import FieldFragmentNode, {
  type Field_fragment$key,
} from "../__generated__/Field_fragment.graphql";

export function Field({ queryRef }: { queryRef: Field_fragment$key }) {
  const data = useFragment(FieldFragmentNode, queryRef);

  const Value = () =>
    match(data.value)
      .with({ __typename: "BooleanValue", boolean: P.boolean }, v => (
        <Text>
          <Text color={v.boolean ? "" : "gray"} bold={v.boolean}>
            Yes
          </Text>
          /
          <Text color={v.boolean ? "gray" : ""} bold={!v.boolean}>
            No
          </Text>
        </Text>
      ))
      .with({ __typename: "EntityValue", entity: P.nonNullable }, v => {
        const entityId = v.entity.id.substring(v.entity.id.length - 8);
        return (
          <Text>
            ref: {entityId} ({v.entity.__typename})
          </Text>
        );
      })
      .with({ __typename: "NumberValue", number: P.number }, v => (
        <Text>{v.number.toLocaleString()}</Text>
      ))
      .with({ __typename: "StringValue", string: P.string }, v => (
        <Text>{v.string}</Text>
      ))
      .with({ __typename: "TimestampValue", timestamp: P.string }, v => (
        <Text>{Temporal.Instant.from(v.timestamp).toLocaleString()}</Text>
      ))
      .otherwise(() => <Text color="gray">null</Text>);

  return (
    <Box>
      <Text>{data.name.value}: </Text>
      <Value />
    </Box>
  );
}

export function FieldInput(props: {
  field: Field_fragment$key;
  onSubmit: (value: ValueInput | null) => void;
}) {
  const data = useFragment(FieldFragmentNode, props.field);
  const { isFocused } = useFocus({ autoFocus: true });
  const [submitted, setSubmitted] = useState(false);
  return (
    <Box>
      <Box marginRight={1}>
        <Text>
          {data.name.value}{" "}
          <Text color="gray" italic>
            {data.valueType}
          </Text>
          :
        </Text>
      </Box>
      <TextInput
        focus={isFocused}
        onSubmit={value => {
          if (value.length === 0) {
            props.onSubmit(null);
          } else {
            props.onSubmit(
              match(data.valueType)
                .with("boolean", () => ({
                  boolean: value.toLowerCase().charAt(0) === "y",
                }))
                .with("entity", () => ({ id: value }))
                .with("number", () => ({ number: Number.parseFloat(value) }))
                .with("string", () => ({ string: value }))
                .with("timestamp", () => ({
                  timestamp: new Date(value).toISOString(),
                }))
                .otherwise(() => null),
            );
          }
          setSubmitted(true);
        }}
      />
      {submitted && (
        <Box marginLeft={1}>
          <Text color="green">✓</Text>
        </Box>
      )}
    </Box>
  );
}
