import { CharacterState } from "../shared/types";
import { getMonsterTransformation } from "../shared/demoData";

export function canTransform(character: CharacterState | undefined, meatType: string): boolean {
  if (!character || character.race !== "Monster") {
    return false;
  }
  return !!getMonsterTransformation(character.form, meatType);
}

export function transformMonster(character: CharacterState, meatType: string) {
  const result = getMonsterTransformation(character.form, meatType);
  if (!result) {
    return null;
  }
  character.form = result.form;
  character.name = result.displayName;
  character.baseStats = { ...result.stats };
  character.maxHp = result.stats.maxHp;
  character.hp = result.stats.maxHp;
  character.str = result.stats.str;
  character.def = result.stats.def;
  character.agi = result.stats.agi;
  character.magic = result.stats.magic;
  character.abilities = result.abilities.map((ability) => ({ ...ability }));
  character.isAlive = true;
  return result;
}
