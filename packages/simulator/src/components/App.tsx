import { Box, Spacer, Text, useInput } from "ink";
import { Suspense, useState } from "react";
import { useFragment, useLazyLoadQuery } from "react-relay";
import AppFragment, { type AppQuery } from "../__generated__/AppQuery.graphql";
import UserFragment, {
  type User_fragment$key,
} from "../__generated__/User_fragment.graphql";
import Help from "./Help";
import Loading from "./Loading";
import { Simulator } from "./simulator";
import { type Mode, ModeGuard, useSimulatorMode } from "./simulator/mode";

export function App() {
  const data = useLazyLoadQuery<AppQuery>(AppFragment, {});
  const mode = useSimulatorMode();
  const [isModeSelectActive, setIsModeSelectActive] = useState(
    mode.active === "%unset%",
  );

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
    <Suspense fallback={<Loading message="Spinning up the simulator..." />}>
      <Box flexDirection="column">
        <Header user={data.user} />
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
        <Box height={1}>
          <Spacer />
        </Box>
        <ModeGuard whenIn={["help"]}>
          <Help />
        </ModeGuard>
        <ModeGuard whenNotIn={["%unset%", "help"]}>
          <Simulator user={data.user} />
        </ModeGuard>
      </Box>
    </Suspense>
  );
}

function Header(props: { user: User_fragment$key }) {
  const user = useFragment(UserFragment, props.user);
  const mode = useSimulatorMode();

  return (
    <Box>
      <Box gap={2}>
        <Text color="yellowBright">{user.displayName}</Text>
      </Box>
      <Spacer />
      <ModeGuard whenNotIn={["help"]}>
        <Text>? for help</Text>
      </ModeGuard>
      <ModeGuard whenIn={["help"]}>
        <Text>
          {"<esc>"} returns to {mode.alternate}
        </Text>
      </ModeGuard>
    </Box>
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
