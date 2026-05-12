# In-Progress SaGa2 Analysis

These reports preserve active investigation and unresolved questions.

## Current Open Questions

- Acquire and analyze direct body of `5F22`.
- Compare direct body of `5F22` with `5E77`.
- Confirm whether `5F22` is merely global setup or participates in hidden/shared state initialization.
- Reconnect `6157` as downstream apply/staging after `611C`.
- Continue search for `C2F6` producer / writer path.
- Keep normal attack entry gap separate from confirmed battle-loop model until resolved.

## Next Recommended Analysis Actions

- Read loop-boundary reports first when working on battle-loop sequencing.
- Read `c2xx/` before making claims about hidden/shared init or block writers.
- Treat ROM image/music extraction notes as active frontier work until selector-stage outputs are directly observed.

## Investigation Topics

## Gaps

Open gaps, unresolved boundaries, and current missing links.

- [saga2_019e_battle_consumer_priority_report.md](gaps/saga2_019e_battle_consumer_priority_report.md)
- [saga2_019e_commit_frontier_report.md](gaps/saga2_019e_commit_frontier_report.md)
- [saga2_019e_immediate_local_target_narrowing_report.md](gaps/saga2_019e_immediate_local_target_narrowing_report.md)
- [saga2_019e_seed_consumer_report.md](gaps/saga2_019e_seed_consumer_report.md)
- [saga2_611c_core_vs_visible_boundary_report.md](gaps/saga2_611c_core_vs_visible_boundary_report.md)
- [saga2_actor_local_consumer_boundary_report.md](gaps/saga2_actor_local_consumer_boundary_report.md)
- [saga2_branchvariant_binding_gap_report.md](gaps/saga2_branchvariant_binding_gap_report.md)
- [saga2_c760_consumer_report.md](gaps/saga2_c760_consumer_report.md)
- [saga2_outcome_like_first_consumer_semantics_report.md](gaps/saga2_outcome_like_first_consumer_semantics_report.md)
- [saga2_pending_combat_decision_frontier_report.md](gaps/saga2_pending_combat_decision_frontier_report.md)
- [saga2_ptr_second_line_candidate_source_persistence_report.md](gaps/saga2_ptr_second_line_candidate_source_persistence_report.md)
- [saga2_remaining_decisive_frontiers_report.md](gaps/saga2_remaining_decisive_frontiers_report.md)
- [saga2_special_candidate_family_variant_report.md](gaps/saga2_special_candidate_family_variant_report.md)
- [saga2_step4_step5_api_frontier_report.md](gaps/saga2_step4_step5_api_frontier_report.md)
- [saga2_step6_start_coding_boundary_report.md](gaps/saga2_step6_start_coding_boundary_report.md)
- [saga2_typescript_godot_bridge_frontier_report.md](gaps/saga2_typescript_godot_bridge_frontier_report.md)

## Frontiers

Active frontiers, ROM-side observation targets, and unresolved narrowing work.

- [saga2_00d2_battle_callers_report.md](frontiers/saga2_00d2_battle_callers_report.md)
- [saga2_0180_0183_value_adjust_report.md](frontiers/saga2_0180_0183_value_adjust_report.md)
- [saga2_0198_cross_cluster_report.md](frontiers/saga2_0198_cross_cluster_report.md)
- [saga2_0198_immediate_caller_cluster_report.md](frontiers/saga2_0198_immediate_caller_cluster_report.md)
- [saga2_0198_predicate_report.md](frontiers/saga2_0198_predicate_report.md)
- [saga2_019b_indexing_report.md](frontiers/saga2_019b_indexing_report.md)
- [saga2_019e_big_struct_exclusion_report.md](frontiers/saga2_019e_big_struct_exclusion_report.md)
- [saga2_019e_caller_isolation_report.md](frontiers/saga2_019e_caller_isolation_report.md)
- [saga2_019e_identity_as_degenerate_outcome_report.md](frontiers/saga2_019e_identity_as_degenerate_outcome_report.md)
- [saga2_019e_local_result_slot_isolation_report.md](frontiers/saga2_019e_local_result_slot_isolation_report.md)
- [saga2_019e_local_vs_shared_decision_report.md](frontiers/saga2_019e_local_vs_shared_decision_report.md)
- [saga2_019e_marker_vs_outcome_report.md](frontiers/saga2_019e_marker_vs_outcome_report.md)
- [saga2_019e_not_just_boolean_report.md](frontiers/saga2_019e_not_just_boolean_report.md)
- [saga2_019e_outcome_byte_priority_report.md](frontiers/saga2_019e_outcome_byte_priority_report.md)
- [saga2_019e_post_resolve_pre_apply_window_report.md](frontiers/saga2_019e_post_resolve_pre_apply_window_report.md)
- [saga2_019e_settled_result_semantics_report.md](frontiers/saga2_019e_settled_result_semantics_report.md)
- [saga2_019e_shadow_family_layering_report.md](frontiers/saga2_019e_shadow_family_layering_report.md)
- [saga2_019e_small_family_hypothesis_report.md](frontiers/saga2_019e_small_family_hypothesis_report.md)
- [saga2_019e_success_side_state_report.md](frontiers/saga2_019e_success_side_state_report.md)
- [saga2_01b9_selection_resolver_report.md](frontiers/saga2_01b9_selection_resolver_report.md)
- [saga2_01e3_wrapper_report.md](frontiers/saga2_01e3_wrapper_report.md)
- [saga2_0469_state_machine_report.md](frontiers/saga2_0469_state_machine_report.md)
- [saga2_0e_qualifier1_symmetry_report.md](frontiers/saga2_0e_qualifier1_symmetry_report.md)
- [saga2_1551_selector_terminal_report.md](frontiers/saga2_1551_selector_terminal_report.md)
- [saga2_41e3_41e5_cocarried_decision_rule_report.md](frontiers/saga2_41e3_41e5_cocarried_decision_rule_report.md)
- [saga2_41e3_41e5_current_output_rule_report.md](frontiers/saga2_41e3_41e5_current_output_rule_report.md)
- [saga2_41e3_41e5_local_glue_rule_report.md](frontiers/saga2_41e3_41e5_local_glue_rule_report.md)
- [saga2_41e3_41e5_same_local_polarity_rule_report.md](frontiers/saga2_41e3_41e5_same_local_polarity_rule_report.md)
- [saga2_4579_queue_builder_report.md](frontiers/saga2_4579_queue_builder_report.md)
- [saga2_5f07_selector_resolve_report.md](frontiers/saga2_5f07_selector_resolve_report.md)
- [saga2_5f_refresh_family_report.md](frontiers/saga2_5f_refresh_family_report.md)
- [saga2_60c0_6156_hidden_seed_layer_report.md](frontiers/saga2_60c0_6156_hidden_seed_layer_report.md)
- [saga2_60c0_shared_builder_relation_report.md](frontiers/saga2_60c0_shared_builder_relation_report.md)
- [saga2_60e8_611b_parent_setup_report.md](frontiers/saga2_60e8_611b_parent_setup_report.md)
- [saga2_611c_0198_proximity_report.md](frontiers/saga2_611c_0198_proximity_report.md)
- [saga2_611c_inner_core_priority_report.md](frontiers/saga2_611c_inner_core_priority_report.md)
- [saga2_611c_named_local_family_elimination_report.md](frontiers/saga2_611c_named_local_family_elimination_report.md)
- [saga2_62a2_6330_cluster_report.md](frontiers/saga2_62a2_6330_cluster_report.md)
- [saga2_6332_success_rebuild_report.md](frontiers/saga2_6332_success_rebuild_report.md)
- [saga2_actor_local_bridge_debug_report.md](frontiers/saga2_actor_local_bridge_debug_report.md)
- [saga2_actor_resolve_result_extension_report.md](frontiers/saga2_actor_resolve_result_extension_report.md)
- [saga2_actors_loop_report.md](frontiers/saga2_actors_loop_report.md)
- [saga2_bank_switch_helper_callers_report.md](frontiers/saga2_bank_switch_helper_callers_report.md)
- [saga2_battle_action_class_prepass_report.md](frontiers/saga2_battle_action_class_prepass_report.md)
- [saga2_battle_prepare_helpers_report.md](frontiers/saga2_battle_prepare_helpers_report.md)
- [saga2_battle_prepass_hl_source_report.md](frontiers/saga2_battle_prepass_hl_source_report.md)
- [saga2_battle_prepass_orchestration_report.md](frontiers/saga2_battle_prepass_orchestration_report.md)
- [saga2_battle_prepass_page_seed_report.md](frontiers/saga2_battle_prepass_page_seed_report.md)
- [saga2_battle_runtime_entry_report.md](frontiers/saga2_battle_runtime_entry_report.md)
- [saga2_battle_state_helpers_report.md](frontiers/saga2_battle_state_helpers_report.md)
- [saga2_branch_code_phase_vs_result_report.md](frontiers/saga2_branch_code_phase_vs_result_report.md)
- [saga2_branch_code_shape_report.md](frontiers/saga2_branch_code_shape_report.md)
- [saga2_branch_phase_granularity_report.md](frontiers/saga2_branch_phase_granularity_report.md)
- [saga2_bulk_copy_fill_helpers_report.md](frontiers/saga2_bulk_copy_fill_helpers_report.md)
- [saga2_c71d_builder_subsystems_report.md](frontiers/saga2_c71d_builder_subsystems_report.md)
- [saga2_c71d_c2b9_runtime_buffers_report.md](frontiers/saga2_c71d_c2b9_runtime_buffers_report.md)
- [saga2_c71d_c2b9_selector_space_report.md](frontiers/saga2_c71d_c2b9_selector_space_report.md)
- [saga2_c73d_seed_table_report.md](frontiers/saga2_c73d_seed_table_report.md)
- [saga2_c745_c70a_cost_tables_report.md](frontiers/saga2_c745_c70a_cost_tables_report.md)
- [saga2_c745_head_update_report.md](frontiers/saga2_c745_head_update_report.md)
- [saga2_c7e0_selector_semantics_report.md](frontiers/saga2_c7e0_selector_semantics_report.md)
- [saga2_c7e0_shared_scratch_report.md](frontiers/saga2_c7e0_shared_scratch_report.md)
- [saga2_combat_decision_consume_bypass_report.md](frontiers/saga2_combat_decision_consume_bypass_report.md)
- [saga2_combat_decision_first_consumer_frontier_report.md](frontiers/saga2_combat_decision_first_consumer_frontier_report.md)
- [saga2_combat_decision_output_order_report.md](frontiers/saga2_combat_decision_output_order_report.md)
- [saga2_combat_decision_reject_fallback_report.md](frontiers/saga2_combat_decision_reject_fallback_report.md)
- [saga2_combat_decision_validation_path_report.md](frontiers/saga2_combat_decision_validation_path_report.md)
- [saga2_counter_consume_microflow_report.md](frontiers/saga2_counter_consume_microflow_report.md)
- [saga2_counter_gate_ch_register_origins_report.md](frontiers/saga2_counter_gate_ch_register_origins_report.md)
- [saga2_counter_gate_formation_report.md](frontiers/saga2_counter_gate_formation_report.md)
- [saga2_d12_entry_semantics_report.md](frontiers/saga2_d12_entry_semantics_report.md)
- [saga2_decode_outcome_api_report.md](frontiers/saga2_decode_outcome_api_report.md)
- [saga2_deferred_binding_strategy_shortform_report.md](frontiers/saga2_deferred_binding_strategy_shortform_report.md)
- [saga2_effective_slot_primary_emphasis_report.md](frontiers/saga2_effective_slot_primary_emphasis_report.md)
- [saga2_ff8c_token_domain_comparison_report.md](frontiers/saga2_ff8c_token_domain_comparison_report.md)
- [saga2_immediate_implementation_backlog_report.md](frontiers/saga2_immediate_implementation_backlog_report.md)
- [saga2_input_wrappers_report.md](frontiers/saga2_input_wrappers_report.md)
- [saga2_layer_relation_matrix_report.md](frontiers/saga2_layer_relation_matrix_report.md)
- [saga2_local_action_opener_frontier_report.md](frontiers/saga2_local_action_opener_frontier_report.md)
- [saga2_mbc1_writepoints_report.md](frontiers/saga2_mbc1_writepoints_report.md)
- [saga2_mode_transition_helpers_report.md](frontiers/saga2_mode_transition_helpers_report.md)
- [saga2_name_table_caller_classification_report.md](frontiers/saga2_name_table_caller_classification_report.md)
- [saga2_pair_visibility_direct_landing_report.md](frontiers/saga2_pair_visibility_direct_landing_report.md)
- [saga2_particle_state_machine_report.md](frontiers/saga2_particle_state_machine_report.md)
- [saga2_pointer_before_final_target_report.md](frontiers/saga2_pointer_before_final_target_report.md)
- [saga2_pointer_reopening_onset_report.md](frontiers/saga2_pointer_reopening_onset_report.md)
- [saga2_porting_minimum_blockers_report.md](frontiers/saga2_porting_minimum_blockers_report.md)
- [saga2_post_branch_targetsource_independence_report.md](frontiers/saga2_post_branch_targetsource_independence_report.md)
- [saga2_post_route_target_evidence_order_report.md](frontiers/saga2_post_route_target_evidence_order_report.md)
- [saga2_qualifier_eq1_reject_report.md](frontiers/saga2_qualifier_eq1_reject_report.md)
- [saga2_qualifier_ge2_class_report.md](frontiers/saga2_qualifier_ge2_class_report.md)
- [saga2_random_seeds_callers_report.md](frontiers/saga2_random_seeds_callers_report.md)
- [saga2_resolve_actor_command_order_report.md](frontiers/saga2_resolve_actor_command_order_report.md)
- [saga2_rom_363f_00ac_copy_bridge_report.md](frontiers/saga2_rom_363f_00ac_copy_bridge_report.md)
- [saga2_rom_block_preview_validation_report.md](frontiers/saga2_rom_block_preview_validation_report.md)
- [saga2_rom_character_image_entry_report.md](frontiers/saga2_rom_character_image_entry_report.md)
- [saga2_rom_first_intermediate_value_target_report.md](frontiers/saga2_rom_first_intermediate_value_target_report.md)
- [saga2_rom_first_proof_extraction_report.md](frontiers/saga2_rom_first_proof_extraction_report.md)
- [saga2_rom_gfx_preload_bridge_report.md](frontiers/saga2_rom_gfx_preload_bridge_report.md)
- [saga2_rom_header_pointer_vs_preload_report.md](frontiers/saga2_rom_header_pointer_vs_preload_report.md)
- [saga2_rom_image_extractor_first_anchor_report.md](frontiers/saga2_rom_image_extractor_first_anchor_report.md)
- [saga2_rom_image_first_case_bytes_report.md](frontiers/saga2_rom_image_first_case_bytes_report.md)
- [saga2_rom_image_first_proof_case_report.md](frontiers/saga2_rom_image_first_proof_case_report.md)
- [saga2_rom_intermediate_value_decision_rule_report.md](frontiers/saga2_rom_intermediate_value_decision_rule_report.md)
- [saga2_rom_music_anchor_surface_report.md](frontiers/saga2_rom_music_anchor_surface_report.md)
- [saga2_rom_music_atom_extension_report.md](frontiers/saga2_rom_music_atom_extension_report.md)
- [saga2_rom_music_chunk_comparison_report.md](frontiers/saga2_rom_music_chunk_comparison_report.md)
- [saga2_rom_music_composite_chunk_decomposition_report.md](frontiers/saga2_rom_music_composite_chunk_decomposition_report.md)
- [saga2_rom_music_decode_plan_report.md](frontiers/saga2_rom_music_decode_plan_report.md)
- [saga2_rom_music_first_chunk_report.md](frontiers/saga2_rom_music_first_chunk_report.md)
- [saga2_rom_music_first_output_classification_report.md](frontiers/saga2_rom_music_first_output_classification_report.md)
- [saga2_rom_music_separator_polarity_report.md](frontiers/saga2_rom_music_separator_polarity_report.md)
- [saga2_rom_music_stable_atom_candidates_report.md](frontiers/saga2_rom_music_stable_atom_candidates_report.md)
- [saga2_rom_postcopy_object_materialization_report.md](frontiers/saga2_rom_postcopy_object_materialization_report.md)
- [saga2_rom_precopy_selector_stage_report.md](frontiers/saga2_rom_precopy_selector_stage_report.md)
- [saga2_rom_preload_byte_anchor_report.md](frontiers/saga2_rom_preload_byte_anchor_report.md)
- [saga2_rom_preload_decode_bridge_candidate_report.md](frontiers/saga2_rom_preload_decode_bridge_candidate_report.md)
- [saga2_rom_preload_decode_flow_report.md](frontiers/saga2_rom_preload_decode_flow_report.md)
- [saga2_rom_preload_list_single_entry_report.md](frontiers/saga2_rom_preload_list_single_entry_report.md)
- [saga2_rom_preload_selector_model_report.md](frontiers/saga2_rom_preload_selector_model_report.md)
- [saga2_rom_reentry_path_report.md](frontiers/saga2_rom_reentry_path_report.md)
- [saga2_rom_selector_ranking_rationale_report.md](frontiers/saga2_rom_selector_ranking_rationale_report.md)
- [saga2_rom_selector_wrapper_rationale_report.md](frontiers/saga2_rom_selector_wrapper_rationale_report.md)
- [saga2_route_core_implementation_note_report.md](frontiers/saga2_route_core_implementation_note_report.md)
- [saga2_routing_layer_second_line_report.md](frontiers/saga2_routing_layer_second_line_report.md)
- [saga2_rst08_e15_seeded_source_report.md](frontiers/saga2_rst08_e15_seeded_source_report.md)
- [saga2_source_hardening_backlog_report.md](frontiers/saga2_source_hardening_backlog_report.md)
- [saga2_special_code_ff_0e_0f_report.md](frontiers/saga2_special_code_ff_0e_0f_report.md)
- [saga2_step6_provisional_milestone_report.md](frontiers/saga2_step6_provisional_milestone_report.md)
- [saga2_success_fail_event_family_report.md](frontiers/saga2_success_fail_event_family_report.md)
- [saga2_target_diff_explained_by_pointer_class_report.md](frontiers/saga2_target_diff_explained_by_pointer_class_report.md)
- [saga2_to5_rom_stance_report.md](frontiers/saga2_to5_rom_stance_report.md)
- [saga2_to5_selector_observation_wait_report.md](frontiers/saga2_to5_selector_observation_wait_report.md)

## C2Xx

C2xx / C7xx workspace, producer, consumer, and hidden-init investigations.

- [saga2_c200_export_import_cluster_report.md](c2xx/saga2_c200_export_import_cluster_report.md)
- [saga2_c20f_c7e0_c2f6_connection_gap_report.md](c2xx/saga2_c20f_c7e0_c2f6_connection_gap_report.md)
- [saga2_c20f_field_role_report.md](c2xx/saga2_c20f_field_role_report.md)
- [saga2_c21f_after_base_elimination_report.md](c2xx/saga2_c21f_after_base_elimination_report.md)
- [saga2_c21f_after_base_search_report.md](c2xx/saga2_c21f_after_base_search_report.md)
- [saga2_c21f_block_builder_report.md](c2xx/saga2_c21f_block_builder_report.md)
- [saga2_c21f_c7e0_consumer_split_report.md](c2xx/saga2_c21f_c7e0_consumer_split_report.md)
- [saga2_c21f_consumer_candidate_gap_report.md](c2xx/saga2_c21f_consumer_candidate_gap_report.md)
- [saga2_c21f_flat_list_destination_report.md](c2xx/saga2_c21f_flat_list_destination_report.md)
- [saga2_c21f_no_readback_yet_report.md](c2xx/saga2_c21f_no_readback_yet_report.md)
- [saga2_c21f_offset_read_search_plan_report.md](c2xx/saga2_c21f_offset_read_search_plan_report.md)
- [saga2_c21f_stride_helper_report.md](c2xx/saga2_c21f_stride_helper_report.md)
- [saga2_c2a2_budget_report.md](c2xx/saga2_c2a2_budget_report.md)
- [saga2_c2b9_entry_decode_report.md](c2xx/saga2_c2b9_entry_decode_report.md)
- [saga2_c2b9_workspace_subsystems_report.md](c2xx/saga2_c2b9_workspace_subsystems_report.md)
- [saga2_c2da_producers_report.md](c2xx/saga2_c2da_producers_report.md)
- [saga2_c2f6_copy_wrapper_gap_report.md](c2xx/saga2_c2f6_copy_wrapper_gap_report.md)
- [saga2_c2f6_four_layer_reconnection_report.md](c2xx/saga2_c2f6_four_layer_reconnection_report.md)
- [saga2_c2f6_hidden_init_boundary_report.md](c2xx/saga2_c2f6_hidden_init_boundary_report.md)
- [saga2_c2f6_hidden_init_candidate_clusters_report.md](c2xx/saga2_c2f6_hidden_init_candidate_clusters_report.md)
- [saga2_c2f6_hidden_init_entrypoints_report.md](c2xx/saga2_c2f6_hidden_init_entrypoints_report.md)
- [saga2_c2f6_search_reprioritization_report.md](c2xx/saga2_c2f6_search_reprioritization_report.md)
- [saga2_c2f6_state_gap_report.md](c2xx/saga2_c2f6_state_gap_report.md)
- [saga2_c2f6_zero_fill_gap_report.md](c2xx/saga2_c2f6_zero_fill_gap_report.md)
- [saga2_c2xx_block_writer_gap_report.md](c2xx/saga2_c2xx_block_writer_gap_report.md)
- [saga2_c2xx_destination_scan_report.md](c2xx/saga2_c2xx_destination_scan_report.md)

## Normal Attack

Normal attack entry uncertainty kept separate from confirmed battle-loop knowledge.

- [saga2_normal_attack_entry_gap_report.md](normal_attack/saga2_normal_attack_entry_gap_report.md)

## Rng Open Questions

RNG-side open questions, unresolved slots, and growth/RNG follow-up notes.

- [growth.md](rng_open_questions/growth.md)
- [saga2_battle_rng_44f4_report.md](rng_open_questions/saga2_battle_rng_44f4_report.md)
- [saga2_battle_rng_45a8_report.md](rng_open_questions/saga2_battle_rng_45a8_report.md)
- [saga2_combat_rng_entry_vs_counter_report.md](rng_open_questions/saga2_combat_rng_entry_vs_counter_report.md)
- [saga2_combat_rng_extension_frontier_report.md](rng_open_questions/saga2_combat_rng_extension_frontier_report.md)
- [saga2_combat_rng_inner_belt_split_report.md](rng_open_questions/saga2_combat_rng_inner_belt_split_report.md)
- [saga2_first_recoverable_combat_rng_meaning_report.md](rng_open_questions/saga2_first_recoverable_combat_rng_meaning_report.md)
- [saga2_growth_rng_reverse_lookup_report.md](rng_open_questions/saga2_growth_rng_reverse_lookup_report.md)
- [saga2_rng_battle_reachability_report.md](rng_open_questions/saga2_rng_battle_reachability_report.md)
- [saga2_rng_damage_core_gap_report.md](rng_open_questions/saga2_rng_damage_core_gap_report.md)
- [saga2_rng_slot07_08_offset_report.md](rng_open_questions/saga2_rng_slot07_08_offset_report.md)

## Loop Boundary

Loop-entry and loop-handoff reports around 5F22 / 5E77 / 611C / 6157.

- [saga2_5e77_parent_loop_context_report.md](loop_boundary/saga2_5e77_parent_loop_context_report.md)
- [saga2_5f22_preloop_setup_report.md](loop_boundary/saga2_5f22_preloop_setup_report.md)
- [saga2_611c_6157_handoff_boundary_report.md](loop_boundary/saga2_611c_6157_handoff_boundary_report.md)
- [saga2_6157_apply_staging_context_report.md](loop_boundary/saga2_6157_apply_staging_context_report.md)
- [saga2_6157_entry_contract_report.md](loop_boundary/saga2_6157_entry_contract_report.md)
- [saga2_6157_entry_preexisting_vs_constructed_report.md](loop_boundary/saga2_6157_entry_preexisting_vs_constructed_report.md)
- [saga2_6157_first_branch_decision_report.md](loop_boundary/saga2_6157_first_branch_decision_report.md)
- [saga2_6157_minimal_handoff_shape_report.md](loop_boundary/saga2_6157_minimal_handoff_shape_report.md)
- [saga2_6157_outcome_like_bridge_report.md](loop_boundary/saga2_6157_outcome_like_bridge_report.md)
- [saga2_6157_player_scoped_handoff_report.md](loop_boundary/saga2_6157_player_scoped_handoff_report.md)
