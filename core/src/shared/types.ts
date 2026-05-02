export type BattleMode = "command" | "victory_meat" | "victory_done" | "defeat" | "finished";
export type Race = "Human" | "Esper" | "Monster" | "Robot" | "Enemy";
export type ActionType = "attack" | "ability" | "defend";

export interface StatBlock {
  maxHp: number;
  str: number;
  def: number;
  agi: number;
  magic: number;
}

export interface StatBonuses {
  maxHp: number;
  str: number;
  def: number;
  agi: number;
  magic: number;
}

export interface Ability {
  id: string;
  name: string;
  power: number;
  kind: string;
  targetSide: "ally" | "enemy";
}

export interface Item {
  id: string;
  name: string;
  statBonuses: Partial<StatBonuses>;
}

export interface UsageStats {
  attack: number;
  defend: number;
  ability: number;
}

export interface CharacterState {
  id: string;
  name: string;
  race: Race;
  form: string;
  hp: number;
  maxHp: number;
  str: number;
  def: number;
  agi: number;
  magic: number;
  abilities: Ability[];
  equipment: Item[];
  baseStats: StatBlock;
  equipmentStats: StatBonuses;
  isAlive: boolean;
  usageStats: UsageStats;
}

export interface QueuedAction {
  actorId: string;
  type: ActionType;
  side: "ally" | "enemy";
  abilityId?: string;
}

export interface MeatDrop {
  name: string;
  type: string;
}

export interface BattleState {
  seed: number;
  allies: CharacterState[];
  enemies: CharacterState[];
  battleLog: string[];
  queuedActions: QueuedAction[];
  state: BattleMode;
  turnNumber: number;
  currentActorIndex: number;
  meatDrops: MeatDrop[];
  victoryGrowthLogs: string[];
  pendingMonsterId: string | null;
  pendingMeatIndex: number;
}

export interface CoreRequest {
  operation: "init" | "queue_action" | "resolve_next" | "consume_meat";
  state?: BattleState;
  actionType?: ActionType;
  abilityIndex?: number;
  seed?: number;
}

export interface CoreResponse {
  ok: boolean;
  state?: BattleState;
  error?: string;
}
