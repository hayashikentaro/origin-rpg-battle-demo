import { applyVictoryGrowth } from "../growth";
import { nextFloat, nextInt, normalizeSeed } from "../rng";
import { canTransform, transformMonster } from "../transform";
import { createAllies, createEnemies, getEnemyMeatDrop } from "../shared/demoData";
import { Ability, BattleState, CharacterState, QueuedAction, StatBonuses } from "../shared/types";

function cloneCharacter(character: CharacterState): CharacterState {
  return JSON.parse(JSON.stringify(character));
}

function applyRobotEquipment(character: CharacterState) {
  if (character.race !== "Robot") {
    return;
  }
  const bonuses: StatBonuses = { maxHp: 0, str: 0, def: 0, agi: 0, magic: 0 };
  for (const item of character.equipment) {
    bonuses.maxHp += item.statBonuses.maxHp ?? 0;
    bonuses.str += item.statBonuses.str ?? 0;
    bonuses.def += item.statBonuses.def ?? 0;
    bonuses.agi += item.statBonuses.agi ?? 0;
    bonuses.magic += item.statBonuses.magic ?? 0;
  }
  const hpRatio = character.maxHp > 0 ? character.hp / character.maxHp : 1;
  character.equipmentStats = bonuses;
  character.maxHp = character.baseStats.maxHp + bonuses.maxHp;
  character.str = character.baseStats.str + bonuses.str;
  character.def = character.baseStats.def + bonuses.def;
  character.agi = character.baseStats.agi + bonuses.agi;
  character.magic = character.baseStats.magic + bonuses.magic;
  character.hp = Math.max(1, Math.min(character.maxHp, Math.round(character.maxHp * hpRatio)));
}

function livingCharacters(characters: CharacterState[]): CharacterState[] {
  return characters.filter((character) => character.isAlive);
}

function currentActor(state: BattleState): CharacterState | null {
  const living = livingCharacters(state.allies);
  if (state.state !== "command" || state.currentActorIndex >= living.length) {
    return null;
  }
  return living[state.currentActorIndex];
}

function findCharacter(characters: CharacterState[], id: string): CharacterState | undefined {
  return characters.find((character) => character.id === id);
}

function randomTarget(state: BattleState, characters: CharacterState[]): CharacterState | null {
  const living = livingCharacters(characters);
  if (living.length === 0) {
    return null;
  }
  return living[nextInt(state, 0, living.length - 1)];
}

function lowestHpTarget(characters: CharacterState[]): CharacterState | null {
  const living = livingCharacters(characters);
  if (living.length === 0) {
    return null;
  }
  return living.reduce((lowest, current) => (current.hp < lowest.hp ? current : lowest));
}

function physicalDamage(state: BattleState, attacker: CharacterState, defender: CharacterState): number {
  const variance = nextInt(state, -2, 3);
  return Math.max(1, attacker.str - Math.floor(defender.def / 2) + variance);
}

function magicDamage(state: BattleState, attacker: CharacterState, defender: CharacterState, power: number): number {
  const variance = nextInt(state, -1, 2);
  return Math.max(1, attacker.magic + power - Math.floor(defender.def / 3) + variance);
}

function healAmount(state: BattleState, caster: CharacterState, power: number): number {
  return Math.max(2, caster.magic + power + nextInt(state, 0, 3));
}

function applyDamage(target: CharacterState, amount: number): number {
  target.hp = Math.max(0, target.hp - amount);
  target.isAlive = target.hp > 0;
  return amount;
}

function applyHealing(target: CharacterState, amount: number): number {
  target.hp = Math.min(target.maxHp, target.hp + amount);
  target.isAlive = target.hp > 0;
  return amount;
}

function resolveAction(state: BattleState, action: QueuedAction): string[] {
  const actor = action.side === "ally" ? findCharacter(state.allies, action.actorId) : findCharacter(state.enemies, action.actorId);
  if (!actor || !actor.isAlive) {
    return [];
  }

  const allies = action.side === "ally" ? state.allies : state.enemies;
  const enemies = action.side === "ally" ? state.enemies : state.allies;
  const logs: string[] = [];

  switch (action.type) {
    case "attack": {
      const target = randomTarget(state, enemies);
      if (!target) {
        return logs;
      }
      const damage = physicalDamage(state, actor, target);
      applyDamage(target, damage);
      logs.push(`${actor.name}の攻撃。${target.name}に${damage}ダメージ。`);
      if (!target.isAlive) {
        logs.push(`${target.name}は倒れた。`);
      }
      return logs;
    }
    case "ability": {
      const ability = actor.abilities.find((entry) => entry.id === action.abilityId);
      if (!ability) {
        return logs;
      }
      return resolveAbility(state, actor, ability, allies, enemies);
    }
    case "defend":
      logs.push(`${actor.name}は防御態勢を取った。`);
      return logs;
    default:
      return logs;
  }
}

function resolveAbility(
  state: BattleState,
  actor: CharacterState,
  ability: Ability,
  allies: CharacterState[],
  enemies: CharacterState[]
): string[] {
  if (ability.kind === "heal") {
    const target = lowestHpTarget(allies);
    if (!target) {
      return [];
    }
    const healed = healAmount(state, actor, ability.power);
    applyHealing(target, healed);
    return [`${actor.name}は${ability.name}で${target.name}のHPを${healed}回復した。`];
  }

  const target = randomTarget(state, enemies);
  if (!target) {
    return [];
  }
  const damage = magicDamage(state, actor, target, ability.power);
  applyDamage(target, damage);
  const logs = [`${actor.name}は${ability.name}。${target.name}に${damage}ダメージ。`];
  if (!target.isAlive) {
    logs.push(`${target.name}は倒れた。`);
  }
  return logs;
}

function allDead(characters: CharacterState[]): boolean {
  return characters.every((character) => !character.isAlive);
}

function queueEnemyActions(state: BattleState) {
  for (const enemy of state.enemies) {
    if (!enemy.isAlive) {
      continue;
    }
    if (enemy.abilities.length > 0 && nextFloat(state) < 0.4) {
      state.queuedActions.push({
        actorId: enemy.id,
        type: "ability",
        side: "enemy",
        abilityId: enemy.abilities[0].id
      });
    } else {
      state.queuedActions.push({
        actorId: enemy.id,
        type: "attack",
        side: "enemy"
      });
    }
  }
}

function findMonster(state: BattleState): CharacterState | null {
  return state.allies.find((ally) => ally.race === "Monster") ?? null;
}

function prepareNextMeatChoice(state: BattleState) {
  const monster = state.pendingMonsterId ? findCharacter(state.allies, state.pendingMonsterId) : null;
  if (!monster || !monster.isAlive) {
    state.state = "victory_done";
    state.battleLog.push("肉を食べられるモンスターがいない。");
    return;
  }

  while (state.pendingMeatIndex < state.meatDrops.length) {
    const meat = state.meatDrops[state.pendingMeatIndex];
    if (canTransform(monster, meat.type)) {
      state.state = "victory_meat";
      state.battleLog.push(`${monster.name}は${meat.name}を食べられる。`);
      return;
    }
    state.pendingMeatIndex += 1;
  }

  state.state = "victory_done";
  state.battleLog.push("これ以上変身できる肉はない。");
}

function handleVictory(state: BattleState) {
  state.state = "victory_meat";
  state.queuedActions = [];
  state.victoryGrowthLogs = applyVictoryGrowth(state);
  state.battleLog.push("敵をすべて倒した。");
  state.battleLog.push(...state.victoryGrowthLogs);
  state.meatDrops = state.enemies
    .map((enemy) => getEnemyMeatDrop(enemy.id))
    .filter((drop): drop is NonNullable<typeof drop> => drop !== null);
  const monster = findMonster(state);
  state.pendingMonsterId = monster?.id ?? null;
  state.pendingMeatIndex = 0;
  prepareNextMeatChoice(state);
}

function resolveTurn(state: BattleState) {
  queueEnemyActions(state);
  const sortedActions = [...state.queuedActions].sort((a, b) => {
    const actorA = a.side === "ally" ? findCharacter(state.allies, a.actorId) : findCharacter(state.enemies, a.actorId);
    const actorB = b.side === "ally" ? findCharacter(state.allies, b.actorId) : findCharacter(state.enemies, b.actorId);
    return (actorB?.agi ?? 0) - (actorA?.agi ?? 0);
  });

  for (const action of sortedActions) {
    const actor = action.side === "ally" ? findCharacter(state.allies, action.actorId) : findCharacter(state.enemies, action.actorId);
    if (action.type === "defend" && actor) {
      actor.def += 2;
    }
    state.battleLog.push(...resolveAction(state, action));
    if (action.type === "defend" && actor) {
      actor.def -= 2;
    }
    if (allDead(state.enemies)) {
      handleVictory(state);
      return;
    }
    if (allDead(state.allies)) {
      state.state = "defeat";
      state.battleLog.push("パーティは全滅した。");
      return;
    }
  }

  state.queuedActions = [];
  state.currentActorIndex = 0;
  state.turnNumber += 1;
  state.battleLog.push(`${state.turnNumber}ターン目開始。`);
}

function skipMeatChoice(state: BattleState) {
  if (state.state !== "victory_meat") {
    return;
  }
  const monster = state.pendingMonsterId ? findCharacter(state.allies, state.pendingMonsterId) : null;
  const meat = state.meatDrops[state.pendingMeatIndex];
  if (monster && meat) {
    state.battleLog.push(`${monster.name}は${meat.name}を見送った。`);
  }
  state.pendingMeatIndex += 1;
  prepareNextMeatChoice(state);
}

export function createInitialState(seed = Date.now()): BattleState {
  const allies = createAllies().map(cloneCharacter);
  for (const ally of allies) {
    applyRobotEquipment(ally);
  }
  return {
    seed: normalizeSeed(seed),
    allies,
    enemies: createEnemies().map(cloneCharacter),
    battleLog: ["バトルデモ開始。", "味方全員の行動を選んでからターンを進めてください。"],
    queuedActions: [],
    state: "command",
    turnNumber: 1,
    currentActorIndex: 0,
    meatDrops: [],
    victoryGrowthLogs: [],
    pendingMonsterId: null,
    pendingMeatIndex: -1
  };
}

export function queueAction(state: BattleState, actionType: "attack" | "ability" | "defend", abilityIndex?: number): BattleState {
  const actor = currentActor(state);
  if (!actor) {
    return state;
  }

  actor.usageStats[actionType] += 1;
  const action: QueuedAction = { actorId: actor.id, type: actionType, side: "ally" };
  if (actionType === "ability") {
    const ability = abilityIndex !== undefined ? actor.abilities[abilityIndex] : undefined;
    if (!ability) {
      return state;
    }
    action.abilityId = ability.id;
    state.battleLog.push(`${actor.name}は${ability.name}を選んだ。`);
  } else {
    var actionLabel = actionType === "attack" ? "たたかう" : "ぼうぎょ";
    state.battleLog.push(`${actor.name}は${actionLabel}を選んだ。`);
  }

  state.queuedActions.push(action);
  state.currentActorIndex += 1;
  if (state.currentActorIndex >= livingCharacters(state.allies).length) {
    state.battleLog.push("全員の行動が決まった。次へ進んでください。");
  }
  return state;
}

export function resolveNext(state: BattleState): BattleState {
  switch (state.state) {
    case "command":
      if (state.currentActorIndex >= livingCharacters(state.allies).length) {
        resolveTurn(state);
      }
      break;
    case "victory_meat":
      skipMeatChoice(state);
      break;
    case "victory_done":
    case "defeat":
    case "finished":
      return createInitialState(state.seed + 1);
  }
  return state;
}

export function consumeMeat(state: BattleState): BattleState {
  if (state.state !== "victory_meat" || state.pendingMeatIndex < 0 || state.pendingMeatIndex >= state.meatDrops.length) {
    return state;
  }
  const monster = state.pendingMonsterId ? findCharacter(state.allies, state.pendingMonsterId) : null;
  if (!monster) {
    return state;
  }
  const meat = state.meatDrops[state.pendingMeatIndex];
  state.battleLog.push(`${monster.name} eats ${meat.name}.`);
  const result = transformMonster(monster, meat.type);
  if (!result) {
    state.battleLog.push("何も起こらなかった。");
  } else {
    state.battleLog.push(`${monster.name}は${result.form}に変身した。`);
  }
  state.pendingMeatIndex += 1;
  prepareNextMeatChoice(state);
  return state;
}
