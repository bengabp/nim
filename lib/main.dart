import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _mode = ThemeMode.system;

  void setThemeMode(ThemeMode mode) {
    setState(() => _mode = mode);
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFF7A00);
    const black = Color(0xFF000000);
    const white = Color(0xFFFFFFFF);

    final darkScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: orange,
      onPrimary: Colors.black,
      secondary: Colors.orangeAccent,
      onSecondary: Colors.black,
      error: Colors.redAccent,
      onError: Colors.white,
      surface: black,
      onSurface: Colors.white,
    );

    final lightScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: orange,
      onPrimary: Colors.black,
      secondary: Colors.orange,
      onSecondary: Colors.black,
      error: Colors.red,
      onError: Colors.white,
      surface: white,
      onSurface: Colors.black,
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: black,
      canvasColor: black,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.black, foregroundColor: Colors.white),
      textTheme: GoogleFonts.fredokaTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ).apply(bodyColor: Colors.white, displayColor: Colors.white),
      listTileTheme: const ListTileThemeData(iconColor: Colors.orange, textColor: Colors.white),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(backgroundColor: orange, foregroundColor: Colors.black),
      ),
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: lightScheme,
      scaffoldBackgroundColor: white,
      canvasColor: white,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black),
      textTheme: GoogleFonts.fredokaTextTheme(
        ThemeData(brightness: Brightness.light).textTheme,
      ).apply(bodyColor: Colors.black, displayColor: Colors.black),
      listTileTheme: const ListTileThemeData(iconColor: Colors.orange, textColor: Colors.black),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(backgroundColor: orange, foregroundColor: Colors.black),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nim Lessons',
      themeMode: _mode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const LessonsPage(),
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final List<String> audioUrls; // remote audios
  final List<String> audioPaths; // local audios
  final String? videoPath; // local video
  final int sizeBytes; // total asset size
  final DateTime modifiedAt;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    this.audioUrls = const [],
    this.audioPaths = const [],
    this.videoPath,
    required this.sizeBytes,
    required this.modifiedAt,
  });
}

// Simple model for an audio track (local or remote)
class _Track {
  final String name;   // display name (usually basename)
  final bool isLocal;  // true if source is a local file path
  final String source; // file path or URL

  const _Track({
    required this.name,
    required this.isLocal,
    required this.source,
  });
}

class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  late List<Lesson> lessons;

  @override
  void initState() {
    super.initState();
    lessons = _seedLessons();
  }

  List<Lesson> _seedLessons() {
    final now = DateTime.now();
    const lorem =
        'Nim is a modern systems programming language that aims to combine the raw execution speed, low-level memory access, and fine-grained control traditionally associated with languages like C and C++, while at the same time offering the expressive power, readability, and developer-friendly syntax that programmers have come to appreciate in Python. It was designed with the philosophy that software should be both efficient and pleasant to write: the compiler translates Nim code into highly optimized C, C++, or even JavaScript, enabling it to run virtually anywhere while producing small, fast executables with minimal runtime overhead.'
        'Unlike many system languages that prioritize performance at the cost of ergonomics, Nim provides features like powerful macros, meta-programming capabilities, and a rich standard library, which make it flexible enough for rapid prototyping yet robust enough for large, complex applications. Its strong static type system prevents common bugs, but thanks to type inference and elegant syntax, code feels concise and expressive rather than verbose. Memory management in Nim is also versatile: developers can rely on automatic garbage collection when convenience is needed, or take manual control for performance-critical scenarios, making it particularly attractive for domains like embedded systems, operating system kernels, scientific computing, and high-performance servers.'
        '\n\nIn practice, this means that a developer can write code that looks and feels almost like Python—clean, readable, and easy to reason about—yet compiles down to something with the speed and efficiency of C. This unique balance allows Nim to bridge the gap between productivity and performance, making it a compelling choice for engineers who want the best of both worlds: the safety and abstraction of a high-level language, and the raw power and portability of low-level system programming.'
        'In this lesson, we explore the core ideas behind Nim: a fast compiler, strong typing with type inference, and a modern macro system.'
        'We will also look at the Nimble package manager and community practices.\n\n'
        'By the end, you will understand why Nim can be a great choice for performance-critical applications and elegant scripting alike.';
    return [
      Lesson(
        id: 'l1',
        title: 'Introduction to Nim',
        description: lorem,
        audioUrls: const ['https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'],
        audioPaths: const [],
        videoPath: null,
        sizeBytes: 3 * 1024 * 1024,
        modifiedAt: now.subtract(const Duration(days: 2, hours: 3)),
      ),
      Lesson(
        id: 'l2',
        title: 'Variables and Types',
        description: lorem,
        audioUrls: const ['https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'],
        audioPaths: const [],
        videoPath: null,
        sizeBytes: 5 * 1024 * 1024,
        modifiedAt: now.subtract(const Duration(days: 1, hours: 5)),
      ),
      Lesson(
        id: 'l3',
        title: 'Control Flow',
        description: lorem,
        audioUrls: const [],
        audioPaths: const [],
        videoPath: null,
        sizeBytes: 1 * 1024 * 1024,
        modifiedAt: now.subtract(const Duration(hours: 12)),
      ),
    ];
  }

  String _fmtSizeMB(int bytes) {
    if (bytes <= 0) return '0 MB';
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(mb >= 10 ? 0 : 1)} MB';
  }

  String _fmtDate(DateTime dt) {
    final d = dt.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  Future<void> _addLesson() async {
    final result = await Navigator.of(context).push<Lesson>(
      MaterialPageRoute(builder: (_) => const AddLessonPage()),
    );
    if (result != null) {
      setState(() => lessons.insert(0, result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson added')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        toolbarHeight: 72,
        title: Row(
          children: [
            Text(
              'Lessons',
              style: GoogleFonts.fredoka(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
            ),
            const Spacer(),
            const _ThemeToggle(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addLesson,
        backgroundColor: colors.primary,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        itemCount: lessons.length,
        separatorBuilder: (_, __) => Divider(color: colors.onSurface.withOpacity(0.12), height: 1),
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return Dismissible(
            key: ValueKey(lesson.id),
            background: Container(
              color: Colors.redAccent,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.redAccent,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (_) async {
              final result = await showDialog<bool>(
                context: context,
                builder: (ctx) {
                  final cs = Theme.of(ctx).colorScheme;
                  return AlertDialog(
                    title: const Text('Delete lesson?'),
                    content: Text(
                      'Are you sure you want to delete "${lesson.title}"? You can undo right after deleting.',
                      style: TextStyle(color: cs.onSurface.withOpacity(0.8)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
              return result ?? false;
            },
            onDismissed: (_) {
              final removed = lesson;
              setState(() => lessons.removeAt(index));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted "${removed.title}"'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () => setState(() => lessons.insert(index, removed)),
                  ),
                ),
              );
            },
            child: ListTile(
              title: Text(
                lesson.title,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Updated: ${_fmtDate(lesson.modifiedAt)} • ${_fmtSizeMB(lesson.sizeBytes)}',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
              trailing: Icon(Icons.chevron_right, color: colors.primary),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => LessonDetailPage(lesson: lesson)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class LessonDetailPage extends StatefulWidget {
  final Lesson lesson;
  const LessonDetailPage({super.key, required this.lesson});

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  final AudioPlayer _player = AudioPlayer();
  PlayerState _state = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _seeking = false;
  final _scrollController = ScrollController();
  int _currentTrack = 0;
  bool _hasSetInitialSource = false;
  bool _isLoading = false;

  List<_Track> get _tracks {
    final urls = widget.lesson.audioUrls.map((u) => _Track(name: _basename(u), isLocal: false, source: u)).toList();
    final paths = widget.lesson.audioPaths.map((p) => _Track(name: _basename(p), isLocal: true, source: p)).toList();
    return [...paths, ...urls]; // prefer local first
  }

  String _basename(String s) {
    final ix = s.lastIndexOf('/');
    if (ix >= 0 && ix + 1 < s.length) return s.substring(ix + 1);
    return s;
  }

  Future<void> _seekRelative(Duration delta) async {
    final current = _position;
    final targetMs = (current + delta).inMilliseconds.clamp(0, _duration.inMilliseconds);
    final target = Duration(milliseconds: targetMs);
    await _player.seek(target);
    if (mounted) setState(() => _position = target);
  }

  Future<void> _togglePlay() async {
    final tracks = _tracks;
    if (tracks.isEmpty) return;
    if (!_hasSetInitialSource) {
      await _setSourceForTrack(_currentTrack);
    }
    if (_state == PlayerState.playing) {
      await _player.pause();
    } else if (_state == PlayerState.paused) {
      await _player.resume();
    } else if (_state == PlayerState.completed) {
      await _player.seek(Duration.zero);
      await _player.resume();
    } else {
      await _player.resume();
    }
  }

  Future<void> _setSourceForTrack(int index) async {
    final tracks = _tracks;
    if (index < 0 || index >= tracks.length) return;
    final t = tracks[index];
    await _player.stop();
    if (!t.isLocal) setState(() => _isLoading = true);
    if (t.isLocal) {
      await _player.setSource(DeviceFileSource(t.source));
    } else {
      await _player.setSource(UrlSource(t.source));
    }
    setState(() {
      _currentTrack = index;
      _position = Duration.zero;
      _hasSetInitialSource = true;
    });
  }

  Future<void> _playNext() async {
    final tracks = _tracks;
    if (tracks.isEmpty) return;
    final next = (_currentTrack + 1) % tracks.length;
    await _setSourceForTrack(next);
    await _player.resume();
  }

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() => _state = s);
    });
    _player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() {
        _duration = d;
        _isLoading = false;
      });
    });
    _player.onPositionChanged.listen((p) {
      if (!mounted || _seeking) return;
      setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _state = PlayerState.completed;
        _position = _duration;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tracks = _tracks;
    final hasAudio = tracks.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Stack(
        children: [
          // Subtle blur strip below the app bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(height: 8, color: Colors.transparent),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title removed here to avoid duplication (kept only in AppBar)
                Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    widget.lesson.description,
                    style: TextStyle(fontSize: 16, height: 1.35, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.95)),
                  ),
                ),
              ),
            ),
              ],
            ),
          ),

          // Floating media panel with glass effect
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _MediaPanel(
              isLoading: _isLoading,
              isPlaying: _state == PlayerState.playing,
              onTogglePlay: hasAudio ? _togglePlay : null,
              onBack: hasAudio ? () => _seekRelative(const Duration(seconds: -5)) : null,
              onForward: hasAudio ? () => _seekRelative(const Duration(seconds: 5)) : null,
              onNext: hasAudio ? _playNext : null,
              title: hasAudio ? tracks[_currentTrack].name : 'No audio available',
              duration: _duration,
              position: _position,
              onSeekChanged: (v) {
                setState(() {
                  _seeking = true;
                  _position = Duration(milliseconds: v.round());
                });
              },
              onSeekEnd: (v) async {
                final pos = Duration(milliseconds: v.round());
                await _player.seek(pos);
                setState(() => _seeking = false);
              },
              tracks: tracks,
              currentIndex: _currentTrack,
              onSelectTrack: (i) async {
                await _setSourceForTrack(i);
                await _player.resume();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SeekBar extends StatelessWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const _SeekBar({
    required this.duration,
    required this.position,
    required this.onChanged,
    required this.onChangeEnd,
  });

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh = d.inHours;
    return hh > 0 ? '$hh:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final maxMs = duration.inMilliseconds.clamp(0, 1 << 31).toDouble();
    final targetMs = position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble();
    final onColor = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          tween: Tween<double>(begin: targetMs, end: targetMs),
          builder: (context, animatedMs, _) {
            return SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                activeTrackColor: onColor,
                inactiveTrackColor: onColor.withOpacity(0.25),
                thumbColor: onColor,
                overlayShape: SliderComponentShape.noOverlay,
                thumbShape: const _BarSliderThumbShape(),
              ),
              child: Slider(
                min: 0,
                max: maxMs <= 0 ? 1 : maxMs,
                value: maxMs <= 0 ? 0 : animatedMs.clamp(0, maxMs),
                onChanged: onChanged,
                onChangeEnd: onChangeEnd,
              ),
            );
          },
        ),
        Row(
          children: [
            Text(_fmt(Duration(milliseconds: targetMs.round())), style: TextStyle(color: textColor, fontSize: 12)),
            const Spacer(),
            Text(_fmt(duration), style: TextStyle(color: textColor, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

// A slim vertical bar thumb, similar to the screenshot
class _BarSliderThumbShape extends SliderComponentShape {
  const _BarSliderThumbShape();

  static const double _width = 6.0;
  static const double _height = 18.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(_width, _height);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()..color = sliderTheme.thumbColor ?? Colors.white;
    final Rect rect = Rect.fromCenter(center: center, width: _width, height: _height);
    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));
    canvas.drawRRect(rrect, paint);
  }
}

// Waveform-like seek bar with progress fill and time labels
class _WaveSeekBar extends StatelessWidget {
  final Duration duration;
  final Duration position;
  final String seed;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const _WaveSeekBar({
    required this.duration,
    required this.position,
    required this.seed,
    required this.onChanged,
    required this.onChangeEnd,
  });

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh = d.inHours;
    return hh > 0 ? '$hh:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final onColor = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    final maxMs = duration.inMilliseconds;
    final posMs = position.inMilliseconds.clamp(0, maxMs);
    final ratio = maxMs == 0 ? 0.0 : posMs / maxMs;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (d) {
                final localX = d.localPosition.dx.clamp(0.0, c.maxWidth);
                final r = c.maxWidth == 0 ? 0.0 : localX / c.maxWidth;
                onChanged((r * maxMs).toDouble());
              },
              onHorizontalDragEnd: (_) => onChangeEnd(posMs.toDouble()),
              onTapDown: (d) {
                final localX = d.localPosition.dx.clamp(0.0, c.maxWidth);
                final r = c.maxWidth == 0 ? 0.0 : localX / c.maxWidth;
                onChangeEnd((r * maxMs).toDouble());
              },
              child: CustomPaint(
                size: Size(c.maxWidth, 36),
                painter: _WaveformPainter(
                  ratio: ratio,
                  seed: seed,
                  active: onColor,
                  inactive: onColor.withOpacity(0.25),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(_fmt(Duration(milliseconds: posMs)), style: TextStyle(color: textColor, fontSize: 12)),
            const Spacer(),
            Text('-${_fmt(duration - Duration(milliseconds: posMs))}', style: TextStyle(color: textColor, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double ratio; // 0..1
  final String seed;
  final Color active;
  final Color inactive;

  _WaveformPainter({required this.ratio, required this.seed, required this.active, required this.inactive});

  List<double> _generateHeights(int n) {
    // Deterministic pseudo randomness from seed
    int h = 0;
    for (final c in seed.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    final heights = List<double>.generate(n, (i) {
      h = (h * 1664525 + 1013904223) & 0xffffffff;
      final v = ((h >> 16) & 0xffff) / 0xffff; // 0..1
      return 0.25 + 0.75 * v; // 0.25..1.0 of max height
    });
    return heights;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bars = (size.width / 4).floor(); // 2px bar + 2px gap
    final heights = _generateHeights(bars);
    final maxH = size.height - 4;
    final activePaint = Paint()..color = active;
    final inactivePaint = Paint()..color = inactive;
    final activeBars = (bars * ratio).clamp(0, bars).floor();
    double x = 0;
    for (int i = 0; i < bars; i++) {
      final h = heights[i] * maxH;
      final y = (size.height - h) / 2;
      final paint = i <= activeBars ? activePaint : inactivePaint;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 2, h), const Radius.circular(1)),
        paint,
      );
      x += 4; // bar + gap
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.ratio != ratio ||
        oldDelegate.seed != seed ||
        oldDelegate.active != active ||
        oldDelegate.inactive != inactive;
  }
}

class _ThemeToggle extends StatefulWidget {
  const _ThemeToggle();

  @override
  State<_ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<_ThemeToggle> {
  @override
  Widget build(BuildContext context) {
    final app = MyApp.of(context)!;
    final mode = app._mode;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = Theme.of(context).colorScheme.surface.withOpacity(0.2);

    final int index = mode == ThemeMode.dark ? 1 : 0; // two options: Default(System)=0, Dark=1
    final inactive = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: SizedBox(
        width: 100,
        height: 35,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primary.withOpacity(0.3)),
              ),
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: [Alignment.centerLeft, Alignment.centerRight][index],
              child: Container(
                width: 48,
                height: 28,
                decoration: BoxDecoration(color: primary.withOpacity(0.25), borderRadius: BorderRadius.circular(14)),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // mainAxisSize: MainAxisSize.max,
                children: [
                  IconButton(
                    tooltip: 'Auto',
                    onPressed: () => setState(() => app.setThemeMode(ThemeMode.system)),
                    icon: Icon(Icons.brightness_auto, color: index == 0 ? primary : inactive),
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    // constraints: const BoxConstraints(minHeight: 28, minWidth: 34),
                  ),
                  IconButton(
                    tooltip: 'Dark',
                    onPressed: () => setState(() => app.setThemeMode(ThemeMode.dark)),
                    icon: Icon(Icons.nights_stay_outlined, color: index == 1 ? primary : inactive),
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    // constraints: const BoxConstraints(minHeight: 28, minWidth: 34),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Floating media panel widget with collapse and glass effect
class _MediaPanel extends StatefulWidget {
  final bool isLoading;
  final bool isPlaying;
  final VoidCallback? onTogglePlay;
  final VoidCallback? onBack;
  final VoidCallback? onForward;
  final VoidCallback? onNext;
  final String title;
  final Duration duration;
  final Duration position;
  final ValueChanged<double> onSeekChanged;
  final ValueChanged<double> onSeekEnd;
  final List<_Track> tracks;
  final int currentIndex;
  final ValueChanged<int> onSelectTrack;

  const _MediaPanel({
    required this.isLoading,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.onBack,
    required this.onForward,
    required this.onNext,
    required this.title,
    required this.duration,
    required this.position,
    required this.onSeekChanged,
    required this.onSeekEnd,
    required this.tracks,
    required this.currentIndex,
    required this.onSelectTrack,
  });

  @override
  State<_MediaPanel> createState() => _MediaPanelState();
}

class _MediaPanelState extends State<_MediaPanel> with TickerProviderStateMixin {
  bool _collapsed = false;

  String _ellipsize(String s, int maxChars) {
    if (s.length <= maxChars) return s;
    final head = (maxChars * 0.6).floor();
    final tail = maxChars - head - 1;
    return s.substring(0, head) + '…' + s.substring(s.length - tail);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface.withOpacity(0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.primary.withOpacity(0.25)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (_collapsed) ...[
                      const SizedBox(width: 8),
                      widget.isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                          : IconButton(
                              tooltip: widget.isPlaying ? 'Pause' : 'Play',
                              onPressed: widget.onTogglePlay,
                              icon: Icon(widget.isPlaying ? Icons.pause : Icons.play_arrow),
                              color: colors.primary,
                              iconSize: 22,
                              padding: EdgeInsets.zero,
                            ),
                      IconButton(
                        tooltip: 'Next',
                        onPressed: widget.onNext,
                        icon: const Icon(Icons.skip_next),
                        color: colors.primary,
                        iconSize: 22,
                        padding: EdgeInsets.zero,
                      ),
                    ] else ...[
                      IconButton(
                        tooltip: 'Back 5s',
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.replay_5),
                        color: colors.primary,
                      ),
                      widget.isLoading
                          ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3))
                          : IconButton(
                              tooltip: widget.isPlaying ? 'Pause' : 'Play',
                              onPressed: widget.onTogglePlay,
                              icon: Icon(widget.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                              color: colors.primary,
                            ),
                      IconButton(
                        tooltip: 'Forward 5s',
                        onPressed: widget.onForward,
                        icon: const Icon(Icons.forward_5),
                        color: colors.primary,
                      ),
                    ],
                    IconButton(
                      tooltip: _collapsed ? 'Expand' : 'Collapse',
                      onPressed: () => setState(() => _collapsed = !_collapsed),
                      icon: Icon(_collapsed ? Icons.expand_less : Icons.expand_more, color: colors.primary),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: _collapsed
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _WaveSeekBar(
                              duration: widget.duration,
                              position: widget.position,
                              seed: widget.title,
                              onChanged: widget.onSeekChanged,
                              onChangeEnd: widget.onSeekEnd,
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Controls are now inline with the header row above
                            const SizedBox(height: 8),
                            _WaveSeekBar(
                              duration: widget.duration,
                              position: widget.position,
                              seed: widget.title,
                              onChanged: widget.onSeekChanged,
                              onChangeEnd: widget.onSeekEnd,
                            ),
                            const SizedBox(height: 6),
                            // track pills with wrap (3 per row)
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 120),
                              child: Scrollbar(
                                thumbVisibility: true,
                                child: LayoutBuilder(
                                  builder: (context, cons) {
                                    const spacing = 8.0;
                                    const perRow = 3;
                                    final pillWidth = (cons.maxWidth - spacing * (perRow - 1)) / perRow;
                                    return SingleChildScrollView(
                                      child: Wrap(
                                        spacing: spacing,
                                        runSpacing: spacing,
                                        children: [
                                          for (int i = 0; i < widget.tracks.length; i++)
                                            SizedBox(
                                              width: pillWidth,
                                              child: InkWell(
                                                onTap: () => widget.onSelectTrack(i),
                                                borderRadius: BorderRadius.circular(20),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: i == widget.currentIndex ? colors.primary.withOpacity(0.2) : colors.surface.withOpacity(0.4),
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(color: i == widget.currentIndex ? colors.primary : colors.onSurface.withOpacity(0.15)),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        i == widget.currentIndex ? Icons.equalizer : Icons.audiotrack,
                                                        size: 14,
                                                        color: i == widget.currentIndex ? colors.primary : colors.onSurface.withOpacity(0.6),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          _ellipsize(widget.tracks[i].name, 22),
                                                          style: TextStyle(
                                                            color: colors.onSurface,
                                                            fontSize: 12,
                                                            fontWeight: i == widget.currentIndex ? FontWeight.w700 : FontWeight.w400,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayingVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  const _PlayingVisualizer({required this.isPlaying, required this.color});

  @override
  State<_PlayingVisualizer> createState() => _PlayingVisualizerState();
}

class _PlayingVisualizerState extends State<_PlayingVisualizer> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PlayingVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.isPlaying && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bars = List.generate(4, (i) {
      return AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = _ctrl.value;
          final base = 8.0 + i * 2.0;
          final amp = 16.0 - i * 2.0;
          final phase = i * 0.6;
          final h = base + amp * (widget.isPlaying ? (0.5 + 0.5 * math.sin(t * 2 * math.pi + phase)) : 0.0);
          return Container(
            width: 4,
            height: h,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        },
      );
    });

    return Row(mainAxisSize: MainAxisSize.min, children: bars);
  }
}

class AddLessonPage extends StatefulWidget {
  const AddLessonPage({super.key});

  @override
  State<AddLessonPage> createState() => _AddLessonPageState();
}

class _AddLessonPageState extends State<AddLessonPage> {
  final _titleCtrl = TextEditingController();
  final List<String> _audioPaths = [];
  String? _videoPath;
  int _audioBytes = 0;
  final int _videoBytes = 0;
  bool _converting = false;
  int _convertingDone = 0;
  int _convertingTotal = 0;

  Future<void> _pickAudio() async {
    try {
      // Use Files app with audio extensions, allow multiple selections
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['mp3', 'm4a', 'aac', 'wav', 'flac', 'ogg', 'caf'],
        allowMultiple: true,
        withData: false,
      );
      if (res != null && res.files.isNotEmpty) {
        int bytes = 0;
        final paths = <String>[];
        for (final f in res.files) {
          final p = f.path;
          if (p != null) {
            paths.add(p);
            try {
              bytes += await File(p).length();
            } catch (_) {}
          }
        }
        setState(() {
          _audioPaths
            ..clear()
            ..addAll(paths);
          _audioBytes = bytes;
        });
      }
    } on MissingPluginException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File picker not registered. Please stop the app and rebuild.')),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File pick failed: ${e.code}')),
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      final res = await FilePicker.platform.pickFiles(type: FileType.video, allowMultiple: true, withData: false);
      if (res != null && res.files.isNotEmpty) {
        var vids = res.files.map((f) => f.path).whereType<String>().toList();
        if (vids.length > 3) {
          vids = vids.take(3).toList();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Only the first 3 videos will be converted.')),
            );
          }
        }
        await _convertVideosToAudio(vids);
      }
    } on MissingPluginException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File picker not registered. Please stop the app and rebuild.')),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File pick failed: ${e.code}')),
      );
    }
  }

  Future<void> _convertVideosToAudio(List<String> videoPaths) async {
    if (videoPaths.isEmpty) return;
    setState(() {
      _converting = true;
      _convertingDone = 0;
      _convertingTotal = videoPaths.length;
    });
    final outDir = await getApplicationDocumentsDirectory();
    for (final input in videoPaths) {
      final base = p.basenameWithoutExtension(input);
      // Preserve original video name for the audio file; ensure uniqueness
      String outPath = p.join(outDir.path, '$base.m4a');
      int suffix = 1;
      while (await File(outPath).exists()) {
        outPath = p.join(outDir.path, '${base}_$suffix.m4a');
        suffix++;
      }
      String esc(String s) => "'${s.replaceAll("'", "\\'")}'";
      final cmd = "-y -i ${esc(input)} -vn -acodec aac -b:a 192k ${esc(outPath)}";
      final session = await FFmpegKit.execute(cmd);
      final rc = await session.getReturnCode();
      if (rc != null && rc.isValueSuccess()) {
        int len = 0;
        try { len = await File(outPath).length(); } catch (_) {}
        setState(() {
          _audioPaths.add(outPath);
          _audioBytes += len;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Convert failed for ${p.basename(input)}')),
          );
        }
      }
      if (mounted) setState(() => _convertingDone++);
    }
    if (mounted) setState(() => _converting = false);
  }

  String _fmtSizeMB(int bytes) {
    if (bytes <= 0) return '0 MB';
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(mb >= 10 ? 0 : 1)} MB';
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }
    final total = _audioBytes + _videoBytes;
    final now = DateTime.now();
    final lesson = Lesson(
      id: 'u${now.microsecondsSinceEpoch}',
      title: title,
      description:
          'This is your newly added lesson.\n\nWrite a detailed, kid-friendly description here with multiple paragraphs to explain the topic clearly and engagingly.\n\nYou can attach audio and video to complement the text.',
      audioUrls: const [],
      audioPaths: List.unmodifiable(_audioPaths),
      videoPath: _videoPath,
      sizeBytes: total,
      modifiedAt: now,
    );
    Navigator.of(context).pop(lesson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Lesson'),
        backgroundColor: Colors.black,
        actions: [
          TextButton(onPressed: _converting ? null : _save, child: const Text('Save')),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Lesson Title',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _pickAudio,
                  icon: const Icon(Icons.audiotrack),
                  label: const Text('Pick Audio'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _audioPaths.isEmpty
                        ? 'No audio selected'
                        : '${_audioPaths.length} file(s) • ${_fmtSizeMB(_audioBytes)}',
                    style: const TextStyle(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _pickVideo,
                  icon: const Icon(Icons.videocam),
                  label: const Text('Pick Video'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _converting
                        ? 'Converting videos... ($_convertingDone/$_convertingTotal)'
                        : (_videoPath == null ? 'No video selected' : 'Video: ${_fmtSizeMB(_videoBytes)}'),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (_converting) ...[
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                tween: Tween(begin: 0.0, end: _convertingTotal == 0 ? 0.0 : _convertingDone / _convertingTotal),
                builder: (context, v, _) => LinearProgressIndicator(value: v),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save Lesson'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
