import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const KanaTrainerApp());
}

class KanaTrainerApp extends StatelessWidget {
  const KanaTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kana Trainer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const KanaHomePage(),
    );
  }
}

class KanaHomePage extends StatefulWidget {
  const KanaHomePage({super.key});

  @override
  State<KanaHomePage> createState() => _KanaHomePageState();
}

class _KanaHomePageState extends State<KanaHomePage> {
  int _selectedIndex = 0; // 0 = Hiragana, 1 = Katakana

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kana Trainer'), centerTitle: true),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.text_fields),
                label: Text('Hiragana'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.translate),
                label: Text('Katakana'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [HiraganaQuizPage(), KatakanaQuizPage()],
            ),
          ),
        ],
      ),
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
      _feedback = null;
      _isCorrect = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _inputFocusNode.requestFocus();
      }
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
  }

  @override
  Widget build(BuildContext context) {
    final currentChar = _activeSet[_currentIndex].key;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Center(
            child: Text(
              currentChar,
              style: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
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
          FilledButton(onPressed: _checkAnswer, child: const Text('Check')),
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
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }
}

class KatakanaQuizPage extends StatefulWidget {
  const KatakanaQuizPage({super.key});

  @override
  State<KatakanaQuizPage> createState() => _KatakanaQuizPageState();
}

class _KatakanaQuizPageState extends State<KatakanaQuizPage> {
  static const List<MapEntry<String, String>> _basicKatakana = [
    MapEntry('ア', 'a'),
    MapEntry('イ', 'i'),
    MapEntry('ウ', 'u'),
    MapEntry('エ', 'e'),
    MapEntry('オ', 'o'),
    MapEntry('カ', 'ka'),
    MapEntry('キ', 'ki'),
    MapEntry('ク', 'ku'),
    MapEntry('ケ', 'ke'),
    MapEntry('コ', 'ko'),
    MapEntry('サ', 'sa'),
    MapEntry('シ', 'shi'),
    MapEntry('ス', 'su'),
    MapEntry('セ', 'se'),
    MapEntry('ソ', 'so'),
    MapEntry('タ', 'ta'),
    MapEntry('チ', 'chi'),
    MapEntry('ツ', 'tsu'),
    MapEntry('テ', 'te'),
    MapEntry('ト', 'to'),
    MapEntry('ナ', 'na'),
    MapEntry('ニ', 'ni'),
    MapEntry('ヌ', 'nu'),
    MapEntry('ネ', 'ne'),
    MapEntry('ノ', 'no'),
    MapEntry('ハ', 'ha'),
    MapEntry('ヒ', 'hi'),
    MapEntry('フ', 'fu'),
    MapEntry('ヘ', 'he'),
    MapEntry('ホ', 'ho'),
    MapEntry('マ', 'ma'),
    MapEntry('ミ', 'mi'),
    MapEntry('ム', 'mu'),
    MapEntry('メ', 'me'),
    MapEntry('モ', 'mo'),
    MapEntry('ヤ', 'ya'),
    MapEntry('ユ', 'yu'),
    MapEntry('ヨ', 'yo'),
    MapEntry('ラ', 'ra'),
    MapEntry('リ', 'ri'),
    MapEntry('ル', 'ru'),
    MapEntry('レ', 're'),
    MapEntry('ロ', 'ro'),
    MapEntry('ワ', 'wa'),
    MapEntry('ヲ', 'wo'),
    MapEntry('ン', 'n'),
  ];

  static const List<MapEntry<String, String>> _dakuten = [
    MapEntry('ガ', 'ga'),
    MapEntry('ギ', 'gi'),
    MapEntry('グ', 'gu'),
    MapEntry('ゲ', 'ge'),
    MapEntry('ゴ', 'go'),
    MapEntry('ザ', 'za'),
    MapEntry('ジ', 'ji'),
    MapEntry('ズ', 'zu'),
    MapEntry('ゼ', 'ze'),
    MapEntry('ゾ', 'zo'),
    MapEntry('ダ', 'da'),
    MapEntry('ヂ', 'ji'),
    MapEntry('ヅ', 'zu'),
    MapEntry('デ', 'de'),
    MapEntry('ド', 'do'),
    MapEntry('バ', 'ba'),
    MapEntry('ビ', 'bi'),
    MapEntry('ブ', 'bu'),
    MapEntry('ベ', 'be'),
    MapEntry('ボ', 'bo'),
  ];

  static const List<MapEntry<String, String>> _handakuten = [
    MapEntry('パ', 'pa'),
    MapEntry('ピ', 'pi'),
    MapEntry('プ', 'pu'),
    MapEntry('ペ', 'pe'),
    MapEntry('ポ', 'po'),
  ];

  final TextEditingController _controller = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final Random _random = Random();

  bool _includeDakuten = false;
  bool _includeHandakuten = false;

  late List<MapEntry<String, String>> _activeSet;
  int _currentIndex = 0;
  String? _feedback;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _rebuildActiveSet();
    _pickRandomCharacter();
  }

  void _rebuildActiveSet() {
    _activeSet = [
      ..._basicKatakana,
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
      _feedback = null;
      _isCorrect = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _inputFocusNode.requestFocus();
      }
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

    if (userInput == correct) {
      _pickRandomCharacter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentChar = _activeSet[_currentIndex].key;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Center(
            child: Text(
              currentChar,
              style: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              FilterChip(
                label: const Text('Include dakuten (ガ, ザ, ダ, バ...)'),
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
                label: const Text('Include handakuten (パ...)'),
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
          FilledButton(onPressed: _checkAnswer, child: const Text('Check')),
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
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }
}
