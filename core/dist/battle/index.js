"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.consumeMeat = exports.resolveNext = exports.queueAction = exports.createInitialState = exports.resolveActorCommandMatrix = exports.resolveActorCommand = void 0;
const growth_1 = require("../growth");
const rng_1 = require("../rng");
const transform_1 = require("../transform");
const demoData_1 = require("../shared/demoData");
function cloneCharacter(character) {
    return JSON.parse(JSON.stringify(character));
}
function applyRobotEquipment(character) {
    if (character.race !== "Robot") {
        return;
    }
    const bonuses = { maxHp: 0, str: 0, def: 0, agi: 0, magic: 0 };
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
function livingCharacters(characters) {
    return characters.filter((character) => character.isAlive);
}
function currentActor(state) {
    const living = livingCharacters(state.allies);
    if (state.state !== "command" || state.currentActorIndex >= living.length) {
        return null;
    }
    return living[state.currentActorIndex];
}
function findCharacter(characters, id) {
    return characters.find((character) => character.id === id);
}
function randomTarget(state, characters) {
    const living = livingCharacters(characters);
    if (living.length === 0) {
        return null;
    }
    return living[(0, rng_1.nextInt)(state, 0, living.length - 1)];
}
function lowestHpTarget(characters) {
    const living = livingCharacters(characters);
    if (living.length === 0) {
        return null;
    }
    return living.reduce((lowest, current) => (current.hp < lowest.hp ? current : lowest));
}
function physicalDamage(state, attacker, defender) {
    const variance = (0, rng_1.nextInt)(state, -2, 3);
    return Math.max(1, attacker.str - Math.floor(defender.def / 2) + variance);
}
function magicDamage(state, attacker, defender, power) {
    const variance = (0, rng_1.nextInt)(state, -1, 2);
    return Math.max(1, attacker.magic + power - Math.floor(defender.def / 3) + variance);
}
function healAmount(state, caster, power) {
    return Math.max(2, caster.magic + power + (0, rng_1.nextInt)(state, 0, 3));
}
function applyDamage(target, amount) {
    target.hp = Math.max(0, target.hp - amount);
    target.isAlive = target.hp > 0;
    return amount;
}
function applyHealing(target, amount) {
    target.hp = Math.min(target.maxHp, target.hp + amount);
    target.isAlive = target.hp > 0;
    return amount;
}
function decodeResolvedOutcome(playerIndex, outcomeLikeByte = 0) {
    return ((playerIndex & 0x03) << 4) | (outcomeLikeByte & 0x0f);
}
function selectLocalActionPath(kindId, arg) {
    return ((kindId & 0x0f) << 4) | (arg & 0x0f);
}
function pathNeedsCandidateSelection(localPath) {
    return (localPath & 0x10) !== 0;
}
function buildPointerCandidateWithRng07_08(state, localPath) {
    const upperHi = (localPath >> 1) & 0x0f;
    const upperLo = ((localPath << 1) | 0x03) & 0x0f;
    const hi = (0, rng_1.nextInt)(state, 0, upperHi);
    const lo = (0, rng_1.nextInt)(state, 0, upperLo);
    return {
        slotHi: 0x07,
        slotLo: 0x08,
        offset: ((hi & 0xff) << 8) | (lo & 0xff)
    };
}
function routeTarget(target, slotIndex, candidate) {
    if (target !== 0xff) {
        return {
            target,
            source: "explicit"
        };
    }
    if (candidate) {
        return {
            target: candidate.offset & 0x03,
            source: "candidate"
        };
    }
    return {
        target: slotIndex & 0x03,
        source: "slotIndex"
    };
}
function reopenTargetSource(target, candidate) {
    if (target !== 0xff) {
        return "explicit";
    }
    if (candidate) {
        return "candidate";
    }
    return "slotIndex";
}
function bucketCandidateOffset(candidateOffset) {
    return (((candidateOffset >> 8) ^ candidateOffset) & 0x01);
}
function describeBranchMode(localPath) {
    return pathNeedsCandidateSelection(localPath)
        ? "candidate_aware_local_resolution_mode"
        : "shared_default_local_resolution_mode";
}
function describeBranchVariantMeaning(branchVariant) {
    if (branchVariant === undefined) {
        return undefined;
    }
    return "candidate_family_lane_refinement_bit";
}
function resolveCombatRngAfterLocalPath(localPath, candidateOffset) {
    const candidatePath = pathNeedsCandidateSelection(localPath);
    const branchVariant = candidatePath && typeof candidateOffset === "number" ? bucketCandidateOffset(candidateOffset) : undefined;
    return {
        accepted: false,
        branch: 0,
        branchVariant,
        branchModeMeaning: describeBranchMode(localPath),
        branchVariantMeaning: describeBranchVariantMeaning(branchVariant),
        branchVariantBindingStatus: branchVariant === undefined ? undefined : "deferred_numeric_binding",
        branchVariantCarryMeaning: branchVariant === undefined ? undefined : "same_side_pointer_correspondence",
        debugSource: "unresolved_local_policy",
        pendingWindow: "41E7-41E9 -> 41EB-41EC",
        pendingMeaning: candidatePath
            ? "special_candidate_candidate_accept_policy"
            : "special_candidate_local_accept_policy"
    };
}
function routeAfterDecision(branch, branchVariant) {
    if (branchVariant === undefined) {
        return branch;
    }
    return (branch << 1) | branchVariant;
}
function reopenPointerFlavor(targetSource) {
    return targetSource === "candidate" ? "candidate" : "shared";
}
function describePointerFlavorMeaning(pointerFlavor) {
    return pointerFlavor === "candidate"
        ? "candidate_entry_target_provenance_path"
        : "shared_default_target_provenance_path";
}
function resolveAction(state, action) {
    const actor = action.side === "ally" ? findCharacter(state.allies, action.actorId) : findCharacter(state.enemies, action.actorId);
    if (!actor || !actor.isAlive) {
        return [];
    }
    const allies = action.side === "ally" ? state.allies : state.enemies;
    const enemies = action.side === "ally" ? state.enemies : state.allies;
    const logs = [];
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
function resolveAbility(state, actor, ability, allies, enemies) {
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
function resolveActorCommand(input) {
    const state = createInitialState(1);
    const branch = decodeResolvedOutcome(input.actorIndex, input.outcomeLikeByte ?? 0);
    const localPath = selectLocalActionPath(input.action.kindId, input.action.arg);
    const candidate = pathNeedsCandidateSelection(localPath) ? buildPointerCandidateWithRng07_08(state, localPath) : null;
    const combatDecision = resolveCombatRngAfterLocalPath(localPath, candidate?.offset);
    const postBranchRoute = routeAfterDecision(combatDecision?.branch ?? branch, combatDecision?.branchVariant);
    const postBranchTargetSource = reopenTargetSource(input.action.target, candidate);
    const pointerFlavor = reopenPointerFlavor(postBranchTargetSource);
    const pointerFlavorMeaning = describePointerFlavorMeaning(pointerFlavor);
    const routedTarget = routeTarget(input.action.target, input.action.slotIndex, candidate);
    const debugTrace = [
        `decode branch actor=${input.actorIndex} outcome=${input.outcomeLikeByte ?? 0} => ${branch}`,
        `select path kind=${input.action.kindId} arg=${input.action.arg} => ${localPath}`,
        candidate
            ? `candidate rng 07/08 => offset=${candidate.offset}`
            : "candidate rng skipped",
        combatDecision
            ? `combat hook accepted=${combatDecision.accepted} branch=${combatDecision.branch}/${combatDecision.branchModeMeaning ?? "--"} variant=${combatDecision.branchVariant ?? "--"}/${combatDecision.branchVariantMeaning ?? "--"} binding=${combatDecision.branchVariantBindingStatus ?? "--"} carry=${combatDecision.branchVariantCarryMeaning ?? "--"} route=${postBranchRoute} source=${combatDecision.debugSource ?? "--"} meaning=${combatDecision.pendingMeaning ?? "--"}`
            : `combat hook skipped route=${postBranchRoute}`,
        `post-branch marker=${postBranchTargetSource} pointer=${pointerFlavor}/${pointerFlavorMeaning}`,
        `target terminal source=${routedTarget.source} => ${routedTarget.target}`
    ];
    return {
        actorIndex: input.actorIndex,
        branch,
        postBranchRoute,
        localPath,
        postBranchTargetSource,
        pointerFlavor,
        pointerFlavorMeaning,
        target: routedTarget.target,
        targetSource: routedTarget.source,
        didConsumeCandidateRng: candidate !== null,
        candidateOffset: candidate?.offset,
        action: { ...input.action },
        combatDecision,
        debugTrace
    };
}
exports.resolveActorCommand = resolveActorCommand;
function resolveActorCommandMatrix(inputs) {
    return inputs.map((input) => resolveActorCommand(input));
}
exports.resolveActorCommandMatrix = resolveActorCommandMatrix;
function allDead(characters) {
    return characters.every((character) => !character.isAlive);
}
function queueEnemyActions(state) {
    for (const enemy of state.enemies) {
        if (!enemy.isAlive) {
            continue;
        }
        if (enemy.abilities.length > 0 && (0, rng_1.nextFloat)(state) < 0.4) {
            state.queuedActions.push({
                actorId: enemy.id,
                type: "ability",
                side: "enemy",
                abilityId: enemy.abilities[0].id
            });
        }
        else {
            state.queuedActions.push({
                actorId: enemy.id,
                type: "attack",
                side: "enemy"
            });
        }
    }
}
function findMonster(state) {
    return state.allies.find((ally) => ally.race === "Monster") ?? null;
}
function prepareNextMeatChoice(state) {
    const monster = state.pendingMonsterId ? findCharacter(state.allies, state.pendingMonsterId) : null;
    if (!monster || !monster.isAlive) {
        state.state = "victory_done";
        state.battleLog.push("肉を食べられるモンスターがいない。");
        return;
    }
    while (state.pendingMeatIndex < state.meatDrops.length) {
        const meat = state.meatDrops[state.pendingMeatIndex];
        if ((0, transform_1.canTransform)(monster, meat.type)) {
            state.state = "victory_meat";
            state.battleLog.push(`${monster.name}は${meat.name}を食べられる。`);
            return;
        }
        state.pendingMeatIndex += 1;
    }
    state.state = "victory_done";
    state.battleLog.push("これ以上変身できる肉はない。");
}
function handleVictory(state) {
    state.state = "victory_meat";
    state.queuedActions = [];
    state.victoryGrowthLogs = (0, growth_1.applyVictoryGrowth)(state);
    state.battleLog.push("敵をすべて倒した。");
    state.battleLog.push(...state.victoryGrowthLogs);
    state.meatDrops = state.enemies
        .map((enemy) => (0, demoData_1.getEnemyMeatDrop)(enemy.id))
        .filter((drop) => drop !== null);
    const monster = findMonster(state);
    state.pendingMonsterId = monster?.id ?? null;
    state.pendingMeatIndex = 0;
    prepareNextMeatChoice(state);
}
function resolveTurn(state) {
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
function skipMeatChoice(state) {
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
function createInitialState(seed = Date.now()) {
    const allies = (0, demoData_1.createAllies)().map(cloneCharacter);
    for (const ally of allies) {
        applyRobotEquipment(ally);
    }
    return {
        seed: (0, rng_1.normalizeSeed)(seed),
        allies,
        enemies: (0, demoData_1.createEnemies)().map(cloneCharacter),
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
exports.createInitialState = createInitialState;
function queueAction(state, actionType, abilityIndex) {
    const actor = currentActor(state);
    if (!actor) {
        return state;
    }
    actor.usageStats[actionType] += 1;
    const action = { actorId: actor.id, type: actionType, side: "ally" };
    if (actionType === "ability") {
        const ability = abilityIndex !== undefined ? actor.abilities[abilityIndex] : undefined;
        if (!ability) {
            return state;
        }
        action.abilityId = ability.id;
        state.battleLog.push(`${actor.name}は${ability.name}を選んだ。`);
    }
    else {
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
exports.queueAction = queueAction;
function resolveNext(state) {
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
exports.resolveNext = resolveNext;
function consumeMeat(state) {
    if (state.state !== "victory_meat" || state.pendingMeatIndex < 0 || state.pendingMeatIndex >= state.meatDrops.length) {
        return state;
    }
    const monster = state.pendingMonsterId ? findCharacter(state.allies, state.pendingMonsterId) : null;
    if (!monster) {
        return state;
    }
    const meat = state.meatDrops[state.pendingMeatIndex];
    state.battleLog.push(`${monster.name} eats ${meat.name}.`);
    const result = (0, transform_1.transformMonster)(monster, meat.type);
    if (!result) {
        state.battleLog.push("何も起こらなかった。");
    }
    else {
        state.battleLog.push(`${monster.name}は${result.form}に変身した。`);
    }
    state.pendingMeatIndex += 1;
    prepareNextMeatChoice(state);
    return state;
}
exports.consumeMeat = consumeMeat;
