import { createContext, useContext, useState } from "react";

const modes = {
  "%unset%": {
    //
  },
  start: {
    //
  },
  history: {
    //
  },
  help: {
    //
  },
};

export type Mode = keyof typeof modes;
export type UserMode = Exclude<Mode, "%unset%" | "help">;

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
        available: Object.keys(modes).filter(
          m => !["%unset%", "help"].includes(m),
        ) as UserMode[],
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
  if (
    props.whenNotIn?.includes(active) ||
    (props.whenIn && !props.whenIn?.includes(active))
  ) {
    return null;
  }
  return props.children;
}
