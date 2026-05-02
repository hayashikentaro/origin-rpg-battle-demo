"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.transformMonster = exports.canTransform = void 0;
const demoData_1 = require("../shared/demoData");
function canTransform(character, meatType) {
    if (!character || character.race !== "Monster") {
        return false;
    }
    return !!(0, demoData_1.getMonsterTransformation)(character.form, meatType);
}
exports.canTransform = canTransform;
function transformMonster(character, meatType) {
    const result = (0, demoData_1.getMonsterTransformation)(character.form, meatType);
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
exports.transformMonster = transformMonster;
