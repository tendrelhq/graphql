import { Box, Text } from "ink";
import { useSimulatorMode } from "./simulator/mode";

export function Simulator() {
  const mode = useSimulatorMode();

  return (
    <Box flexDirection="column">
      <Text color="yellowBright">Current mode: {mode.active}</Text>
    </Box>
  );
}
