"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getMonsterTransformation = exports.getEsperLearnPool = exports.getEnemyMeatDrop = exports.createEnemies = exports.createAllies = exports.monsterTransforms = exports.monsterForms = void 0;
const abilities = {
    fire: { id: "fire", name: "Fire", power: 6, kind: "magic_attack", targetSide: "enemy" },
    heal: { id: "heal", name: "Heal", power: 5, kind: "heal", targetSide: "ally" },
    spark: { id: "spark", name: "Spark", power: 8, kind: "magic_attack", targetSide: "enemy" },
    howl: { id: "howl", name: "Howl", power: 7, kind: "magic_attack", targetSide: "enemy" },
    chill: { id: "chill", name: "Chill", power: 8, kind: "magic_attack", targetSide: "enemy" },
    flareBreath: { id: "flare_breath", name: "Flare Breath", power: 10, kind: "magic_attack", targetSide: "enemy" }
};
const equipment = {
    servoArm: { id: "servo_arm", name: "Servo Arm", statBonuses: { str: 3, def: 1 } },
    gyroShell: { id: "gyro_shell", name: "Gyro Shell", statBonuses: { maxHp: 6, def: 2, agi: 1 } }
};
exports.monsterForms = {
    Slime: {
        displayName: "Noro",
        stats: { maxHp: 26, str: 7, def: 5, agi: 6, magic: 2 },
        abilities: []
    },
    Wolf: {
        displayName: "Noro",
        stats: { maxHp: 31, str: 10, def: 6, agi: 10, magic: 2 },
        abilities: [abilities.howl]
    },
    Ghost: {
        displayName: "Noro",
        stats: { maxHp: 28, str: 8, def: 5, agi: 9, magic: 8 },
        abilities: [abilities.chill]
    },
    Chimera: {
        displayName: "Noro",
        stats: { maxHp: 38, str: 12, def: 8, agi: 11, magic: 6 },
        abilities: [abilities.flareBreath]
    }
};
exports.monsterTransforms = {
    Slime: { beast: "Wolf" },
    Wolf: { undead: "Ghost" },
    Ghost: { beast: "Chimera" }
};
function makeCharacter(data) {
    const stats = data.baseStats ?? {
        maxHp: data.maxHp ?? 1,
        str: data.str ?? 1,
        def: data.def ?? 1,
        agi: data.agi ?? 1,
        magic: data.magic ?? 0
    };
    return {
        id: data.id,
        name: data.name,
        race: data.race,
        form: data.form ?? "",
        hp: data.hp ?? stats.maxHp,
        maxHp: data.maxHp ?? stats.maxHp,
        str: data.str ?? stats.str,
        def: data.def ?? stats.def,
        agi: data.agi ?? stats.agi,
        magic: data.magic ?? stats.magic,
        abilities: [...(data.abilities ?? [])],
        equipment: [...(data.equipment ?? [])],
        baseStats: { ...stats },
        equipmentStats: {
            maxHp: data.equipmentStats?.maxHp ?? 0,
            str: data.equipmentStats?.str ?? 0,
            def: data.equipmentStats?.def ?? 0,
            agi: data.equipmentStats?.agi ?? 0,
            magic: data.equipmentStats?.magic ?? 0
        },
        isAlive: data.isAlive ?? true,
        usageStats: {
            attack: data.usageStats?.attack ?? 0,
            defend: data.usageStats?.defend ?? 0,
            ability: data.usageStats?.ability ?? 0
        }
    };
}
function createAllies() {
    return [
        makeCharacter({
            id: "aki",
            name: "Aki",
            race: "Human",
            maxHp: 36,
            hp: 36,
            str: 11,
            def: 8,
            agi: 9,
            magic: 1
        }),
        makeCharacter({
            id: "mira",
            name: "Mira",
            race: "Esper",
            maxHp: 28,
            hp: 28,
            str: 6,
            def: 6,
            agi: 8,
            magic: 10,
            abilities: [abilities.fire, abilities.heal]
        }),
        makeCharacter({
            id: "noro",
            name: "Noro",
            race: "Monster",
            form: "Slime",
            maxHp: 26,
            hp: 26,
            str: 7,
            def: 5,
            agi: 6,
            magic: 2,
            baseStats: { ...exports.monsterForms.Slime.stats }
        }),
        makeCharacter({
            id: "unit7",
            name: "Unit-7",
            race: "Robot",
            maxHp: 24,
            hp: 24,
            str: 5,
            def: 4,
            agi: 5,
            magic: 0,
            equipment: [equipment.servoArm, equipment.gyroShell],
            baseStats: { maxHp: 24, str: 5, def: 4, agi: 5, magic: 0 }
        })
    ];
}
exports.createAllies = createAllies;
function createEnemies() {
    return [
        makeCharacter({
            id: "goblin",
            name: "Goblin",
            race: "Enemy",
            maxHp: 20,
            hp: 20,
            str: 8,
            def: 4,
            agi: 7,
            magic: 0
        }),
        makeCharacter({
            id: "beast",
            name: "Beast",
            race: "Enemy",
            maxHp: 24,
            hp: 24,
            str: 10,
            def: 5,
            agi: 6,
            magic: 0
        }),
        makeCharacter({
            id: "wisp",
            name: "Wisp",
            race: "Enemy",
            maxHp: 18,
            hp: 18,
            str: 5,
            def: 3,
            agi: 10,
            magic: 9,
            abilities: [abilities.fire]
        })
    ];
}
exports.createEnemies = createEnemies;
function getEnemyMeatDrop(enemyId) {
    switch (enemyId) {
        case "goblin":
            return { name: "Goblin Cut", type: "beast" };
        case "beast":
            return { name: "Beast Meat", type: "beast" };
        case "wisp":
            return { name: "Wisp Essence", type: "undead" };
        default:
            return null;
    }
}
exports.getEnemyMeatDrop = getEnemyMeatDrop;
function getEsperLearnPool() {
    return [abilities.spark, abilities.fire, abilities.heal];
}
exports.getEsperLearnPool = getEsperLearnPool;
function getMonsterTransformation(currentForm, meatType) {
    const nextForm = exports.monsterTransforms[currentForm]?.[meatType];
    if (!nextForm) {
        return null;
    }
    const definition = exports.monsterForms[nextForm];
    return {
        form: nextForm,
        displayName: definition.displayName,
        stats: { ...definition.stats },
        abilities: definition.abilities.map((ability) => ({ ...ability }))
    };
}
exports.getMonsterTransformation = getMonsterTransformation;
