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
  assert(attack.combatDecision?.branchVariantBindingStatus === undefined, "attack branchVariantBindingStatus should be undefined");
  assert(attack.postBranchRoute === 0, `attack postBranchRoute mismatch: ${attack.postBranchRoute}`);
  assert(attack.postBranchTargetSource === "slotIndex", `attack postBranchTargetSource mismatch: ${attack.postBranchTargetSource}`);
  assert(attack.pointerFlavor === "shared", `attack pointerFlavor mismatch: ${attack.pointerFlavor}`);
  assert(
    attack.pointerFlavorMeaning === "shared_default_target_provenance_path",
    `attack pointerFlavorMeaning mismatch: ${attack.pointerFlavorMeaning}`
  );
  assert(Array.isArray(attack.debugTrace) && attack.debugTrace.length === 6, "attack debugTrace shape mismatch");
  assert(attack.debugTrace[3]?.startsWith("combat hook "), "attack debugTrace combat-hook order mismatch");
  assert(
    attack.debugTrace[3]?.includes("variant=--/--") &&
      attack.debugTrace[3]?.includes("binding=--") &&
      attack.debugTrace[3]?.includes(`route=${attack.postBranchRoute}`),
    `attack debugTrace variant wording mismatch: ${attack.debugTrace[3]}`
  );
  assert(attack.debugTrace[4]?.startsWith("post-branch marker="), "attack debugTrace marker order mismatch");
  assert(
    attack.debugTrace[4]?.includes(`marker=${attack.postBranchTargetSource}`) &&
      attack.debugTrace[4]?.includes("pointer=shared/shared_default_target_provenance_path"),
    `attack debugTrace pointer meaning mismatch: ${attack.debugTrace[4]}`
  );
  assert(
    attack.debugTrace[5]?.startsWith("target terminal ") &&
      attack.debugTrace[5]?.includes(`source=${attack.targetSource}`) &&
      attack.debugTrace[5]?.endsWith(`=> ${attack.target}`),
    `attack debugTrace target-terminal order mismatch: ${attack.debugTrace[5]}`
  );

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

  const attackExplicit = resolveActorCommand({
    actorIndex: 0,
    action: {
      kindId: 0x10,
      arg: 0,
      target: 0x00,
      slotIndex: 0
    },
    outcomeLikeByte: 0
  });

  assert(attackExplicit.branch === attack.branch, `attackExplicit branch mismatch: ${attackExplicit.branch}`);
  assert(attackExplicit.localPath === attack.localPath, `attackExplicit localPath mismatch: ${attackExplicit.localPath}`);
  assert(attackExplicit.postBranchRoute === attack.postBranchRoute, `attackExplicit postBranchRoute mismatch: ${attackExplicit.postBranchRoute}`);
  assert(attackExplicit.pointerFlavor === attack.pointerFlavor, `attackExplicit pointerFlavor mismatch: ${attackExplicit.pointerFlavor}`);
  assert(attackExplicit.targetSource === "explicit", `attackExplicit targetSource mismatch: ${attackExplicit.targetSource}`);
  assert(attackExplicit.postBranchTargetSource === "explicit", `attackExplicit postBranchTargetSource mismatch: ${attackExplicit.postBranchTargetSource}`);
  assert(
    attackExplicit.debugTrace[4]?.includes("marker=explicit") &&
      attackExplicit.debugTrace[4]?.includes("pointer=shared/shared_default_target_provenance_path"),
    `attackExplicit debugTrace marker/pointer mismatch: ${attackExplicit.debugTrace[4]}`
  );

  const attackSlotProbe = resolveActorCommand({
    actorIndex: 0,
    action: {
      kindId: 0x10,
      arg: 0,
      target: 0xff,
      slotIndex: 1
    },
    outcomeLikeByte: 0
  });

  assert(attackSlotProbe.branch === attack.branch, `attackSlotProbe branch mismatch: ${attackSlotProbe.branch}`);
  assert(attackSlotProbe.localPath === attack.localPath, `attackSlotProbe localPath mismatch: ${attackSlotProbe.localPath}`);
  assert(attackSlotProbe.postBranchRoute === attack.postBranchRoute, `attackSlotProbe postBranchRoute mismatch: ${attackSlotProbe.postBranchRoute}`);
  assert(attackSlotProbe.pointerFlavor === attack.pointerFlavor, `attackSlotProbe pointerFlavor mismatch: ${attackSlotProbe.pointerFlavor}`);
  assert(attackSlotProbe.targetSource === "slotIndex", `attackSlotProbe targetSource mismatch: ${attackSlotProbe.targetSource}`);
  assert(attackSlotProbe.target === 1, `attackSlotProbe target mismatch: ${attackSlotProbe.target}`);
  assert(attackSlotProbe.postBranchTargetSource === "slotIndex", `attackSlotProbe postBranchTargetSource mismatch: ${attackSlotProbe.postBranchTargetSource}`);
  assert(
    attackSlotProbe.debugTrace[4]?.includes("marker=slotIndex") &&
      attackSlotProbe.debugTrace[4]?.includes("pointer=shared/shared_default_target_provenance_path"),
    `attackSlotProbe debugTrace marker/pointer mismatch: ${attackSlotProbe.debugTrace[4]}`
  );

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
    pointerProbe.combatDecision?.branchVariantMeaning === "candidate_family_lane_refinement_bit",
    `pointerProbe branchVariantMeaning mismatch: ${pointerProbe.combatDecision?.branchVariantMeaning}`
  );
  assert(
    pointerProbe.combatDecision?.branchVariantBindingStatus === "deferred_numeric_binding",
    `pointerProbe branchVariantBindingStatus mismatch: ${pointerProbe.combatDecision?.branchVariantBindingStatus}`
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
  assert(
    pointerProbe.debugTrace[3]?.includes("variant=") &&
      pointerProbe.debugTrace[3]?.includes("/" + String(pointerProbe.combatDecision?.branchVariantMeaning)) &&
      pointerProbe.debugTrace[3]?.includes("binding=deferred_numeric_binding") &&
      pointerProbe.debugTrace[3]?.includes(`route=${pointerProbe.postBranchRoute}`),
    `pointerProbe debugTrace variant wording mismatch: ${pointerProbe.debugTrace[3]}`
  );
  assert(pointerProbe.debugTrace[4]?.startsWith("post-branch marker="), "pointerProbe debugTrace marker order mismatch");
  assert(
    pointerProbe.debugTrace[4]?.includes(`marker=${pointerProbe.postBranchTargetSource}`) &&
      pointerProbe.debugTrace[4]?.includes("pointer=candidate/candidate_entry_target_provenance_path"),
    `pointerProbe debugTrace pointer meaning mismatch: ${pointerProbe.debugTrace[4]}`
  );
  assert(
    pointerProbe.debugTrace[5]?.startsWith("target terminal ") &&
      pointerProbe.debugTrace[5]?.includes(`source=${pointerProbe.targetSource}`) &&
      pointerProbe.debugTrace[5]?.endsWith(`=> ${pointerProbe.target}`),
    `pointerProbe debugTrace target-terminal order mismatch: ${pointerProbe.debugTrace[5]}`
  );

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

  const abilityExplicit = resolveActorCommand({
    actorIndex: 2,
    action: {
      kindId: 0x20,
      arg: 1,
      target: 0x00,
      slotIndex: 1
    },
    outcomeLikeByte: 0
  });

  assert(abilityExplicit.branch === ability.branch, `abilityExplicit branch mismatch: ${abilityExplicit.branch}`);
  assert(abilityExplicit.localPath === ability.localPath, `abilityExplicit localPath mismatch: ${abilityExplicit.localPath}`);
  assert(abilityExplicit.postBranchRoute === ability.postBranchRoute, `abilityExplicit postBranchRoute mismatch: ${abilityExplicit.postBranchRoute}`);
  assert(abilityExplicit.pointerFlavor === ability.pointerFlavor, `abilityExplicit pointerFlavor mismatch: ${abilityExplicit.pointerFlavor}`);
  assert(abilityExplicit.targetSource === "explicit", `abilityExplicit targetSource mismatch: ${abilityExplicit.targetSource}`);
  assert(abilityExplicit.postBranchTargetSource === "explicit", `abilityExplicit postBranchTargetSource mismatch: ${abilityExplicit.postBranchTargetSource}`);
  assert(
    abilityExplicit.debugTrace[4]?.includes("marker=explicit") &&
      abilityExplicit.debugTrace[4]?.includes("pointer=shared/shared_default_target_provenance_path"),
    `abilityExplicit debugTrace marker/pointer mismatch: ${abilityExplicit.debugTrace[4]}`
  );

  const abilitySlotProbe = resolveActorCommand({
    actorIndex: 2,
    action: {
      kindId: 0x20,
      arg: 0,
      target: 0xff,
      slotIndex: 1
    },
    outcomeLikeByte: 0
  });

  assert(abilitySlotProbe.branch === 32, `abilitySlotProbe branch mismatch: ${abilitySlotProbe.branch}`);
  assert(abilitySlotProbe.localPath === 0, `abilitySlotProbe localPath mismatch: ${abilitySlotProbe.localPath}`);
  assert(abilitySlotProbe.postBranchRoute === 0, `abilitySlotProbe postBranchRoute mismatch: ${abilitySlotProbe.postBranchRoute}`);
  assert(abilitySlotProbe.pointerFlavor === "shared", `abilitySlotProbe pointerFlavor mismatch: ${abilitySlotProbe.pointerFlavor}`);
  assert(abilitySlotProbe.targetSource === "slotIndex", `abilitySlotProbe targetSource mismatch: ${abilitySlotProbe.targetSource}`);
  assert(abilitySlotProbe.target === 1, `abilitySlotProbe target mismatch: ${abilitySlotProbe.target}`);
  assert(abilitySlotProbe.postBranchTargetSource === "slotIndex", `abilitySlotProbe postBranchTargetSource mismatch: ${abilitySlotProbe.postBranchTargetSource}`);
  assert(
    abilitySlotProbe.debugTrace[4]?.includes("marker=slotIndex") &&
      abilitySlotProbe.debugTrace[4]?.includes("pointer=shared/shared_default_target_provenance_path"),
    `abilitySlotProbe debugTrace marker/pointer mismatch: ${abilitySlotProbe.debugTrace[4]}`
  );

  const matrix = resolveActorCommandMatrix([
    {
      actorIndex: 0,
      action: { kindId: 0x10, arg: 0, target: 0xff, slotIndex: 0 },
      outcomeLikeByte: 0
    },
    {
      actorIndex: 0,
      action: { kindId: 0x10, arg: 0, target: 0x00, slotIndex: 0 },
      outcomeLikeByte: 0
    },
    {
      actorIndex: 0,
      action: { kindId: 0x10, arg: 0, target: 0xff, slotIndex: 1 },
      outcomeLikeByte: 0
    },
    {
      actorIndex: 0,
      action: { kindId: 0x01, arg: 0, target: 0xff, slotIndex: 0 },
      outcomeLikeByte: 0
    },
    {
      actorIndex: 2,
      action: { kindId: 0x20, arg: 1, target: 0x00, slotIndex: 1 },
      outcomeLikeByte: 0
    },
    {
      actorIndex: 2,
      action: { kindId: 0x20, arg: 0, target: 0xff, slotIndex: 1 },
      outcomeLikeByte: 0
    }
  ]);

  assert(matrix.length === 6, `matrix length mismatch: ${matrix.length}`);
  assert(matrix[0]?.targetSource === "slotIndex", `matrix[0] targetSource mismatch: ${matrix[0]?.targetSource}`);
  assert(matrix[1]?.targetSource === "explicit", `matrix[1] targetSource mismatch: ${matrix[1]?.targetSource}`);
  assert(matrix[2]?.targetSource === "slotIndex", `matrix[2] targetSource mismatch: ${matrix[2]?.targetSource}`);
  assert(matrix[2]?.target === 1, `matrix[2] target mismatch: ${matrix[2]?.target}`);
  assert(matrix[3]?.targetSource === "candidate", `matrix[3] targetSource mismatch: ${matrix[3]?.targetSource}`);
  assert(matrix[4]?.targetSource === "explicit", `matrix[4] targetSource mismatch: ${matrix[4]?.targetSource}`);
  assert(matrix[5]?.targetSource === "slotIndex", `matrix[5] targetSource mismatch: ${matrix[5]?.targetSource}`);
  assert(matrix[5]?.target === 1, `matrix[5] target mismatch: ${matrix[5]?.target}`);
}

runResolveActorCommandChecks();
console.log("selfcheck ok");
