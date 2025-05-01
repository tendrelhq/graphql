import { createContext, useContext, useState } from "react";

const modes = {
  "%unset%": {
    //
  },
  config: {
    //
  },
  help: {
    //
  },
  main: {
    //
  },
};

export type Mode = keyof typeof modes;

type ModeContext = {
  active: Mode;
  alternate: Mode;
  available: Mode[];
  switch: (prev: Mode | "%") => void;
};
const ModeContext = createContext<ModeContext | undefined>(undefined);

export function useSimulatorMode() {
  const ctx = useContext(ModeContext);
  if (!ctx) {
    throw new Error("No ModeContext!");
  }
  return ctx;
}

export function ModeControl(props: React.PropsWithChildren) {
  const [mode, setMode] = useState<Mode>("%unset%");
  const [alt, setAlternate] = useState<Mode>("%unset%");
  return (
    <ModeContext.Provider
      value={{
        active: mode,
        alternate: alt,
        available: ["config", "main"],
        switch(newMode) {
          if (newMode === "%") {
            setMode(alt ?? "%unset%");
          } else {
            setAlternate(mode);
            setMode(newMode);
          }
        },
      }}
    >
      {props.children}
    </ModeContext.Provider>
  );
}

interface ModeGuardProps extends React.PropsWithChildren {
  whenIn?: Mode[];
  whenNotIn?: Mode[];
}

export function ModeGuard(props: ModeGuardProps) {
  const { active } = useSimulatorMode();
  if (props.whenNotIn?.includes(active)) {
    return null;
  }
  if (props.whenIn && !props.whenIn.includes(active)) {
    return null;
  }
  return props.children;
}
