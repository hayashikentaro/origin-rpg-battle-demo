import { getEsperLearnPool } from "../shared/demoData";
import { nextFloat, nextInt } from "../rng";
import { BattleState, CharacterState } from "../shared/types";

function rollGrowth(state: BattleState, baseChance: number, relatedActions: number, perActionBonus: number): boolean {
  return nextFloat(state) < baseChance + relatedActions * perActionBonus;
}

function resetUsageStats(character: CharacterState) {
  character.usageStats = { attack: 0, defend: 0, ability: 0 };
}

function growHuman(state: BattleState, character: CharacterState): string[] {
  const gains: string[] = [];
  if (rollGrowth(state, 0.45, character.usageStats.attack, 0.08)) {
    character.maxHp += 2;
    character.hp += 2;
    gains.push("Max HP +2");
  }
  if (rollGrowth(state, 0.35, character.usageStats.attack, 0.12)) {
    character.str += 1;
    gains.push("STR +1");
  }
  if (rollGrowth(state, 0.30, character.usageStats.defend, 0.12)) {
    character.def += 1;
    gains.push("DEF +1");
  }
  if (rollGrowth(state, 0.25, character.usageStats.attack, 0.05)) {
    character.agi += 1;
    gains.push("AGI +1");
  }
  character.baseStats = {
    maxHp: character.maxHp,
    str: character.str,
    def: character.def,
    agi: character.agi,
    magic: character.magic
  };
  resetUsageStats(character);
  if (gains.length === 0) {
    return [`${character.name}は経験を積んだが、能力値は上がらなかった。`];
  }
  return [`${character.name}は成長した: ${gains.join("、")}。`];
}

function growEsper(state: BattleState, character: CharacterState): string[] {
  if (nextFloat(state) > 0.65) {
    resetUsageStats(character);
    return [`${character.name}は戦いを振り返ったが、新しい能力は覚えなかった。`];
  }

  const learnable = getEsperLearnPool();
  const ability = { ...learnable[nextInt(state, 0, learnable.length - 1)] };
  if (character.abilities.some((entry) => entry.id === ability.id)) {
    resetUsageStats(character);
    return [`${character.name}は力を研ぎ澄ませたが、${ability.name}はすでに習得済みだった。`];
  }

  const logs: string[] = [];
  if (character.abilities.length >= 4) {
    const removed = character.abilities.shift();
    if (removed) {
      logs.push(`${character.name}は${removed.name}を忘れた。`);
    }
  }

  character.abilities.push(ability);
  resetUsageStats(character);
  logs.push(`${character.name}は${ability.name}を覚えた。`);
  return logs;
}

export function applyVictoryGrowth(state: BattleState): string[] {
  const logs: string[] = [];
  for (const character of state.allies) {
    if (!character.isAlive) {
      continue;
    }
    switch (character.race) {
      case "Human":
        logs.push(...growHuman(state, character));
        break;
      case "Esper":
        logs.push(...growEsper(state, character));
        break;
      default:
        resetUsageStats(character);
        break;
    }
  }
  return logs;
}
