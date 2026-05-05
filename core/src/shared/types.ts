export type BattleMode = "command" | "victory_meat" | "victory_done" | "defeat" | "finished";
export type Race = "Human" | "Esper" | "Monster" | "Robot" | "Enemy";
export type ActionType = "attack" | "ability" | "defend";

export interface BattleActionHead {
  kindId: number;
  arg: number;
  target: number;
  slotIndex: number;
}

export interface BattleCommandInput {
  actorIndex: number;
  action: BattleActionHead;
  outcomeLikeByte?: number;
}

export interface CombatDecision {
  accepted: boolean;
  branch: number;
  branchVariant?: 0 | 1;
  branchModeMeaning?: "shared_default_local_resolution_mode" | "candidate_aware_local_resolution_mode";
  branchVariantMeaning?: "shared_default_leaning" | "candidate_aware_strict_leaning";
  branchVariantCarryMeaning?: "same_side_pointer_correspondence";
  debugSource?: "unresolved_local_policy";
  pendingWindow?: "41E7-41E9 -> 41EB-41EC";
  pendingMeaning?: "special_candidate_local_accept_policy" | "special_candidate_candidate_accept_policy";
}

export interface ActorResolveResult {
  actorIndex: number;
  branch: number;
  postBranchRoute: number;
  localPath: number;
  postBranchTargetSource: "explicit" | "candidate" | "slotIndex";
  pointerFlavor: "candidate" | "shared";
  pointerFlavorMeaning?: "shared_default_target_provenance_path" | "candidate_entry_target_provenance_path";
  target: number;
  targetSource: "explicit" | "candidate" | "slotIndex";
  didConsumeCandidateRng: boolean;
  candidateOffset?: number;
  action: BattleActionHead;
  combatDecision?: CombatDecision;
  debugTrace: string[];
}

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
  operation: "init" | "queue_action" | "resolve_next" | "consume_meat" | "resolve_actor_command" | "resolve_actor_command_matrix";
  state?: BattleState;
  actionType?: ActionType;
  abilityIndex?: number;
  seed?: number;
  commandInput?: BattleCommandInput;
  commandInputs?: BattleCommandInput[];
}

export interface CoreResponse {
  ok: boolean;
  state?: BattleState;
  actorResolveResult?: ActorResolveResult;
  actorResolveResults?: ActorResolveResult[];
  error?: string;
}
