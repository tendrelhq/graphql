import { Box, Spacer, Text, useInput } from "ink";
import { useFragment, useLazyLoadQuery } from "react-relay";
import AppRootNode, { type AppQuery } from "../__generated__/AppQuery.graphql";
import AppUserInfo, {
  type AppUserInfo_fragment$key,
} from "../__generated__/AppUserInfo_fragment.graphql";
import Help from "./Help";
import { ModeGuard, useSimulatorMode, type Mode } from "./simulator/mode";
import { useState } from "react";

export function App(props: { nodeId: string }) {
  // const data = useLazyLoadQuery<AppQuery>(AppRootNode, props);
  const mode = useSimulatorMode();
  const [isModeSelectActive, setIsModeSelectActive] = useState(false);

  useInput((input, key) => {
    switch (true) {
      case key.ctrl && input === "s":
        setIsModeSelectActive(true);
        break;
      case input === "?":
        mode.switch("help");
        break;
      case key.escape && isModeSelectActive:
        setIsModeSelectActive(false);
        break;
    }
  });

  return (
    <Box flexDirection="column">
      {/* <Header customer={data.customer} /> */}
      <Box>
        <ModeSelect
          isActive={isModeSelectActive || mode.active === "%unset%"}
          onModeChange={() => setIsModeSelectActive(false)}
        />
        <Spacer />
        <Text>
          {isModeSelectActive
            ? `<esc> returns to ${mode.active}`
            : "<C-s> to change mode"}
        </Text>
      </Box>
      <Box>
        <Spacer />
        <ModeGuard whenIn={["help"]}>
          <Text>
            {"<esc>"} returns to {mode.alternate}
          </Text>
        </ModeGuard>
        <ModeGuard whenNotIn={["help"]}>
          <Text>? for help</Text>
        </ModeGuard>
      </Box>
      <ModeGuard whenIn={["help"]}>
        <Help />
      </ModeGuard>
    </Box>
  );
}

function Header(props: { customer: AppUserInfo_fragment$key }) {
  const data = useFragment(AppUserInfo, props.customer);
  return (
    <Text color="yellowBright">
      {data.me.displayName} @ {data.name.value}
    </Text>
  );
}

interface ModeSelectProps {
  isActive: boolean;
  onModeChange: (newMode: Mode) => void;
}

function ModeSelect(props: ModeSelectProps) {
  const mode = useSimulatorMode();

  useInput(
    (input, key) => {
      for (const m of mode.available) {
        if (input.charAt(0).toLowerCase() === m.charAt(0)) {
          mode.switch(m);
          props.onModeChange(m);
          return;
        }
      }
    },
    { isActive: props.isActive },
  );

  return (
    <Box gap={1}>
      {mode.available.map((m, i) => (
        <Box key={m} gap={1}>
          <Text color={mode.active === m ? "green" : undefined}>
            <Text underline={mode.active !== m && props.isActive}>
              {m.charAt(0)}
            </Text>
            {m.substring(1)}
          </Text>
          {i + 1 < mode.available.length && <Text color="gray">|</Text>}
        </Box>
      ))}
    </Box>
  );
}
