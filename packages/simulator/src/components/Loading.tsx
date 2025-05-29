import assert from "node:assert";
import spinners from "cli-spinners";
import type { SpinnerName } from "cli-spinners";
import { Text } from "ink";
import { useEffect, useMemo, useState } from "react";
import { faker } from "../rng"; // This is the default global faker instance.

type Props = {
  message?: string;
};

const spinnerNames = Object.keys(spinners) as unknown as SpinnerName[];

export function Loading({ message = "Loading..." }: Props) {
  const [frame, setFrame] = useState(0);

  const spinner = useMemo(() => {
    const spinnerName = spinnerNames.at(
      faker.number.int(spinnerNames.length - 1),
    );
    assert(spinnerName);
    return spinners[spinnerName];
  }, []);

  useEffect(() => {
    const timer = setInterval(() => {
      setFrame(previousFrame => {
        const isLastFrame = previousFrame === spinner.frames.length - 1;
        return isLastFrame ? 0 : previousFrame + 1;
      });
    }, spinner.interval);
    return () => clearInterval(timer);
  }, [spinner]);

  return (
    <Text>
      {spinner.frames[frame]} {message}
    </Text>
  );
}

export default Loading;
