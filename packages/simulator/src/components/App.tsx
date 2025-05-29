import assert from "node:assert";
import { type Customer, createTestContext } from "@/test/prelude";
import { map } from "@/util";
import { Box, Spacer, Text, useInput } from "ink";
import SelectInput from "ink-select-input";
import { Suspense, useCallback, useEffect, useMemo, useState } from "react";
import {
  type PreloadedQuery,
  useFragment,
  useLazyLoadQuery,
  usePreloadedQuery,
  useQueryLoader,
} from "react-relay";
import AppFragment, { type AppQuery } from "../__generated__/AppQuery.graphql";
import SelectOwnerFragment, {
  type AppSelectOwner_fragment$key,
} from "../__generated__/AppSelectOwner_fragment.graphql";
import SelectedOwnerQuery, {
  type AppSelectedOwnerQuery,
  type AppSelectedOwnerQuery as SelectedOwner,
} from "../__generated__/AppSelectedOwnerQuery.graphql";
import SelectedTemplateQuery, {
  type AppSelectedTemplateQuery as SelectedTemplate,
} from "../__generated__/AppSelectedTemplateQuery.graphql";
import UserFragment, {
  type User_fragment$key,
} from "../__generated__/User_fragment.graphql";
import config from "../config";
import { Simulator } from "../hooks/useSimulation";
import { createCustomer } from "../lib";
import { Trie } from "../lib/Trie";
import { chunkArray } from "../lib/chunk";
import { faker, seed } from "../rng";
import { Id } from "./Id";
import { Input } from "./Input";
import { Loading } from "./Loading";

export function App() {
  const [owner, setOwner] = useState("");
  const [template, setTemplate] = useState("");
  const data = useLazyLoadQuery<AppQuery>(AppFragment, {});

  const ownerQuery = useQueryLoader<SelectedOwner>(SelectedOwnerQuery);
  const templateQuery = useQueryLoader<SelectedTemplate>(SelectedTemplateQuery);

  const onSelectOwner = useCallback(
    (id: string) => {
      setOwner(id);
      ownerQuery[1]({ id });
    },
    [ownerQuery],
  );

  const onSelectTemplate = useCallback(
    (id: string) => {
      setTemplate(id);
      templateQuery[1]({ id });
    },
    [templateQuery],
  );

  const ParseArguments = useCallback(() => {
    if (owner === "") {
      return (
        <SelectOwner
          owners={data.user.organizations}
          onSelect={onSelectOwner}
        />
      );
    }
    if (template === "") {
      return (
        ownerQuery[0] && (
          <SelectTemplate onSelect={onSelectTemplate} parent={ownerQuery[0]} />
        )
      );
    }
    return <Simulator owner={owner} template={template} />;
  }, [data, onSelectOwner, onSelectTemplate, owner, ownerQuery, template]);

  useInput(
    (_, key) => {
      if (key.escape) setOwner("");
    },
    {
      isActive: owner !== "" && template === "",
    },
  );

  return (
    <Box flexDirection="column">
      <Box height={1} />
      <Suspense>
        <Banner user={data.user} />
      </Suspense>
      <Box height={1} />
      {map(ownerQuery[0], queryRef => (
        <Suspense>
          <Owner parent={queryRef} />
        </Suspense>
      ))}
      {map(templateQuery[0], queryRef => (
        <Suspense>
          <Template parent={queryRef} />
        </Suspense>
      ))}
      {owner !== "" && <Box height={1} />}
      <Suspense>
        <ParseArguments />
      </Suspense>
    </Box>
  );
}

function GenerateCustomer(props: { onComplete: (customer: Customer) => void }) {
  useEffect(() => {
    createCustomer(
      { faker, seed, multiplicity: config.multiplicity },
      ctx,
    ).then(c => setTimeout(() => props.onComplete(c), 2000));
  }, [props]);
  return <Loading message="Generating a brand new customer..." />;
}

function Banner(props: { user: User_fragment$key }) {
  const user = useFragment(UserFragment, props.user);
  return (
    <Box gap={1}>
      <Text>Logged in as:</Text>
      <Text color="yellowBright">{user.displayName}</Text>
    </Box>
  );
}

function Owner(props: { parent: PreloadedQuery<SelectedOwner> }) {
  const { node } = usePreloadedQuery(SelectedOwnerQuery, props.parent);
  assert(node.__typename === "Organization");
  return <Selected {...node} />;
}

function Template(props: { parent: PreloadedQuery<SelectedTemplate> }) {
  const { node } = usePreloadedQuery(SelectedTemplateQuery, props.parent);
  assert(node.__typename === "Task");
  return <Selected {...node} />;
}

function Selected(data: { id: string; name: { value: string } }) {
  return (
    <Box>
      <Box gap={1}>
        <Text color="gray">{">"}</Text>
        <Box minWidth="25%">
          <Text bold>{data.name.value}</Text>
        </Box>
      </Box>
      <Id id={data.id} slice={24} />
    </Box>
  );
}

// FIXME: shouldn't need this!
const ctx = await createTestContext();

function SelectOwner({
  onSelect,
  ...props
}: {
  onSelect: (owner: string) => void;
  owners: AppSelectOwner_fragment$key;
}) {
  const owners = useFragment(SelectOwnerFragment, props.owners);
  const [isGenerating, setGenerating] = useState(false);

  const trie = useMemo(() => {
    const trie = new Trie<(typeof owners.edges)[number]["node"]>();
    for (const { node } of owners.edges) {
      trie.insert(node.name.value, node);
    }
    return trie;
  }, [owners]);

  useInput(
    (input, key) => {
      if (key.ctrl && input === "g") {
        setGenerating(true);
      }
    },
    { isActive: !isGenerating },
  );

  if (config.auto_select_owner) {
    return (
      <AutoSelect
        query={config.auto_select_owner}
        items={owners.edges.map(e => e.node)}
        onSelect={onSelect}
      />
    );
  }

  if (config.skip_owner_prompt || isGenerating) {
    return <GenerateCustomer onComplete={c => onSelect(c.id)} />;
  }

  return (
    <Select
      onSelect={onSelect}
      placeholder="  < Search for a customer (<C-g> generates a brand new one)"
      trie={trie}
    />
  );
}

function SelectTemplate(props: {
  onSelect: (template: string) => void;
  parent: PreloadedQuery<AppSelectedOwnerQuery>;
}) {
  const { templates } = usePreloadedQuery(SelectedOwnerQuery, props.parent);

  const trie = useMemo(() => {
    const trie = new Trie<(typeof templates.edges)[number]["node"]["asTask"]>();
    for (const { node } of templates.edges) {
      trie.insert(node.asTask.name.value, node.asTask);
    }
    return trie;
  }, [templates]);

  switch (true) {
    case !!config.auto_select_template:
      return (
        <AutoSelect
          query={config.auto_select_template}
          items={templates.edges.map(e => e.node.asTask)}
          onSelect={props.onSelect}
        />
      );
    default:
      return <Select onSelect={props.onSelect} placeholder="" trie={trie} />;
  }
}

type SelectItem = {
  key: string;
  label: string;
  value: { id: string; name: { value: string } };
};

type SelectProps = {
  onSelect: (id: string) => void;
  placeholder?: string;
  trie: Trie<{ id: string; name: { value: string } }>;
};

type AutoSelectProps = Pick<SelectProps, "onSelect"> & {
  query: string;
  items: readonly Readonly<SelectItem["value"]>[];
};

function AutoSelect(props: AutoSelectProps) {
  useEffect(() => {
    for (const node of props.items) {
      if (node.id === props.query || node.name.value === props.query) {
        props.onSelect(node.id);
        return;
      }
    }

    throw new Error(
      `auto selection failed: query: ${props.query}, items: ${props.items}`,
    );
  }, [props]);

  return null;
}

function Select({ onSelect, placeholder, trie }: SelectProps) {
  const [page, setPage] = useState(0);
  const [searchTerm, setSearchTerm] = useState("");

  const pages: SelectItem[][] = useMemo(() => {
    const nodes = trie.findAllNodesWithPrefix(searchTerm).map(node => {
      assert(node.value);
      return {
        key: node.value.id,
        label: node.value.id,
        value: node.value,
      };
    });
    return chunkArray(nodes, 10);
  }, [searchTerm, trie]);

  const [hasNext, hasPrev] = useMemo(
    () => [page + 1 < pages.length, page > 0],
    [page, pages],
  );

  useInput(
    useCallback(
      (input, key) => {
        if (key.ctrl && input === "n" && hasNext) {
          setPage(prev => prev + 1);
        }
        if (key.ctrl && input === "p" && hasPrev) {
          setPage(prev => prev - 1);
        }
      },
      [hasNext, hasPrev],
    ),
  );

  return (
    <Box flexDirection="column">
      <Box gap={1}>
        <Text color="blue">{">"}</Text>
        <Input
          placeholder={placeholder}
          value={searchTerm}
          onChange={value => {
            setPage(0);
            setSearchTerm(value);
          }}
        />
      </Box>
      <SelectInput
        items={pages[page]}
        itemComponent={item => <SelectInputItem {...(item as SelectItem)} />}
        onSelect={item => onSelect(item.label)}
      >
        {}
      </SelectInput>
      <Box height={1} />
      {(hasNext || hasPrev) && (
        <Text color="gray">
          {hasNext && "<C-n>"}
          {hasNext && hasPrev && "/"}
          {hasPrev && "<C-p>"} {hasNext && "next"}
          {hasNext && hasPrev && "/"}
          {hasPrev && "previous"} page
        </Text>
      )}
    </Box>
  );
}

function SelectInputItem({ value: item }: SelectItem) {
  return (
    <Box>
      <Box minWidth="25%">
        <Text>{item.name.value}</Text>
        {/* <Text>{item.value.prefix}</Text> */}
        {/* <Text underline>{item.value.match}</Text> */}
        {/* <Text>{item.value.suffix}</Text> */}
      </Box>
      <Spacer />
      <Id id={item.id} slice={24} />
    </Box>
  );
}
