import 'package:flutter/material.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key, required this.onDone});

  final Future<void> Function() onDone;

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const List<(String, String, IconData)> _pages = <(String, String, IconData)>[
    ('Welcome to Agile Sprint Master', 'Create projects, build backlogs, and run realistic sprint simulations.', Icons.rocket_launch),
    ('Run Sprint Days', 'Use play, pause, and step controls to advance virtual days and react to events.', Icons.play_circle_outline),
    ('Track Team Performance', 'Monitor velocity, burndown, XP, and achievements across projects.', Icons.insights_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (value) => setState(() => _index = value),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(page.$3, size: 84, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 24),
                        Text(page.$1, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(page.$2, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: _index == 0
                          ? null
                          : () => _controller.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        if (_index == _pages.length - 1) {
                          await widget.onDone();
                          return;
                        }
                        await _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
                      },
                      child: Text(_index == _pages.length - 1 ? 'Get Started' : 'Next'),
                    ),
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
