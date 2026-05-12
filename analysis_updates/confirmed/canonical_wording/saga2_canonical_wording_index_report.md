# SaGa2 Canonical Wording Index Report

## Goal

current frontier で「どの wording を canonical とみなすか」を
入口レポートとして整理する。

## Canonical summaries

### Overall proximity / readiness

- [saga2_recovered_semantics_proximity_report.md](saga2_recovered_semantics_proximity_report.md)
- [saga2_current_readiness_after_pair_alignment_report.md](saga2_current_readiness_after_pair_alignment_report.md)
- [saga2_readiness_after_exact_naming_report.md](saga2_readiness_after_exact_naming_report.md)

### First-line naming

- [saga2_branch_battlenative_naming_report.md](../decision_fields/saga2_branch_battlenative_naming_report.md)
- [saga2_branchvariant_lane_wording_report.md](../decision_fields/saga2_branchvariant_lane_wording_report.md)
- [saga2_branchvariant_binding_gap_report.md](../../in_progress/gaps/saga2_branchvariant_binding_gap_report.md)

### Transfer core

- [saga2_post_branch_route_lane_transfer_report.md](../decision_fields/saga2_post_branch_route_lane_transfer_report.md)
- [saga2_route_to_pointer_anchor_bridge_report.md](../decision_fields/saga2_route_to_pointer_anchor_bridge_report.md)

### Second-line naming

- [saga2_pointer_flavor_exact_naming_report.md](../decision_fields/saga2_pointer_flavor_exact_naming_report.md)
- [saga2_pointer_to_target_downstream_report.md](../decision_fields/saga2_pointer_to_target_downstream_report.md)
- [saga2_target_last_display_policy_report.md](../decision_fields/saga2_target_last_display_policy_report.md)

### Temporal chain

- [saga2_temporal_chain_wording_report.md](saga2_temporal_chain_wording_report.md)
- [saga2_effective_slot_overlap_report.md](saga2_effective_slot_overlap_report.md)

### Debug policy

- [saga2_debug_naming_policy_report.md](../debug_policy/saga2_debug_naming_policy_report.md)
- [saga2_debug_field_order_policy_report.md](../debug_policy/saga2_debug_field_order_policy_report.md)
- [saga2_debug_route_insertion_policy_report.md](../debug_policy/saga2_debug_route_insertion_policy_report.md)
- [saga2_current_debug_policy_snapshot_report.md](../debug_policy/saga2_current_debug_policy_snapshot_report.md)

## Current safest one-line model

現時点の canonical one-line model は次のとおり。

**`branch` = actor-local resolution lane pair、`branchVariant` = PTR-only candidate-family lane refinement bit、`postBranchRoute` = lane-transfer core、`pointerFlavor` = target-provenance path pair、`target` = downstream terminal result。**

## Current safest temporal one-line model

**`41E3-41E5` で retained refinement が handoff され、`41E6` で halo に入り、`41E7-41E9` で `pointerFlavor` pair が first effective に visible となり、その downstream effect として `41EB-41EC` の deterministic consume/writeback が走る。**

## Practical use

今後の docs / debug / code discussion では、

- naming を確認したいときは first-line / second-line / debug policy reports
- battle-side timing を確認したいときは temporal chain reports
- 「どこまで code-ready か」を見たいときは readiness / proximity reports

を見るのが safest である。
