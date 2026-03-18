// Shared utilities, helpers, and common widgets used across all tabs.
// Import this file wherever you need _InfoCard, _MetricBlock, etc.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lift_lab/services/haptics_service.dart';

// ─── Color Helpers ────────────────────────────────────────────────────────────

Color navAccent(int index, ColorScheme colors) {
  // Use orange primary for the active tab for consistency
  return colors.primary;
}

Color cardAccent(String title, ColorScheme colors) {
  final key = title.toLowerCase();
  if (key.contains('nutrition') || key.contains('meal') || key.contains('macro')) return colors.primary;
  if (key.contains('train') || key.contains('workout') || key.contains('session')) return const Color(0xFF0F172A);
  if (key.contains('history') || key.contains('recent')) return const Color(0xFF64748B);
  return colors.primary;
}

Color macroAccent(String label, ColorScheme colors) {
  final key = label.toLowerCase();
  if (key.contains('cal')) return colors.primary;
  if (key.contains('protein')) return const Color(0xFF3B82F6);
  if (key.contains('carb')) return const Color(0xFFF59E0B);
  if (key.contains('fat')) return const Color(0xFFEF4444);
  return colors.primary;
}

Color metricAccent(String label, ColorScheme colors) {
  final key = label.toLowerCase();
  if (key.contains('goal')) return colors.primary;
  if (key.contains('streak')) return const Color(0xFFF59E0B);
  if (key.contains('protein')) return const Color(0xFF3B82F6);
  if (key.contains('carb')) return const Color(0xFFF59E0B);
  return colors.primary;
}

// ─── Date/Time Helpers ────────────────────────────────────────────────────────

DateTime? toDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

String fmtDate(DateTime? date) {
  if (date == null) return 'just now';
  final hh = date.hour.toString().padLeft(2, '0');
  final mm = date.minute.toString().padLeft(2, '0');
  return '${date.day}/${date.month} $hh:$mm';
}

String fmtDuration(int seconds) {
  final h = (seconds ~/ 3600).toString().padLeft(2, '0');
  final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

// ─── Toast Helper ─────────────────────────────────────────────────────────────

void showBottomToast(BuildContext context, String message, {bool isError = false, bool isSuccess = false}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  
  Color bg = const Color(0xFF1E293B); // Slate
  if (isError) bg = const Color(0xFFEF4444); // Red
  if (isSuccess) bg = const Color(0xFF10B981); // Emerald Green

  messenger.showSnackBar(
    SnackBar(
      content: Text(
        message, 
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: bg,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 90),
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
    ),
  );
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

/// Animated card used throughout the app for sections like "Macro Progress", "Recent Sessions" etc.
class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.title, required this.child, this.order = 0});
  final String title;
  final Widget child;
  final int order;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = cardAccent(title, colors);
    final revealStart = (order * 0.08).clamp(0.0, 0.55);
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Interval(revealStart, 1.0, curve: Curves.easeOutCubic),
      builder: (context, value, cardChild) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, (1 - value) * 12), child: cardChild),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x0D000000), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 10, height: 10, 
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Text(
                title, 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.2),
              ),
            ]),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

/// A labeled metric block (e.g. "Streak: 5 days") used in the home and history screens.
class MetricBlock extends StatelessWidget {
  const MetricBlock({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = metricAccent(label, colors);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(
              label, 
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            value, 
            maxLines: 1, 
            overflow: TextOverflow.ellipsis, 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }
}

/// A progress row for a macro (Calories, Protein, etc.) with a coloured bar.
class MacroRow extends StatelessWidget {
  const MacroRow({super.key, required this.label, required this.current, required this.target});
  final String label;
  final int current;
  final int target;

  @override
  Widget build(BuildContext context) {
    final clamped = target == 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    final colors = Theme.of(context).colorScheme;
    final accent = macroAccent(label, colors);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            Text(
              '$current / $target', 
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: accent),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: clamped),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              minHeight: 8,
              value: value,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ),
      ]),
    );
  }
}

/// A pill-shaped action button (e.g. "Open Train", "AI Tip") used on the Home tab.
class ActionPill extends StatefulWidget {
  const ActionPill({super.key, required this.icon, required this.text, required this.onTap});
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  State<ActionPill> createState() => _ActionPillState();
}

class _ActionPillState extends State<ActionPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Premium feel: Use the primary orange for AI or special actions
    final primaryAction = widget.text.toLowerCase().contains('ai') || widget.text.toLowerCase().contains('train');
    
    return AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onHighlightChanged: (v) => setState(() => _pressed = v),
        onTap: () { HapticsService.selection(); widget.onTap(); },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: primaryAction ? colors.primary.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
            border: Border.all(
              color: primaryAction ? colors.primary.withValues(alpha: 0.2) : const Color(0x0D000000),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, 
            children: [
              Icon(widget.icon, size: 18, color: primaryAction ? colors.primary : const Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                widget.text, 
                style: TextStyle(
                  fontWeight: FontWeight.w800, 
                  fontSize: 14,
                  color: primaryAction ? colors.primary : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
