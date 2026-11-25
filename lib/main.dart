import 'package:flutter/material.dart';

void main() {
  runApp(const LabApp());
}

enum PreviewResult { accepted, cancelled }

class LabApp extends StatelessWidget {
  const LabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF675080),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F1FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFC7AAF4),
          foregroundColor: Color(0xFF241A2D),
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF241A2D),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: const InputPage(),
    );
  }
}

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _sizeController = TextEditingController(text: '32');

  double? _parseSize(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  Future<void> _openPreview() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final text = _textController.text;
    final fontSize = _parseSize(_sizeController.text)!;

    final result = await Navigator.of(context).push<PreviewResult>(
      MaterialPageRoute<PreviewResult>(
        builder: (context) => PreviewPage(text: text, fontSize: fontSize),
      ),
    );

    if (!mounted) return;

    final message = switch (result) {
      PreviewResult.accepted => 'Cool!',
      PreviewResult.cancelled => 'Let’s try something else',
      null => "Don't know what to say",
    };

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Image.asset(
          'assets/robot.png',
          width: 56,
          height: 56,
          errorBuilder: (context, error, stackTrace) =>
          const Text('🤖', style: TextStyle(fontSize: 42)),
        ),
        title: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text settings')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: 'Text',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter some text';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sizeController,
                      decoration: const InputDecoration(
                        labelText: 'Font size',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final size = _parseSize(value ?? '');
                        if (size == null || !size.isFinite || size <= 0) {
                          return 'Enter a font size greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: FilledButton(
                        onPressed: _openPreview,
                        child: const Text('Preview'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PreviewPage extends StatelessWidget {
  const PreviewPage({
    super.key,
    required this.text,
    required this.fontSize,
  });

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: fontSize),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  children: [
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pop(PreviewResult.accepted),
                      child: const Text('Ok'),
                    ),
                    OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pop(PreviewResult.cancelled),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}