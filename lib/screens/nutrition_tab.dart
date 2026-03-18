import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lift_lab/models/user_model.dart';
import 'package:lift_lab/services/auth_service.dart';
import 'package:lift_lab/services/database_service.dart';
import 'package:lift_lab/services/groq_nutrition_service.dart';
import 'package:lift_lab/services/haptics_service.dart';
import 'package:lift_lab/widgets/app_widgets.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _orangePrimary   = Color(0xFFFF7A00);
const _orangeSecondary = Color(0xFFFF9D42);
const _blue            = Color(0xFF4FC3F7);
const _amber           = Color(0xFFFFB74D);
const _red             = Color(0xFFFF6B6B);
const _bgWhite         = Color(0xFFFFFFFF);
const _textDark        = Color(0xFF1A1A1A);

const _orangeGradient = LinearGradient(
  colors: [_orangePrimary, _orangeSecondary],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class NutritionTab extends StatefulWidget {
  const NutritionTab({super.key, required this.profile});
  final UserModel? profile;

  @override
  State<NutritionTab> createState() => _NutritionTabState();
}

class _NutritionTabState extends State<NutritionTab>
    with TickerProviderStateMixin {
  final _auth = AuthService();
  final _db   = DatabaseService();

  XFile? _image;
  bool   _scanning = false;

  late final AnimationController _rippleCtrl;

  @override
  void initState() {
    super.initState();
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _rippleCtrl.dispose();
    super.dispose();
  }

  // ── image picking ──────────────────────────────────────────────────────────
  Future<void> _pick(ImageSource src) async {
    final picker = ImagePicker();
    final photo  = await picker.pickImage(source: src, imageQuality: 80);
    if (photo == null || !mounted) return;
    setState(() { _image = photo; _scanning = true; });
    
    // Add toast to eliminate "awkward silence"
    if (mounted) showBottomToast(context, '🔬 AI is analyzing your nutrients...');

    try {
      final result = await GroqNutritionService.scanFood(photo);
      if (!mounted) return;
      HapticsService.success();
      _showResultSheet(result);
    } catch (e) {
      if (!mounted) return;
      HapticsService.error();
      showBottomToast(context, 'Could not analyse image — try again', isError: true);
      setState(() => _image = null);
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  // ── log meal ───────────────────────────────────────────────────────────────
  void _logMeal(Map<String, dynamic> r) {
    final user = _auth.currentUser;
    if (user == null) return;

    // ⚡ Optimistic UI Update: Show success immediately
    HapticsService.success();
    if (mounted) {
      showBottomToast(context, '🍏 Fueling Up — Nutrients Logged!', isSuccess: true);
      setState(() => _image = null);
    }

    // 🔬 Background Database Sync (with 5s safety timeout)
    try {
      _db.logNutritionEntry(
        user.uid,
        mealName: r['food_name'] ?? 'Scanned Meal',
        calories: (r['calories'] as num?)?.toInt() ?? 0,
        protein:  (r['protein']  as num?)?.toInt() ?? 0,
        carbs:    (r['carbs']    as num?)?.toInt() ?? 0,
        fats:     (r['fat']      as num?)?.toInt() ?? 0,
      ).timeout(const Duration(seconds: 5)).catchError((e) {
        debugPrint('Background Nutrition Log Error: $e');
        return null;
      });
    } catch (e) {
      debugPrint('Background Nutrition Action Error: $e');
    }
  }

  // ── result sheet ───────────────────────────────────────────────────────────
  void _showResultSheet(Map<String, dynamic> r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _ResultSheet(
        data: r,
        onLog: () {
          Navigator.pop(context);
          _logMeal(r);
        },
        onRetry: () {
          Navigator.pop(context);
          setState(() => _image = null);
        },
      ),
    );
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWhite,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody()),
                _buildBottomBar(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                'Food Scanner',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _textDark, letterSpacing: -0.5),
              ),
              const SizedBox(height: 2),
              Text(
                'Powered by Groq AI',
                style: TextStyle(fontSize: 14, color: _orangePrimary, fontWeight: FontWeight.w700),
              ),
            ]),
          ),
          if (_image != null && !_scanning)
            GestureDetector(
              onTap: () => setState(() => _image = null),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.05),
                ),
                child: const Icon(Icons.close_rounded, color: Colors.black54, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // Scanning state — full image with overlay
    if (_scanning && _image != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(File(_image!.path), fit: BoxFit.cover),
              Container(color: Colors.black.withValues(alpha: 0.65)),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                AnimatedBuilder(
                  animation: _rippleCtrl,
                  builder: (_, __) => Stack(alignment: Alignment.center, children: [
                    ...[60.0, 80.0, 100.0].map((r) {
                      final offset = (r - 60) / 40;
                      final progress = (_rippleCtrl.value - offset * 0.3).clamp(0.0, 1.0); // ignore: unnecessary_underscores
                      return Opacity(
                        opacity: (1 - progress) * 0.6,
                        child: Container(
                          width: r + progress * 40,
                          height: r + progress * 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _orangePrimary, width: 2),
                          ),
                        ),
                      );
                    }),
                    Container(
                      width: 70, height: 70,
                      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: _orangeGradient),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
                    ),
                  ]),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Analysing…',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Groq AI is identifying your food',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 15),
                ),
              ]),
            ],
          ),
        ),
      );
    }

    // Empty state
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated camera ring
          AnimatedBuilder(
            animation: _rippleCtrl,
            builder: (_, __) {
              final pulse = 0.95 + 0.05 * (1 - (_rippleCtrl.value - 0.5).abs() * 2).clamp(0.0, 1.0);
              return Transform.scale(
                scale: pulse,
                child: Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      _orangePrimary.withValues(alpha: 0.15),
                      _orangePrimary.withValues(alpha: 0.02),
                    ]),
                    border: Border.all(color: _orangePrimary.withValues(alpha: 0.3), width: 3),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 60, color: _orangePrimary),
                ),
              );
            },
          ),
          const SizedBox(height: 36),
          const Text(
            'Snap a photo of your food',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _textDark),
          ),
          const SizedBox(height: 12),
          Text(
            'Groq AI will instantly estimate calories,\nprotein, carbs and fat',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
      child: Row(
        children: [
          // Gallery button
          Expanded(
            child: _OutlineBtn(
              icon: Icons.photo_library_rounded,
              label: 'Gallery',
              onTap: _scanning ? null : () => _pick(ImageSource.gallery),
            ),
          ),
          const SizedBox(width: 16),
          // Camera button (primary)
          GestureDetector(
            onTap: _scanning ? null : () => _pick(ImageSource.camera),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _scanning ? null : _orangeGradient,
                color: _scanning ? _orangePrimary.withValues(alpha: 0.4) : null,
                boxShadow: _scanning ? [] : [
                  BoxShadow(color: _orangePrimary.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 4, offset: const Offset(0, 8)),
                ],
              ),
              child: _scanning
                  ? const Padding(
                      padding: EdgeInsets.all(26),
                      child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                    )
                  : const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(width: 16),
          // Balance the row
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

// ─── Result bottom sheet ───────────────────────────────────────────────────────
class _ResultSheet extends StatelessWidget {
  const _ResultSheet({required this.data, required this.onLog, required this.onRetry});
  final Map<String, dynamic> data;
  final VoidCallback onLog, onRetry;

  @override
  Widget build(BuildContext context) {
    final name     = data['food_name']?.toString() ?? 'Food';
    final calories = (data['calories'] as num?)?.toInt() ?? 0;
    final protein  = (data['protein']  as num?)?.toDouble() ?? 0;
    final carbs    = (data['carbs']    as num?)?.toDouble() ?? 0;
    final fat      = (data['fat']      as num?)?.toDouble() ?? 0;

    // calorie contribution per gram: protein=4, carb=4, fat=9
    final pCal = protein * 4;
    final cCal = carbs   * 4;
    final fCal = fat     * 9;
    final tCal = (pCal + cCal + fCal).clamp(1, double.infinity);

    return Container(
      decoration: const BoxDecoration(
        color: _bgWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(26, 12, 26, 26),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44, height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(3)),
                ),
              ),

              // Food name + calories
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                  child: Text(name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _textDark, letterSpacing: -0.5),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('$calories', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: _orangePrimary, height: 1)),
                  const Text('kcal', style: TextStyle(fontSize: 15, color: Colors.black45, fontWeight: FontWeight.w600)),
                ]),
              ]),

              const SizedBox(height: 32),

              // ── Donut chart + macro numbers side by side ──────────────
              Row(
                children: [
                  SizedBox(
                    width: 140, height: 140,
                    child: Stack(
                      children: [
                        PieChart(PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 46,
                          startDegreeOffset: -90,
                          sections: [
                            _section(pCal / tCal, _blue),
                            _section(cCal / tCal, _amber),
                            _section(fCal / tCal, _red),
                          ],
                        )),
                        Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Text('macros', style: TextStyle(color: Colors.black38, fontSize: 11, letterSpacing: 0.5, fontWeight: FontWeight.w600)),
                            Text(
                              '${(pCal / tCal * 100).round()}P',
                              style: const TextStyle(color: _textDark, fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MacroRow2(label: 'Protein', grams: protein.round(), color: _blue,  pct: pCal / tCal),
                        const SizedBox(height: 20),
                        _MacroRow2(label: 'Carbs',   grams: carbs.round(),   color: _amber, pct: cCal / tCal),
                        const SizedBox(height: 20),
                        _MacroRow2(label: 'Fat',     grams: fat.round(),     color: _red,   pct: fCal / tCal),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Segmented macro bar ────────────────────────────────────
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Calorie balance', style: TextStyle(color: Colors.black45, fontSize: 13, letterSpacing: 0.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 16,
                    child: Row(children: [
                      Flexible(flex: (pCal / tCal * 100).round().clamp(1, 100), child: Container(color: _blue)),
                      const SizedBox(width: 3),
                      Flexible(flex: (cCal / tCal * 100).round().clamp(1, 100), child: Container(color: _amber)),
                      const SizedBox(width: 3),
                      Flexible(flex: (fCal / tCal * 100).round().clamp(1, 100), child: Container(color: _red)),
                    ]),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _BarLabel('Protein', _blue),
                    _BarLabel('Carbs',   _amber),
                    _BarLabel('Fat',     _red),
                  ],
                ),
              ]),

              const SizedBox(height: 40),

              // ── CTA buttons ────────────────────────────────────────────
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: _orangeGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: _orangePrimary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: onLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Log Meal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black54,
                    side: const BorderSide(color: Colors.black12, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Scan Again', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PieChartSectionData _section(double pct, Color color) => PieChartSectionData(
    value: pct * 100,
    color: color,
    radius: 32,
    showTitle: false,
  );
}

class _MacroRow2 extends StatelessWidget {
  const _MacroRow2({required this.label, required this.grams, required this.color, required this.pct});
  final String label;
  final int grams;
  final Color color;
  final double pct;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text('${grams}g', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 17)),
      ]),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          minHeight: 6,
          value: pct.clamp(0, 1),
          backgroundColor: Colors.black.withValues(alpha: 0.04),
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    ]);
  }
}

class _BarLabel extends StatelessWidget {
  const _BarLabel(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.w600)),
    ]);
  }
}

class _OutlineBtn extends StatelessWidget {
  const _OutlineBtn({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: onTap == null ? 0.05 : 0.08), width: 2),
          color: Colors.black.withValues(alpha: onTap == null ? 0.02 : 0.0),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 24, color: onTap == null ? Colors.black26 : Colors.black54),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: onTap == null ? Colors.black26 : Colors.black87, fontWeight: FontWeight.w700, fontSize: 16)),
        ]),
      ),
    );
  }
}
