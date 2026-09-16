import 'package:flutter/material.dart';

/// Raw colour primitives for the Dabbler design system.
///
/// Every constant here is a literal hex value declared in the `:root` block of
/// the design source `tokens/colors.css` (version 4.0), transcribed verbatim.
/// The Dart name is the CSS custom-property name in camelCase, and each
/// constant's doc comment records the CSS token it came from.
///
/// This class is a **primitive** layer, not the semantic API. It carries no
/// light/dark or per-theme resolution — that belongs to the semantic token
/// layer built on top of it. Nothing else in `lib/src/` may write a
/// `Color(0x...)` literal; it must reference a constant declared here.
///
/// The seven themes are `main`, `sport`, `social`, `active`, `bright`,
/// `simple` and `shade`. `simple` and `shade` carry no brand ramp of their own
/// — they resolve through the shared [ink50]–[ink950] ramp. That list is
/// exhaustive: any other theme name is not part of this design system.
///
/// The `--glass-*` tokens of `tokens/glass.css` are deliberately not ported.
abstract final class DabblerPalette {
  const DabblerPalette._();

  // --- Ink — shared neutral primitives ---

  /// `--paper` — `#FFFFFF`.
  static const Color paper = Color(0xFFFFFFFF);

  /// `--ink-50` — `#F5F5F7`.
  static const Color ink50 = Color(0xFFF5F5F7);

  /// `--ink-100` — `#ECEBEF`.
  static const Color ink100 = Color(0xFFECEBEF);

  /// `--ink-200` — `#DCDAE2`.
  static const Color ink200 = Color(0xFFDCDAE2);

  /// `--ink-300` — `#C2BFCB`.
  static const Color ink300 = Color(0xFFC2BFCB);

  /// `--ink-400` — `#9C98A8`.
  static const Color ink400 = Color(0xFF9C98A8);

  /// `--ink-500` — `#787484`.
  static const Color ink500 = Color(0xFF787484);

  /// `--ink-600` — `#595663`.
  static const Color ink600 = Color(0xFF595663);

  /// `--ink-700` — `#3E3B47`.
  static const Color ink700 = Color(0xFF3E3B47);

  /// `--ink-800` — `#28252F`.
  static const Color ink800 = Color(0xFF28252F);

  /// `--ink-900` — `#1B1B1B`.
  static const Color ink900 = Color(0xFF1B1B1B);

  /// `--ink-950` — `#171123`.
  static const Color ink950 = Color(0xFF171123);


  // --- Brand ramp — main ---

  /// `--main-p-300` — `#B289E4`.
  static const Color mainP300 = Color(0xFFB289E4);

  /// `--main-p-400` — `#9760DB`.
  static const Color mainP400 = Color(0xFF9760DB);

  /// `--main-p-600` — `#7328CE`.
  static const Color mainP600 = Color(0xFF7328CE);

  /// `--main-p-700` — `#5A1FA1`.
  static const Color mainP700 = Color(0xFF5A1FA1);

  /// `--main-s-400` — `#BC42AC`.
  static const Color mainS400 = Color(0xFFBC42AC);

  /// `--main-s-600` — `#A4008F`.
  static const Color mainS600 = Color(0xFFA4008F);

  /// `--main-s-700` — `#800070`.
  static const Color mainS700 = Color(0xFF800070);


  // --- Brand ramp — social ---

  /// `--social-p-300` — `#8FB2E9`.
  static const Color socialP300 = Color(0xFF8FB2E9);

  /// `--social-p-400` — `#6997E1`.
  static const Color socialP400 = Color(0xFF6997E1);

  /// `--social-p-600` — `#3473D7`.
  static const Color socialP600 = Color(0xFF3473D7);

  /// `--social-p-700` — `#295AA8`.
  static const Color socialP700 = Color(0xFF295AA8);

  /// `--social-s-400` — `#8DBFFF`.
  static const Color socialS400 = Color(0xFF8DBFFF);

  /// `--social-s-600` — `#65A8FF`.
  static const Color socialS600 = Color(0xFF65A8FF);

  /// `--social-s-700` — `#4F83C7`.
  static const Color socialS700 = Color(0xFF4F83C7);


  // --- Brand ramp — sport ---

  /// `--sport-p-300` — `#8FBC92`.
  static const Color sportP300 = Color(0xFF8FBC92);

  /// `--sport-p-400` — `#69A56C`.
  static const Color sportP400 = Color(0xFF69A56C);

  /// `--sport-p-600` — `#348638`.
  static const Color sportP600 = Color(0xFF348638);

  /// `--sport-p-700` — `#29692C`.
  static const Color sportP700 = Color(0xFF29692C);

  /// `--sport-s-400` — `#92CE91`.
  static const Color sportS400 = Color(0xFF92CE91);

  /// `--sport-s-600` — `#6CBD6A`.
  static const Color sportS600 = Color(0xFF6CBD6A);

  /// `--sport-s-700` — `#549353`.
  static const Color sportS700 = Color(0xFF549353);


  // --- Brand ramp — active ---

  /// `--active-p-300` — `#E592BE`.
  static const Color activeP300 = Color(0xFFE592BE);

  /// `--active-p-400` — `#DB6CA8`.
  static const Color activeP400 = Color(0xFFDB6CA8);

  /// `--active-p-600` — `#CF3989`.
  static const Color activeP600 = Color(0xFFCF3989);

  /// `--active-p-700` — `#A12C6B`.
  static const Color activeP700 = Color(0xFFA12C6B);

  /// `--active-s-400` — `#F04285`.
  static const Color activeS400 = Color(0xFFF04285);

  /// `--active-s-600` — `#EB005A`.
  static const Color activeS600 = Color(0xFFEB005A);

  /// `--active-s-700` — `#B70046`.
  static const Color activeS700 = Color(0xFFB70046);


  // --- Brand ramp — bright ---

  /// `--bright-p-300` — `#FAD09E`.
  static const Color brightP300 = Color(0xFFFAD09E);

  /// `--bright-p-400` — `#F8C07D`.
  static const Color brightP400 = Color(0xFFF8C07D);

  /// `--bright-p-600` — `#F6AA4F`.
  static const Color brightP600 = Color(0xFFF6AA4F);

  /// `--bright-p-700` — `#C0853E`.
  static const Color brightP700 = Color(0xFFC0853E);

  /// `--bright-s-400` — `#956C42`.
  static const Color brightS400 = Color(0xFF956C42);

  /// `--bright-s-600` — `#703900`.
  static const Color brightS600 = Color(0xFF703900);

  /// `--bright-s-700` — `#572C00`.
  static const Color brightS700 = Color(0xFF572C00);


  // --- Surface and neutral foundation ---

  /// `--surface-page` — `#F5F0E6`.
  static const Color surfacePage = Color(0xFFF5F0E6);

  /// `--surface-card` — `#FFFFFF`.
  static const Color surfaceCard = Color(0xFFFFFFFF);

  /// `--surface-sunken` — `#F0EBE0`.
  static const Color surfaceSunken = Color(0xFFF0EBE0);

  /// `--surface-grey` — `#F5F5F5`.
  static const Color surfaceGrey = Color(0xFFF5F5F5);

  /// `--outline-card` — `#E0D9CC`.
  static const Color outlineCard = Color(0xFFE0D9CC);

  /// `--outline-strong` — `#C0B8A8`.
  static const Color outlineStrong = Color(0xFFC0B8A8);

  /// `--faint` — `#E8E0CF`.
  static const Color faint = Color(0xFFE8E0CF);

  /// `--subtle` — `#B8B0A0`.
  static const Color subtle = Color(0xFFB8B0A0);

  /// `--muted` — `#8C8C8C`.
  static const Color muted = Color(0xFF8C8C8C);

  /// `--ink` — `#141414`.
  static const Color ink = Color(0xFF141414);

  /// `--ink-soft` — `#404040`.
  static const Color inkSoft = Color(0xFF404040);


  // --- Status ramp ---

  /// `--success-100` — `#DCFCE7`.
  static const Color success100 = Color(0xFFDCFCE7);

  /// `--success-500` — `#22C55E`.
  static const Color success500 = Color(0xFF22C55E);

  /// `--success-700` — `#166534`.
  static const Color success700 = Color(0xFF166534);

  /// `--warning-100` — `#FEF3C7`.
  static const Color warning100 = Color(0xFFFEF3C7);

  /// `--warning-500` — `#F59E0B`.
  static const Color warning500 = Color(0xFFF59E0B);

  /// `--warning-700` — `#92400E`.
  static const Color warning700 = Color(0xFF92400E);

  /// `--error-100` — `#FEE2E2`.
  static const Color error100 = Color(0xFFFEE2E2);

  /// `--error-500` — `#EF4444`.
  static const Color error500 = Color(0xFFEF4444);

  /// `--error-700` — `#991B1B`.
  static const Color error700 = Color(0xFF991B1B);

  /// `--info-100` — `#DBEAFE`.
  static const Color info100 = Color(0xFFDBEAFE);

  /// `--info-500` — `#3B82F6`.
  static const Color info500 = Color(0xFF3B82F6);

  /// `--info-700` — `#1D4ED8`.
  static const Color info700 = Color(0xFF1D4ED8);

  /// `--spotlight-500` — `#FF5A1F`.
  static const Color spotlight500 = Color(0xFFFF5A1F);


  // --- Per-theme status overrides ---

  /// `--sport-success` — `#138A66`.
  static const Color sportSuccess = Color(0xFF138A66);

  /// `--social-info` — `#6366F1`.
  static const Color socialInfo = Color(0xFF6366F1);

  /// `--active-error` — `#E5484D`.
  static const Color activeError = Color(0xFFE5484D);

  /// `--bright-warning` — `#A8420A`.
  static const Color brightWarning = Color(0xFFA8420A);


  // --- Pastel status tags ---

  /// `--tag-pending-surface` — `#FDEDE3`.
  static const Color tagPendingSurface = Color(0xFFFDEDE3);

  /// `--tag-pending-ink` — `#B4530E`.
  static const Color tagPendingInk = Color(0xFFB4530E);

  /// `--tag-progress-surface` — `#DBEAFB`.
  static const Color tagProgressSurface = Color(0xFFDBEAFB);

  /// `--tag-progress-ink` — `#1D5FBF`.
  static const Color tagProgressInk = Color(0xFF1D5FBF);

  /// `--tag-submitted-surface` — `#E9E2FD`.
  static const Color tagSubmittedSurface = Color(0xFFE9E2FD);

  /// `--tag-submitted-ink` — `#6A32D6`.
  static const Color tagSubmittedInk = Color(0xFF6A32D6);

  /// `--tag-review-surface` — `#FBE7C2`.
  static const Color tagReviewSurface = Color(0xFFFBE7C2);

  /// `--tag-review-ink` — `#8A5A12`.
  static const Color tagReviewInk = Color(0xFF8A5A12);

  /// `--tag-success-surface` — `#D6F2DE`.
  static const Color tagSuccessSurface = Color(0xFFD6F2DE);

  /// `--tag-success-ink` — `#1B7A3D`.
  static const Color tagSuccessInk = Color(0xFF1B7A3D);

  /// `--tag-failed-surface` — `#FBE1E1`.
  static const Color tagFailedSurface = Color(0xFFFBE1E1);

  /// `--tag-failed-ink` — `#C0292F`.
  static const Color tagFailedInk = Color(0xFFC0292F);

  /// `--tag-expired-surface` — `#EDEDEF`.
  static const Color tagExpiredSurface = Color(0xFFEDEDEF);

  /// `--tag-expired-ink` — `#5A5A62`.
  static const Color tagExpiredInk = Color(0xFF5A5A62);


  // --- Decorative tile tones ---

  /// `--tile-amber-surface` — `#FFD60A`.
  static const Color tileAmberSurface = Color(0xFFFFD60A);

  /// `--tile-info-surface` — `#DCEAFB`.
  static const Color tileInfoSurface = Color(0xFFDCEAFB);

  /// `--tile-accent-surface` — `#FBE0EC`.
  static const Color tileAccentSurface = Color(0xFFFBE0EC);
}
