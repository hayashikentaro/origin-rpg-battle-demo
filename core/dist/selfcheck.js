"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const battle_1 = require("./battle");
function assert(condition, message) {
    if (!condition) {
        throw new Error(message);
    }
}
function runResolveActorCommandChecks() {
    const attack = (0, battle_1.resolveActorCommand)({
        actorIndex: 0,
        action: {
            kindId: 0x10,
            arg: 0,
            target: 0xff,
            slotIndex: 0
        },
        outcomeLikeByte: 0
    });
    assert(attack.branch === 0, `attack branch mismatch: ${attack.branch}`);
    assert(attack.localPath === 0, `attack localPath mismatch: ${attack.localPath}`);
    assert(attack.didConsumeCandidateRng === false, "attack should not consume candidate RNG for localPath 0");
    assert(attack.targetSource === "slotIndex", `attack targetSource mismatch: ${attack.targetSource}`);
    assert(Array.isArray(attack.debugTrace) && attack.debugTrace.length === 5, "attack debugTrace shape mismatch");
    const defend = (0, battle_1.resolveActorCommand)({
        actorIndex: 1,
        action: {
            kindId: 0x04,
            arg: 0,
            target: 0x00,
            slotIndex: 0
        },
        outcomeLikeByte: 0
    });
    assert(defend.branch === 16, `defend branch mismatch: ${defend.branch}`);
    assert(defend.localPath === 64, `defend localPath mismatch: ${defend.localPath}`);
    assert(defend.target === 0, `defend target mismatch: ${defend.target}`);
    assert(defend.targetSource === "explicit", `defend targetSource mismatch: ${defend.targetSource}`);
    const pointerProbe = (0, battle_1.resolveActorCommand)({
        actorIndex: 0,
        action: {
            kindId: 0x01,
            arg: 0,
            target: 0xff,
            slotIndex: 0
        },
        outcomeLikeByte: 0
    });
    assert(pointerProbe.localPath === 16, `pointerProbe localPath mismatch: ${pointerProbe.localPath}`);
    assert(pointerProbe.didConsumeCandidateRng === true, "pointerProbe should consume candidate RNG");
    assert(pointerProbe.targetSource === "candidate", `pointerProbe targetSource mismatch: ${pointerProbe.targetSource}`);
    assert(typeof pointerProbe.candidateOffset === "number", "pointerProbe candidateOffset missing");
    assert(pointerProbe.debugTrace[2]?.startsWith("candidate rng 07/08"), "pointerProbe debugTrace candidate step missing");
    const ability = (0, battle_1.resolveActorCommand)({
        actorIndex: 2,
        action: {
            kindId: 0x20,
            arg: 1,
            target: 0xff,
            slotIndex: 1
        },
        outcomeLikeByte: 0
    });
    assert(ability.branch === 32, `ability branch mismatch: ${ability.branch}`);
    assert(ability.localPath === 1, `ability localPath mismatch: ${ability.localPath}`);
    assert(ability.target === 1, `ability target mismatch: ${ability.target}`);
    assert(ability.targetSource === "slotIndex", `ability targetSource mismatch: ${ability.targetSource}`);
    assert(ability.action.arg === 1 && ability.action.slotIndex === 1, "ability action echo mismatch");
    const matrix = (0, battle_1.resolveActorCommandMatrix)([
        {
            actorIndex: 0,
            action: { kindId: 0x10, arg: 0, target: 0xff, slotIndex: 0 },
            outcomeLikeByte: 0
        },
        {
            actorIndex: 0,
            action: { kindId: 0x01, arg: 0, target: 0xff, slotIndex: 0 },
            outcomeLikeByte: 0
        }
    ]);
    assert(matrix.length === 2, `matrix length mismatch: ${matrix.length}`);
    assert(matrix[0]?.targetSource === "slotIndex", `matrix[0] targetSource mismatch: ${matrix[0]?.targetSource}`);
    assert(matrix[1]?.targetSource === "candidate", `matrix[1] targetSource mismatch: ${matrix[1]?.targetSource}`);
}
runResolveActorCommandChecks();
console.log("selfcheck ok");
