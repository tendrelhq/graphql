import spinners from "cli-spinners";
import type { SpinnerName } from "cli-spinners";
import { Text } from "ink";
import { useEffect, useState } from "react";

type Props = {
  /**
   * @default "Loading..."
   */
  message?: string;
  /**
   * Type of a spinner.
   * @default "dots"
   * @see {@link https://github.com/sindresorhus/cli-spinners}
   */
  type?: SpinnerName;
};

export default function Loading({
  message = "Loading...",
  type = "dots",
}: Props) {
  const [frame, setFrame] = useState(0);
  const spinner = spinners[type];

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
