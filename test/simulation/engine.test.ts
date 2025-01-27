import { describe, expect, test } from "bun:test";
import { ComponentStorage, type System, World } from "./engine";

type Position = {
  type: "Position";
  position: {
    x: number;
    y: number;
  };
};

type Transform = {
  type: "Transform";
  transform: {
    x: number;
    y: number;
  };
};

type Player = {
  type: "Player";
  player: {
    name: string;
  };
};

type Arena = {
  type: "Arena";
  arena: {
    length: number;
    width: number;
  };
};

describe("engine", () => {
  test("collision detector", () => {
    const w = new World();

    function makePlayer(
      name: string,
      origin: [number, number],
      invert?: boolean,
    ) {
      const p = w.newEntity();
      w.addComponent<Player>(p, {
        type: "Player",
        player: { name },
      });
      w.addComponent<Position>(p, {
        type: "Position",
        position: {
          x: origin[0],
          y: origin[1],
        },
      });
      w.addComponent<Transform>(p, {
        type: "Transform",
        transform: {
          x: invert ? -5 : +5,
          y: invert ? -5 : +5,
        },
      });
      return p;
    }

    // Three players
    const p1 = makePlayer("Jerry", [0, 0]);
    const p2 = makePlayer("Phil", [100, 100], true);
    const p3 = makePlayer("Bobby", [50, 50]);

    // One arena
    const a = w.newEntity();
    w.addComponent<Arena>(a, {
      type: "Arena",
      arena: {
        length: 200,
        width: 200,
      },
    });

    const move: System = {
      requires: new Set(["Position", "Transform"]),
      execute(world, entities) {
        for (const e of entities) {
          const { position } = world.getComponent<Position>(e, "Position");
          const { transform } = world.getComponent<Transform>(e, "Transform");
          position.x += transform.x;
          position.y += transform.y;
        }
      },
    };
    w.addSystem(move);

    const collisions: string[] = [];
    const detectCollision: System = {
      requires: new Set(["Position", "Player"]),
      execute(world, entities) {
        const arr = [...entities];
        for (let i = 0; i < arr.length - 1; i++) {
          const { position: posI } = world.getComponent<Position>(
            arr[i],
            "Position",
          );
          const { player: pI } = world.getComponent<Player>(arr[i], "Player");
          for (let j = i + 1; j < arr.length; j++) {
            const { position: posJ } = world.getComponent<Position>(
              arr[j],
              "Position",
            );
            const { player: pJ } = world.getComponent<Player>(arr[j], "Player");
            if (posI.x === posJ.x && posI.y === posJ.y) {
              collisions.push(
                `${pI.name} x ${pJ.name} at (${posI.x},${posJ.y})`,
              );
            }
          }
        }
      },
    };

    w.addSystem(detectCollision);

    const pos1 = w.getComponent<Position>(p1, "Position");
    const pos2 = w.getComponent<Position>(p2, "Position");
    const pos3 = w.getComponent<Position>(p3, "Position");

    for (let i = 0; i < 20; i++) {
      w.update();
    }

    expect(collisions).toEqual([
      "Phil x Bobby at (75,75)",
      "Jerry x Phil at (50,50)",
    ]);
    expect(pos1.position).toEqual({ x: 100, y: 100 });
    expect(pos2.position).toEqual({ x: 0, y: 0 });
    expect(pos3.position).toEqual({ x: 150, y: 150 });
  });

  describe("ComponentStorage", () => {
    test("add + has", () => {
      const s = new ComponentStorage();

      s.add(0, {
        type: "foo",
        foo: true,
      });
      expect(s.has(0, "foo")).toBeTrue();

      s.add(1, {
        type: "foo",
        foo: false,
      });
      expect(s.has(1, "foo")).toBeTrue();

      s.add(1, {
        type: "bar",
        bar: "foo",
      });
      expect(s.has(1, "bar")).toBeTrue();
      expect(s.hasAll(1, ["foo", "bar"])).toBeTrue();
      expect(s.hasAll(0, ["foo", "bar"])).toBeFalse();
    });

    test("add + find", () => {
      const s = new ComponentStorage();

      s.add(0, {
        type: "foo",
        foo: true,
      });
      s.add(1, {
        type: "foo",
        foo: false,
      });
      s.add(1, {
        type: "bar",
        bar: "foo",
      });

      expect([...s.find("foo")]).toEqual([0, 1]);
      expect([...s.findAll(["foo"])]).toEqual([0, 1]);
      expect([...s.findAll(["foo", "bar"])]).toEqual([1]);
    });

    test("add + remove", () => {
      const s = new ComponentStorage();

      s.add(0, {
        type: "foo",
        foo: true,
      });
      s.add(1, {
        type: "foo",
        foo: false,
      });
      s.add(1, {
        type: "bar",
        bar: "foo",
      });

      s.remove(0, "foo");
      expect(s.has(0, "foo")).toBeFalse();

      s.remove(1, "foo");
      expect(s.has(1, "foo")).toBeFalse();
      expect(s.has(1, "bar")).toBeTrue();

      s.remove(1, "bar");
      expect(s.has(1, "bar")).toBeFalse();
    });
  });
});
