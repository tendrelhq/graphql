import { Box, Text, useInput } from "ink";
import { useSimulatorMode } from "./simulator/mode";

function Help() {
  const mode = useSimulatorMode();

  useInput((_, key) => {
    if (key.escape) {
      mode.switch("%");
    }
  });

  return (
    <Box>
      <Text>
        This is the help text. It is not very helpful at the moment :D
      </Text>
    </Box>
  );
}

export default Help;
