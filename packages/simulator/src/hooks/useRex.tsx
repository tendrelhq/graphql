import { createContext, useContext, useMemo } from "react";
import { useRelayEnvironment } from "react-relay";
import { Rex, type TimeOptions } from "../rex";

const Context = createContext<Rex | null>(null);

interface Props extends React.PropsWithChildren {
  options?: TimeOptions;
}

export function RexRoot({ children, options }: Props) {
  const environment = useRelayEnvironment();
  const instance = useMemo(
    () => new Rex(environment, options),
    [environment, options],
  );
  return <Context.Provider value={instance}>{children}</Context.Provider>;
}

export function useRex() {
  const ctx = useContext(Context);
  if (!ctx) {
    throw new Error("useRex() called outside a <RexRoot>");
  }
  return ctx;
}
