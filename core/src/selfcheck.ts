import { resolveActorCommand, resolveActorCommandMatrix } from "./battle";

function assert(condition: unknown, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function runResolveActorCommandChecks(): void {
  const attack = resolveActorCommand({
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
  assert(
    attack.combatDecision?.pendingMeaning === "special_candidate_local_accept_policy",
    `attack pendingMeaning mismatch: ${attack.combatDecision?.pendingMeaning}`
  );
  assert(attack.combatDecision?.accepted === false, "attack accepted mismatch");
  assert(attack.combatDecision?.branch === 0, `attack combat branch mismatch: ${attack.combatDecision?.branch}`);
  assert(
    attack.combatDecision?.branchModeMeaning === "shared_default_local_resolution_mode",
    `attack branchModeMeaning mismatch: ${attack.combatDecision?.branchModeMeaning}`
  );
  assert(attack.combatDecision?.branchVariant === undefined, "attack branchVariant should be undefined");
  assert(attack.postBranchRoute === 0, `attack postBranchRoute mismatch: ${attack.postBranchRoute}`);
  assert(attack.postBranchTargetSource === "slotIndex", `attack postBranchTargetSource mismatch: ${attack.postBranchTargetSource}`);
  assert(attack.pointerFlavor === "shared", `attack pointerFlavor mismatch: ${attack.pointerFlavor}`);
  assert(
    attack.pointerFlavorMeaning === "shared_default_target_provenance_path",
    `attack pointerFlavorMeaning mismatch: ${attack.pointerFlavorMeaning}`
  );
  assert(Array.isArray(attack.debugTrace) && attack.debugTrace.length === 6, "attack debugTrace shape mismatch");
  assert(attack.debugTrace[3]?.startsWith("combat hook "), "attack debugTrace combat-hook order mismatch");
  assert(attack.debugTrace[4]?.startsWith("post-branch marker="), "attack debugTrace marker order mismatch");
  assert(
    attack.debugTrace[4]?.includes("pointer=shared/shared_default_target_provenance_path"),
    `attack debugTrace pointer meaning mismatch: ${attack.debugTrace[4]}`
  );
  assert(attack.debugTrace[5]?.startsWith("target terminal "), "attack debugTrace target-terminal order mismatch");

  const defend = resolveActorCommand({
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

  const pointerProbe = resolveActorCommand({
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
  assert(
    pointerProbe.combatDecision?.pendingMeaning === "special_candidate_candidate_accept_policy",
    `pointerProbe pendingMeaning mismatch: ${pointerProbe.combatDecision?.pendingMeaning}`
  );
  assert(pointerProbe.combatDecision?.accepted === false, "pointerProbe accepted mismatch");
  assert(pointerProbe.combatDecision?.branch === 0, `pointerProbe combat branch mismatch: ${pointerProbe.combatDecision?.branch}`);
  assert(
    pointerProbe.combatDecision?.branchModeMeaning === "candidate_aware_local_resolution_mode",
    `pointerProbe branchModeMeaning mismatch: ${pointerProbe.combatDecision?.branchModeMeaning}`
  );
  const expectedPointerVariant = (((Number(pointerProbe.candidateOffset) >> 8) ^ Number(pointerProbe.candidateOffset)) & 0x01);
  assert(
    pointerProbe.combatDecision?.branchVariant === expectedPointerVariant,
    `pointerProbe branchVariant mismatch: ${pointerProbe.combatDecision?.branchVariant}`
  );
  assert(
    typeof pointerProbe.combatDecision?.branchVariantMeaning === "string",
    "pointerProbe branchVariantMeaning missing"
  );
  assert(
    pointerProbe.combatDecision?.branchVariantCarryMeaning === "same_side_pointer_correspondence",
    `pointerProbe branchVariantCarryMeaning mismatch: ${pointerProbe.combatDecision?.branchVariantCarryMeaning}`
  );
  assert(pointerProbe.postBranchRoute === expectedPointerVariant, `pointerProbe postBranchRoute mismatch: ${pointerProbe.postBranchRoute}`);
  assert(pointerProbe.postBranchTargetSource === "candidate", `pointerProbe postBranchTargetSource mismatch: ${pointerProbe.postBranchTargetSource}`);
  assert(pointerProbe.pointerFlavor === "candidate", `pointerProbe pointerFlavor mismatch: ${pointerProbe.pointerFlavor}`);
  assert(
    pointerProbe.pointerFlavorMeaning === "candidate_entry_target_provenance_path",
    `pointerProbe pointerFlavorMeaning mismatch: ${pointerProbe.pointerFlavorMeaning}`
  );
  assert(typeof pointerProbe.candidateOffset === "number", "pointerProbe candidateOffset missing");
  assert(pointerProbe.debugTrace[2]?.startsWith("candidate rng 07/08"), "pointerProbe debugTrace candidate step missing");
  assert(pointerProbe.debugTrace[3]?.startsWith("combat hook "), "pointerProbe debugTrace combat-hook order mismatch");
  assert(pointerProbe.debugTrace[4]?.startsWith("post-branch marker="), "pointerProbe debugTrace marker order mismatch");
  assert(
    pointerProbe.debugTrace[4]?.includes("pointer=candidate/candidate_entry_target_provenance_path"),
    `pointerProbe debugTrace pointer meaning mismatch: ${pointerProbe.debugTrace[4]}`
  );
  assert(pointerProbe.debugTrace[5]?.startsWith("target terminal "), "pointerProbe debugTrace target-terminal order mismatch");

  const ability = resolveActorCommand({
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

  const matrix = resolveActorCommandMatrix([
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
