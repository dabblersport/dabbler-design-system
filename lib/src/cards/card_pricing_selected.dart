/// `CardPricingSelected` — **a state, not a component.**
///
/// The Figma kit ships `Card/Pricing/Default` (`8:39`) and
/// `Card/Pricing/Selected` (`8:40`) as two symbols. KAN-249 AC1 rules that the
/// second is *"a visual state derived from `CardPricingDefault` — same pattern,
/// same file"*, and the two JSX dumps bear that out: identical tree, identical
/// text slots, identical trial pill, differing only in the shell they are drawn
/// on and in how the selection indicator is painted.
///
/// So there is **no `DabblerCardPricingSelected` widget** and this file
/// declares nothing of its own. It exists only because KAN-249's `Surfaces:`
/// line names the path, and it re-exports the one widget so that an import of
/// either path resolves:
///
/// ```dart
/// const DabblerCardPricing(plan: 'monthly', price: r'$5.99/mo');
/// const DabblerCardPricing(
///   plan: 'yearly',
///   price: r'$59.99/yr',
///   selected: true,
/// );
/// ```
///
/// Note that the kit's two symbol names are inverted with respect to what they
/// paint — the symbol called `Selected` draws the *unselected* tile. `cxo`
/// ruling **D-019** keeps that inversion out of the Dart enum, whose two values
/// are named by what they draw. The reasoning, the evidence and the
/// consequence for `DabblerCardVariant.pricingSelected` /
/// `DabblerCardVariant.pricingUnselected` are recorded in full on
/// [DabblerCardPricing]; they are not restated here, because a second copy of
/// that argument is exactly the drift AC1 is guarding against.
library;

export 'card_pricing_default.dart' show DabblerCardPricing;
