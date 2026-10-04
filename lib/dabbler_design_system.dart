/// Dabbler Design System — the package's single public surface.
///
/// A consumer writes one import:
///
/// ```dart
/// import 'package:dabbler_design_system/dabbler_design_system.dart';
/// ```
///
/// and reaches every token and component this package ships. Nothing under
/// `lib/src/` is a supported import path; this file is the contract.
///
/// ## How this file stays honest (KAN-256 AC3)
///
/// `test/dabbler_design_system_test.dart` parses every library under
/// `lib/src/` for public top-level declarations and fails when one is neither
/// reachable through an export below nor named in that test's explicit
/// exemption list, with a written reason. It is a scanner, not a transcription
/// of this file, so a component landing in `lib/src/` with no export here
/// breaks the build rather than quietly falling out of the public API.
///
/// ## The gallery is part of the surface
///
/// `src/gallery/gallery_entry.dart` and each component's `*_gallery.dart` are
/// exported too. The gallery app (`lib/main.dart`) imports this barrel and
/// nothing under `lib/src/`, so it doubles as a standing check that the public
/// surface is actually sufficient to build with (KAN-259).
///
/// ## What is deliberately NOT exported
///
/// Each omission below is mirrored by an exemption entry in that test. The
/// answer to a scanner flagging an internal type is an exemption with a
/// reason — never a widening of this surface.
///
/// * `src/forms/field_shell.dart` in full — [DabblerFieldShell] and its
///   [DabblerFieldAlign] are the paint layer the form fields compose
///   internally (DS-600 AC1). No public component's API mentions either type,
///   so nothing a consumer writes needs them.
/// * `DabblerPickerFieldShell` from `src/forms/picker_field.dart` — the same
///   ruling for the typed-or-picked fields. The rest of that library
///   ([DabblerPickerField]) is public, so the file is exported with the shell
///   hidden rather than dropped.
/// * `progressSweepOffsetAt` from `src/feedback/progress_bar.dart` — a test
///   seam, documented as such at its declaration, that samples the
///   indeterminate keyframe without pumping frames. Not a component API.
/// * Private `part` members of the split libraries (`sheet_panel.dart`,
///   `sheet_route.dart`, `picker_field_shell.dart`). A `part` is not a
///   library and is never exported directly; its public members reach this
///   surface through the library that owns it, and its private members stay
///   private. Exporting a part file is a compile error, not a choice.
library;

export 'src/calendar/calendar.dart';
export 'src/calendar/calendar_day_status.dart';
export 'src/calendar/time_picker.dart';
export 'src/calendar/calendar_gallery.dart';
export 'src/calendar/calendar_year_gallery.dart';
export 'src/calendar/calendar_status_gallery.dart';
export 'src/cards/card.dart';
export 'src/cards/card_event_large.dart';
export 'src/cards/card_event_medium.dart';
export 'src/cards/card_event_small.dart';
export 'src/cards/card_event_listing.dart';
export 'src/cards/card_venue.dart';
export 'src/cards/card_game.dart';
export 'src/cards/card_game_gallery.dart';
export 'src/cards/card_upcoming.dart';
export 'src/cards/card_upcoming_gallery.dart';
export 'src/cards/listing_cards_gallery.dart';
export 'src/cards/card_house.dart';
export 'src/cards/card_pricing_default.dart';
export 'src/cards/card_pricing_selected.dart';
export 'src/cards/card_ticket.dart';
export 'src/cards/empty_state.dart';
export 'src/cards/card_active_room.dart';
export 'src/cards/card_poll.dart';
export 'src/cards/card_room.dart';
export 'src/cards/checklist_panel.dart';
export 'src/cards/icon_list.dart';
export 'src/cards/icon_list_gallery.dart';
export 'src/cards/member_list_panel.dart';
export 'src/cards/mutuals_card.dart';
export 'src/cards/panel_card.dart';
export 'src/cards/panel_cards_gallery.dart';
export 'src/cards/room_cards_gallery.dart';
export 'src/cards/stat_tile.dart';
export 'src/cards/profile_row.dart';
export 'src/cards/profile_row_gallery.dart';
export 'src/controls/link_chip.dart';
export 'src/controls/counter_link.dart';
export 'src/cards/stat_tile_value.dart';
export 'src/cards/headcount.dart';
export 'src/cards/list_row.dart';
export 'src/cards/stat_tile_gallery.dart';
export 'src/cards/cards_gallery.dart';
export 'src/controls/button.dart';
export 'src/controls/button_gallery.dart';
export 'src/controls/on_color_icon_button.dart';
export 'src/controls/on_color_icon_button_gallery.dart';
export 'src/controls/text_link.dart';
export 'src/controls/text_link_gallery.dart';
export 'src/controls/chip.dart';
export 'src/controls/chip_gallery.dart';
export 'src/controls/filter_rail.dart';
export 'src/controls/filter_rail_gallery.dart';
export 'src/controls/fab.dart';
export 'src/controls/fab_gallery.dart';
export 'src/feedback/banner.dart';
export 'src/feedback/banner_gallery.dart';
export 'src/feedback/inline_message.dart';
export 'src/feedback/inline_message_gallery.dart';
export 'src/feedback/progress_bar.dart' hide progressSweepOffsetAt;
export 'src/feedback/progress_bar_gallery.dart';
export 'src/feedback/progress_stages.dart';
export 'src/feedback/progress_stages_gallery.dart';
export 'src/feedback/skeleton.dart';
export 'src/feedback/skeleton_gallery.dart';
export 'src/feedback/ring.dart';
export 'src/feedback/ring_gallery.dart';
export 'src/feedback/spinner.dart';
export 'src/feedback/spinner_gallery.dart';
export 'src/feedback/toast.dart';
export 'src/feedback/toast_gallery.dart';
export 'src/feed/activity_row.dart';
export 'src/feed/feed_atoms.dart';
export 'src/feed/feed_gallery.dart';
export 'src/feed/news_card.dart';
export 'src/feed/post_row.dart';
export 'src/feed/attachment_chip.dart';
export 'src/feed/comment_row.dart';
export 'src/feed/post_detail.dart';
export 'src/feed/repost_row.dart';
export 'src/feed/reply_composer.dart';
export 'src/feed/thread_gallery.dart';
export 'src/media/image.dart';
export 'src/media/gallery_hero.dart';
export 'src/media/image_gallery.dart';
export 'src/media/provider_mark.dart';
export 'src/media/provider_mark_gallery.dart';
export 'src/forms/checkbox.dart';
export 'src/forms/code_input.dart';
export 'src/forms/date_columns.dart';
export 'src/forms/date_columns_gallery.dart';
export 'src/forms/date_field.dart';
export 'src/forms/highlighted_text.dart';
export 'src/forms/input_row.dart';
export 'src/forms/input_row_parts.dart';
export 'src/forms/picker_field.dart' hide DabblerPickerFieldShell;
export 'src/forms/radio.dart';
export 'src/forms/search_field.dart';
export 'src/forms/search_gallery.dart';
export 'src/forms/form_extras_gallery.dart';
export 'src/forms/selectable_card.dart';
export 'src/forms/selectable_card_gallery.dart';
export 'src/forms/select.dart';
export 'src/forms/slider.dart';
export 'src/forms/stepper.dart';
export 'src/forms/text_field.dart';
export 'src/forms/time_field.dart';
export 'src/forms/toggle.dart';
export 'src/forms/forms_gallery.dart';
export 'src/gallery/docs/doc_loader.dart';
export 'src/gallery/docs/doc_page.dart';
export 'src/gallery/docs/doc_specimen_resolver.dart';
export 'src/gallery/docs/doc_view.dart';
export 'src/gallery/docs/doc_vocabulary.dart';
export 'src/gallery/gallery_app.dart';
export 'src/gallery/gallery_entry.dart';
export 'src/gallery/gallery_index.dart';
export 'src/gallery/gallery_page.dart';
export 'src/gallery/gallery_specimen.dart';
export 'src/gallery/gallery_theme_scope.dart';
export 'src/gallery/gallery_theme_switcher.dart';
export 'src/foundations/icon.dart';
export 'src/foundations/icon_mirror.dart';
export 'src/foundations/text.dart';
export 'src/foundations/text_gallery.dart';
export 'src/interaction/inert.dart';
export 'src/tokens/dabbler_layout.dart';
export 'src/tokens/dabbler_app_roles_gallery.dart';
export 'src/foundations/sport_background.dart';
export 'src/foundations/sport_icon.dart';
export 'src/foundations/sports.dart';
export 'src/foundations/foundations_gallery.dart';
export 'src/foundations/vibes.dart';
export 'src/foundations/vibes_gallery.dart';
export 'src/interaction/focus_ring.dart';
export 'src/interaction/press_scale.dart';
export 'src/interaction/scrim.dart';
export 'src/interaction/swipe_action.dart';
export 'src/interaction/swipe_action_gallery.dart';
export 'src/interaction/interaction_gallery.dart';
export 'src/layout/accordion.dart';
export 'src/layout/accordion_gallery.dart';
export 'src/layout/divider.dart';
export 'src/layout/divider_gallery.dart';
export 'src/layout/fade.dart';
export 'src/layout/fade_gallery.dart';
export 'src/layout/section.dart';
export 'src/layout/key_value_row.dart';
export 'src/layout/key_value_row_gallery.dart';
export 'src/cards/transaction_row.dart';
export 'src/cards/transaction_row_gallery.dart';
export 'src/feedback/progress_card.dart';
export 'src/feedback/progress_card_gallery.dart';
export 'src/layout/shell_gallery.dart';
export 'src/layout/section_gallery.dart';
export 'src/layout/tabs.dart';
export 'src/layout/tabs_label_fit.dart';
export 'src/layout/tabs_gallery.dart';
export 'src/layout/page.dart';
export 'src/layout/detail_header.dart';
export 'src/layout/detail_page.dart';
export 'src/layout/detail_gallery.dart';
export 'src/layout/flow_page.dart';
export 'src/layout/tile_grid.dart';
export 'src/layout/flow_gallery.dart';
export 'src/layout/refresh.dart';
export 'src/layout/refresh_gallery.dart';
export 'src/layout/tab_pager.dart';
export 'src/navigation/top_bar_unread_gallery.dart';
export 'src/surfaces/avatar_image_gallery.dart';
export 'src/navigation/bottom_bar.dart';
export 'src/navigation/action_bar.dart';
export 'src/navigation/tab_bar.dart';
export 'src/navigation/tab_bar_gallery.dart';
export 'src/navigation/top_bar.dart';
export 'src/navigation/page_dots.dart';
export 'src/navigation/page_header.dart';
export 'src/navigation/page_header_gallery.dart';
export 'src/navigation/step_progress.dart';
export 'src/navigation/step_progress_gallery.dart';
export 'src/messaging/chat_composer.dart';
export 'src/messaging/chat_composer_gallery.dart';
export 'src/messaging/conversation_context.dart';
export 'src/messaging/conversation_context_gallery.dart';
export 'src/messaging/conversation_header.dart';
export 'src/messaging/conversation_header_gallery.dart';
export 'src/messaging/conversation_row.dart';
export 'src/messaging/conversation_row_gallery.dart';
export 'src/messaging/message.dart';
export 'src/messaging/message_thread.dart';
export 'src/messaging/message_thread_gallery.dart';
export 'src/messaging/messaging_atoms.dart';
export 'src/messaging/messaging_atoms_gallery.dart';
export 'src/messaging/messaging_auto_direction.dart';
export 'src/messaging/messaging_foundations.dart';
export 'src/messaging/messaging_parts.dart';
export 'src/messaging/messaging_parts_gallery.dart';
export 'src/messaging/messaging_shared_object_card.dart';
export 'src/navigation/navigation_gallery.dart';
export 'src/rooms/mini_player.dart';
export 'src/rooms/rooms_gallery.dart';
export 'src/rooms/speaker_grid.dart';
export 'src/overlays/dialog.dart';
export 'src/overlays/dialog_gallery.dart';
export 'src/overlays/menu.dart';
export 'src/overlays/menu_gallery.dart';
export 'src/overlays/sheet.dart';
export 'src/overlays/sheet_gallery.dart';
export 'src/overlays/sheet_list.dart';
export 'src/overlays/sort_control.dart';
export 'src/overlays/sort_control_gallery.dart';
export 'src/overlays/tooltip.dart';
export 'src/overlays/tooltip_gallery.dart';
export 'src/surfaces/avatar.dart';
export 'src/surfaces/avatar_gallery.dart';
export 'src/surfaces/badge.dart';
export 'src/surfaces/badge_gallery.dart';
export 'src/surfaces/icon_tile.dart';
export 'src/surfaces/icon_tile_gallery.dart';
export 'src/surfaces/hero_icon.dart';
export 'src/surfaces/hero_icon_gallery.dart';
export 'src/surfaces/rating.dart';
export 'src/surfaces/rating_gallery.dart';
export 'src/surfaces/surface.dart';
export 'src/surfaces/surface_gallery.dart';
export 'src/tokens/dabbler_colors.dart';
export 'src/tokens/dabbler_colors_gallery.dart';
export 'src/tokens/dabbler_dark_provisional.dart';
export 'src/tokens/dabbler_direction_gallery.dart';
export 'src/tokens/dabbler_geometry.dart';
export 'src/tokens/dabbler_geometry_gallery.dart';
export 'src/tokens/dabbler_hue_tone.dart';
export 'src/tokens/dabbler_motion.dart';
export 'src/tokens/dabbler_motion_gallery.dart';
export 'src/tokens/dabbler_neutral_status.dart';
export 'src/tokens/dabbler_palette.dart';
export 'src/tokens/dabbler_scrim.dart';
export 'src/tokens/dabbler_status_pairs.dart';
export 'src/tokens/dabbler_themes_gallery.dart';
export 'src/tokens/dabbler_type.dart';
export 'src/tokens/dabbler_type_gallery.dart';
