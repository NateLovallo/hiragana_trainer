import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const HiraganaTrainerApp());
}

class HiraganaTrainerApp extends StatelessWidget {
  const HiraganaTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hiragana Trainer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HiraganaQuizPage(),
    );
  }
}

class HiraganaQuizPage extends StatefulWidget {
  const HiraganaQuizPage({super.key});

  @override
  State<HiraganaQuizPage> createState() => _HiraganaQuizPageState();
}

class _HiraganaQuizPageState extends State<HiraganaQuizPage> {
  // Basic sets: each list is character -> romaji
  static const List<MapEntry<String, String>> _basicHiragana = [
    MapEntry('あ', 'a'),
    MapEntry('い', 'i'),
    MapEntry('う', 'u'),
    MapEntry('え', 'e'),
    MapEntry('お', 'o'),
    MapEntry('か', 'ka'),
    MapEntry('き', 'ki'),
    MapEntry('く', 'ku'),
    MapEntry('け', 'ke'),
    MapEntry('こ', 'ko'),
    MapEntry('さ', 'sa'),
    MapEntry('し', 'shi'),
    MapEntry('す', 'su'),
    MapEntry('せ', 'se'),
    MapEntry('そ', 'so'),
    MapEntry('た', 'ta'),
    MapEntry('ち', 'chi'),
    MapEntry('つ', 'tsu'),
    MapEntry('て', 'te'),
    MapEntry('と', 'to'),
    MapEntry('な', 'na'),
    MapEntry('に', 'ni'),
    MapEntry('ぬ', 'nu'),
    MapEntry('ね', 'ne'),
    MapEntry('の', 'no'),
    MapEntry('は', 'ha'),
    MapEntry('ひ', 'hi'),
    MapEntry('ふ', 'fu'),
    MapEntry('へ', 'he'),
    MapEntry('ほ', 'ho'),
    MapEntry('ま', 'ma'),
    MapEntry('み', 'mi'),
    MapEntry('む', 'mu'),
    MapEntry('め', 'me'),
    MapEntry('も', 'mo'),
    MapEntry('や', 'ya'),
    MapEntry('ゆ', 'yu'),
    MapEntry('よ', 'yo'),
    MapEntry('ら', 'ra'),
    MapEntry('り', 'ri'),
    MapEntry('る', 'ru'),
    MapEntry('れ', 're'),
    MapEntry('ろ', 'ro'),
    MapEntry('わ', 'wa'),
    MapEntry('を', 'wo'),
    MapEntry('ん', 'n'),
  ];

  static const List<MapEntry<String, String>> _dakuten = [
    MapEntry('が', 'ga'),
    MapEntry('ぎ', 'gi'),
    MapEntry('ぐ', 'gu'),
    MapEntry('げ', 'ge'),
    MapEntry('ご', 'go'),
    MapEntry('ざ', 'za'),
    MapEntry('じ', 'ji'),
    MapEntry('ず', 'zu'),
    MapEntry('ぜ', 'ze'),
    MapEntry('ぞ', 'zo'),
    MapEntry('だ', 'da'),
    MapEntry('ぢ', 'ji'),
    MapEntry('づ', 'zu'),
    MapEntry('で', 'de'),
    MapEntry('ど', 'do'),
    MapEntry('ば', 'ba'),
    MapEntry('び', 'bi'),
    MapEntry('ぶ', 'bu'),
    MapEntry('べ', 'be'),
    MapEntry('ぼ', 'bo'),
  ];

  static const List<MapEntry<String, String>> _handakuten = [
    MapEntry('ぱ', 'pa'),
    MapEntry('ぴ', 'pi'),
    MapEntry('ぷ', 'pu'),
    MapEntry('ぺ', 'pe'),
    MapEntry('ぽ', 'po'),
  ];

  final TextEditingController _controller = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final Random _random = Random();

  bool _includeDakuten = false;
  bool _includeHandakuten = false;

  late List<MapEntry<String, String>> _activeSet;
  int _currentIndex = 0;
  String? _feedback; // "Correct!" or "Try again"
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _rebuildActiveSet();
    _pickRandomCharacter();
  }

  void _rebuildActiveSet() {
    _activeSet = [
      ..._basicHiragana,
      if (_includeDakuten) ..._dakuten,
      if (_includeHandakuten) ..._handakuten,
    ];
  }

  void _pickRandomCharacter() {
    if (_activeSet.isEmpty) {
      _rebuildActiveSet();
    }
    setState(() {
      _currentIndex = _random.nextInt(_activeSet.length);
      _controller.clear();
      //_feedback = null;
      //_isCorrect = false;
    });

   
  }

  void _checkAnswer() {
    final userInput = _controller.text.trim().toLowerCase();
    final correct = _activeSet[_currentIndex].value;

    setState(() {
      if (userInput == correct) {
        _feedback = 'Correct! "$correct"';
        _isCorrect = true;
      } else {
        _feedback = 'Incorrect!';
        _isCorrect = false;
      }
    });

    // If correct, immediately move to the next character.
    if (userInput == correct) {
      _pickRandomCharacter();
    }

     // Request focus after layout so the TextField is laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _inputFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentChar = _activeSet[_currentIndex].key;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hiragana Trainer'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Text(
                currentChar,
                style: const TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                FilterChip(
                  label: const Text('Include dakuten (が, ざ, だ, ば...)'),
                  selected: _includeDakuten,
                  onSelected: (value) {
                    setState(() {
                      _includeDakuten = value;
                      _rebuildActiveSet();
                      _pickRandomCharacter();
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Include handakuten (ぱ...)'),
                  selected: _includeHandakuten,
                  onSelected: (value) {
                    setState(() {
                      _includeHandakuten = value;
                      _rebuildActiveSet();
                      _pickRandomCharacter();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              focusNode: _inputFocusNode,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _checkAnswer(),
              decoration: const InputDecoration(
                labelText: 'Type the romaji (e.g. "shi")',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _checkAnswer,
              child: const Text('Check'),
            ),
            const SizedBox(height: 16),
            if (_feedback != null)
              Text(
                _feedback!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: _isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const Spacer(),
            const Text(
              'Tip: answers are in romaji, lowercase.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }
}
