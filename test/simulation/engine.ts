import { assert, assertNonNull } from "@/util";

export type Entity = number;

export type Component = {
  readonly type: string;
};

export interface System {
  requires: Set<Component["type"]>;
  execute(world: World, entities: Set<Entity>): void;
}

export class World {
  private nextEntity = 0;
  private entities: Set<Entity>;
  private components: ComponentStorage;
  private systems: Map<Set<Component["type"]>, Set<System>>;

  constructor() {
    this.entities = new Set();
    this.components = new ComponentStorage();
    this.systems = new Map();
  }

  newEntity(): Entity {
    const e = this.nextEntity++;
    this.entities.add(e);
    return e;
  }

  hasEntity(entity: Entity) {
    return this.entities.has(entity);
  }

  addComponent<T extends Component>(entity: Entity, component: T) {
    assert(this.hasEntity(entity), `Entity (${entity}) does not exist.`);
    assert(
      !this.hasComponent(entity, component.type),
      `Entity (${entity}) already has a '${component.type}'.`,
    );
    this.components.add(entity, component);
  }

  getComponent<T extends Component>(entity: Entity, component: T["type"]): T {
    const c = this.components.get(entity, component);
    return assertNonNull(c) as T;
  }

  removeComponent(entity: Entity, componentType: Component["type"]) {
    this.components.remove(entity, componentType);
  }

  hasComponent(entity: Entity, componentType: Component["type"]) {
    return this.components.has(entity, componentType);
  }

  addSystem<T extends System>(system: T) {
    if (!this.systems.has(system.requires)) {
      this.systems.set(system.requires, new Set());
    }
    this.systems.get(system.requires)?.add(system);
  }

  removeSystem<T extends System>(system: T): boolean {
    return this.systems.delete(system.requires);
  }

  update() {
    for (const [cs, ss] of this.systems.entries()) {
      const es = this.components.findAll(cs);
      if (es.size) {
        for (const s of ss) {
          s.execute(this, es);
        }
      }
    }
  }
}

export class ComponentStorage {
  private storage: Map<Component["type"], Map<Entity, Component>>;

  constructor() {
    this.storage = new Map();
  }

  add<T extends Component>(entity: Entity, component: T) {
    if (!this.storage.has(component.type)) {
      this.storage.set(component.type, new Map());
    }
    this.storage.get(component.type)?.set(entity, component);
  }

  has(entity: Entity, componentType: Component["type"]) {
    return this.storage.get(componentType)?.has(entity) === true;
  }

  hasAll(entity: Entity, components: Iterable<Component["type"]>) {
    for (const c of components) {
      if (!this.storage.get(c)?.has(entity)) {
        return false;
      }
    }
    return true;
  }

  find(components: Component["type"]): Set<Entity> {
    return new Set(this.storage.get(components)?.keys() ?? []);
  }

  findAll(components: Iterable<Component["type"]>): Set<Entity> {
    const cs = [...components];
    let es = new Set(this.storage.get(cs[0])?.keys() ?? []);
    for (let i = 1; i < cs.length; i++) {
      es = es.intersection(new Set(this.storage.get(cs[i])?.keys() ?? []));
    }
    return es;
  }

  get(entity: Entity, component: Component["type"]) {
    return this.storage.get(component)?.get(entity);
  }

  remove(entity: Entity, componentType: Component["type"]) {
    this.storage.get(componentType)?.delete(entity);
  }
}
