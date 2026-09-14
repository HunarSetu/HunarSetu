import 'package:flutter/material.dart';

/// HunarSetu design-token palette — shades of green.
///
/// The green ramps below are the source of truth. The historical role names
/// (`terracotta`, `gold`, `berry`, `blueAccent`) are kept as aliases because
/// they are referenced from ~200 call sites across the app; they now resolve to
/// greens. Prefer the green names in new code.
///
/// Role hierarchy:
///   leaf     → every primary action button
///   olive    → every secondary / alternate-path button
///   teal     → accent only (at most one hero card per screen)
///   pine     → accent only (comparison bars, text-link icons — never a fill)
///   emerald  → dispatched / delivered / confirmed
///   danger   → destructive and genuine error states only
class AppColors {
  // ---------------------------------------------------------------------------
  // Green ramps — source of truth
  // ---------------------------------------------------------------------------

  /// Primary action — deep leaf green.
  static const leaf      = Color(0xFF2F6B45);
  static const leafPress = Color(0xFF1E4A2E);
  static const leafTint  = Color(0xFFD9E8DE);

  /// Secondary action — olive (yellow-green, so it stays legible beside leaf).
  static const olive      = Color(0xFF7C8A33);
  static const olivePress = Color(0xFF5C6725);
  static const oliveTint  = Color(0xFFEDF1DA);

  /// Accent 1 — teal green. Hero metric cards.
  static const teal      = Color(0xFF2C6E63);
  static const tealPress = Color(0xFF1E5049);
  static const tealTint  = Color(0xFFD7E7E3);

  /// Accent 2 — deep pine. Comparison bars, link icons.
  static const pine      = Color(0xFF1F4D53);
  static const pinePress = Color(0xFF143940);
  static const pineTint  = Color(0xFFD6E4E6);

  /// Success — brighter emerald, deliberately separated from [leaf] so a
  /// "delivered" badge never reads as just another primary-coloured chip.
  static const emerald     = Color(0xFF2E9E6B);
  static const emeraldTint = Color(0xFFD6F0E4);

  /// Destructive / genuine errors. The one warm hue kept, so an error is
  /// unmistakable against an otherwise entirely green UI.
  static const danger     = Color(0xFFC0392B);
  static const dangerTint = Color(0xFFF7DDD9);

  // ---------------------------------------------------------------------------
  // Ink — near-black with a cool green cast rather than pure black
  // ---------------------------------------------------------------------------
  static const ink            = Color(0xFF16211B);
  static const inkSoft        = Color(0xFF5A6B60);
  static const inkFaint       = Color(0xFF93A399);

  // ---------------------------------------------------------------------------
  // Surfaces — off-whites tinted green so the page never reads as flat grey
  // ---------------------------------------------------------------------------
  static const parchment      = Color(0xFFF2F7F1); // page background
  static const parchmentDeep  = Color(0xFFDFEADD); // tracks / segmented controls
  static const cardSurface    = Color(0xFFFAFDF9);

  // ---------------------------------------------------------------------------
  // Structural
  // ---------------------------------------------------------------------------
  static const dottedBorder   = Color(0xFFC6D4C5);
  /// Borders, field outlines, card outlines — rgba(22,33,27,0.14)
  static const line           = Color(0x2416211B);
  /// Resting card shadow — rgba(22,33,27,0.08)
  static const shadow         = Color(0x1416211B);
  /// Lifted / sheet shadow — rgba(22,33,27,0.28)
  static const shadowLifted   = Color(0x4716211B);
  static const overlay        = Color(0x6B0E1611);

  // ---------------------------------------------------------------------------
  // Semantic convenience aliases
  // ---------------------------------------------------------------------------
  static const textPrimary    = ink;
  static const textSecondary  = inkSoft;
  static const textTertiary   = inkFaint;
  static const textOnPrimary  = Color(0xFFFFFFFF);

  static const background     = parchment;
  static const surface        = cardSurface;
  static const surfaceVariant = parchmentDeep;

  /// Now a true red. Previously this aliased the primary action colour, which
  /// made a delete button indistinguishable from a confirm button.
  static const error          = danger;
  static const errorLight     = dangerTint;
  static const warning        = olive;
  static const border         = dottedBorder;
  static const divider        = line;

  // ---------------------------------------------------------------------------
  // Status badge roles (order cards + filter chips)
  // ---------------------------------------------------------------------------
  static const statusActionBg   = leafTint;      // "New" / action required
  static const statusActionFg   = leafPress;
  static const statusPendingBg  = oliveTint;     // "Packed" / processing
  static const statusPendingFg  = olivePress;
  static const statusSuccessBg  = emeraldTint;   // Dispatched / delivered
  static const statusSuccessFg  = emerald;

  // ---------------------------------------------------------------------------
  // Legacy role names — every one of these is still referenced across the app.
  // Kept so no screen needs editing; all now resolve to greens.
  // ---------------------------------------------------------------------------
  static const terracotta      = leaf;
  static const terracottaDark  = leafPress;
  static const terracottaLight = leafTint;

  static const gold            = olive;
  static const goldDark        = olivePress;
  static const goldLight       = oliveTint;

  static const berry           = teal;
  static const berryDark       = tealPress;
  static const berryLight      = tealTint;

  static const blueAccent      = pine;
  static const blueAccentDark  = pinePress;
  static const blueAccentLight = pineTint;

  static const success         = emerald;
  static const successLight    = emeraldTint;

  static const plaster         = parchment;
  static const plasterDark     = parchmentDeep;
  static const charcoal        = ink;
  static const charcoalSoft    = inkSoft;
  static const cream           = cardSurface;
  static const oak             = dottedBorder;
  static const mustard         = olive;
  static const brick           = leafPress;
  static const aboveRange      = teal;

  static const online          = emerald;
  static const syncing         = olive;
  static const offline         = inkSoft;

  static const statusLive      = emerald;
  static const statusPending   = olive;
  static const statusDraft     = inkSoft;
  static const statusSold      = olive;

  static const indigo          = leafPress;
  static const indigoLight     = leaf;
  static const indigoDark      = ink;
  static const turmeric        = olive;
  static const turmericLight   = oliveTint;
  static const turmericDark    = olivePress;
  static const forestGreen     = leaf;
  static const forestGreenLight= leafTint;
  static const forestGreenDark = Color(0xFF1B3A25);

  static const info            = pine;

  AppColors._();
}
