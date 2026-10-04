import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_layout.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';
import 'spinner.dart';

/// Where one stage of a staged process stands.
enum DabblerStageStatus {
  /// Not started: a small grey dot, faded label.
  pending,

  /// Running now: a spinner, semibold label.
  active,

  /// Finished: a bold success tick.
  done,

  /// Stopped with an error: a bold danger glyph in the error colour.
  failed,
}

/// One stage of [DabblerProgressStages].
@immutable
class DabblerProgressStage {
  /// A stage with its [label] and [status].
  const DabblerProgressStage({
    required this.label,
    this.status = DabblerStageStatus.pending,
  });

  /// The already-localised label.
  final String label;

  /// Where the stage stands.
  final DabblerStageStatus status;
}

/// ProgressStages — the list of named stages under a progress bar while an
/// account (or anything else with several writes) is being set up.
///
/// Transcribed from the "Setup progress" frame of
/// `Auth and Onboarding.dc.html:456-492` (`setupStages`, `:2076-2093`). Each
/// row is a 24px glyph box and a 16px label, `gap:12px`, with `gap:15px`
/// between rows:
///
/// | status | glyph | label | row |
/// |---|---|---|---|
/// | [DabblerStageStatus.pending] | a 9px dot in `--outline-strong` | `--muted`, weight 400 | opacity 0.45 |
/// | [DabblerStageStatus.active] | a small [DabblerSpinner] | `--ink`, weight 600 | opacity 1 |
/// | [DabblerStageStatus.done] | `tick-circle` bold, success | `--ink`, weight 400 | opacity 1 |
/// | [DabblerStageStatus.failed] | `danger` bold, error | `--ink`, weight 600 | opacity 1 |
///
/// ```dart
/// DabblerProgressStages(stages: [
///   DabblerProgressStage(label: 'Creating your profile', status: DabblerStageStatus.done),
///   DabblerProgressStage(label: 'Setting up your sports', status: DabblerStageStatus.active),
///   DabblerProgressStage(label: 'Getting your feed ready'),
/// ])
/// ```
///
/// **Deviation:** the source's 22px tick is [DabblerSizing.iconRow] (21), the
/// nearest step. The opacity change animates over [DabblerMotion.base] unless
/// motion is reduced (`transition: opacity 200ms`, `:473`).
///
/// ## Accessibility
///
/// Each row is one node, labelled by its text; the active stage is announced
/// as in progress through the spinner's own semantics.
///
/// ## RTL
///
/// The glyph sits at the inline start of each row.
class DabblerProgressStages extends StatelessWidget {
  /// Creates the stage list.
  const DabblerProgressStages({super.key, required this.stages});

  /// The stages, top to bottom.
  final List<DabblerProgressStage> stages;

  /// The opacity of a pending stage, `0.45`.
  static const double pendingOpacity = 0.45;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < stages.length; i++) ...<Widget>[
          if (i > 0) const DabblerGap.v(DabblerSpacing.space5),
          _StageRow(stage: stages[i]),
        ],
      ],
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({required this.stage});

  final DabblerProgressStage stage;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final DabblerStageStatus status = stage.status;

    final Widget glyph = switch (status) {
      DabblerStageStatus.done => DabblerIcon(
        'tick-circle',
        weight: DabblerIconWeight.bold,
        size: DabblerSizing.iconRow,
        color: colors.success.strong,
      ),
      DabblerStageStatus.active => const DabblerSpinner(
        size: DabblerSpinnerSize.sm,
      ),
      DabblerStageStatus.failed => DabblerIcon(
        'danger',
        weight: DabblerIconWeight.bold,
        size: DabblerSizing.iconRow,
        color: colors.error.strong,
      ),
      DabblerStageStatus.pending => DabblerSurface(
        width: DabblerSizing.dot,
        height: DabblerSizing.dot,
        radius: DabblerRadius.pill,
        fill: colors.borderStrong,
        borderWidth: 0,
      ),
    };

    final bool pending = status == DabblerStageStatus.pending;
    final bool emphasised =
        status == DabblerStageStatus.active ||
        status == DabblerStageStatus.failed;

    return Semantics(
      container: true,
      label: stage.label,
      child: ExcludeSemantics(
        child: AnimatedOpacity(
          opacity: pending ? DabblerProgressStages.pendingOpacity : 1,
          duration: DabblerMotion.reduceMotion(context)
              ? Duration.zero
              : DabblerMotion.base,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: DabblerSizing.iconMd,
                height: DabblerSizing.iconMd,
                child: Center(child: glyph),
              ),
              const DabblerGap.h(DabblerSpacing.space4),
              Expanded(
                child: Text(
                  stage.label,
                  style: DabblerType.body
                      .resolveForDirection(direction)
                      .copyWith(
                        color: pending
                            ? colors.textTertiary
                            : colors.textPrimary,
                        fontWeight: emphasised
                            ? DabblerType.semibold
                            : DabblerType.regular,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
