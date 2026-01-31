import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glassmorphism Calculator',
      theme: ThemeData.dark(),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _history = '';
  double? _firstOperand;
  String? _operation;
  bool _shouldClearDisplay = true;
  double _memory = 0;
  String? _pressedButton;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus on startup.
    // WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      String keyLabel = key.keyLabel;
      String? buttonToPress;

      // Handle number keys
      if (key == LogicalKeyboardKey.digit0 || key == LogicalKeyboardKey.numpad0) {
        buttonToPress = '0';
      } else if (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.numpad1) {
        buttonToPress = '1';
      } else if (key == LogicalKeyboardKey.digit2 || key == LogicalKeyboardKey.numpad2) {
        buttonToPress = '2';
      } else if (key == LogicalKeyboardKey.digit3 || key == LogicalKeyboardKey.numpad3) {
        buttonToPress = '3';
      } else if (key == LogicalKeyboardKey.digit4 || key == LogicalKeyboardKey.numpad4) {
        buttonToPress = '4';
      } else if (key == LogicalKeyboardKey.digit5 || key == LogicalKeyboardKey.numpad5) {
        buttonToPress = '5';
      } else if (key == LogicalKeyboardKey.digit6 || key == LogicalKeyboardKey.numpad6) {
        buttonToPress = '6';
      } else if (key == LogicalKeyboardKey.digit7 || key == LogicalKeyboardKey.numpad7) {
        buttonToPress = '7';
      } else if (key == LogicalKeyboardKey.digit8 || key == LogicalKeyboardKey.numpad8) {
        buttonToPress = '8';
      } else if (key == LogicalKeyboardKey.digit9 || key == LogicalKeyboardKey.numpad9) {
        buttonToPress = '9';
      } else if (key == LogicalKeyboardKey.period || key == LogicalKeyboardKey.numpadDecimal) {
        buttonToPress = '.';
      } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.equal || key == LogicalKeyboardKey.numpadEnter) {
        buttonToPress = '=';
      } else if (key == LogicalKeyboardKey.backspace) {
        buttonToPress = '⌫';
      } else if (key == LogicalKeyboardKey.add || key == LogicalKeyboardKey.numpadAdd) {
        buttonToPress = '+';
      } else if (key == LogicalKeyboardKey.minus || key == LogicalKeyboardKey.numpadSubtract) {
        buttonToPress = '-';
      } else if (key == LogicalKeyboardKey.numpadMultiply || keyLabel == '*') {
        buttonToPress = '×';
      } else if (key == LogicalKeyboardKey.numpadDivide || keyLabel == '/') {
        buttonToPress = '÷';
      } else if (key.keyLabel.toLowerCase() == 'c') {
        buttonToPress = 'C';
      }

      if (buttonToPress != null) {
        _animateButtonPress(buttonToPress);
      }

      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _animateButtonPress(String buttonText) {
    setState(() {
      _pressedButton = buttonText;
    });
    _onButtonPressed(buttonText);

    // Clear the pressed state after a short delay
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _pressedButton = null;
        });
      }
    });
  }

  void _onButtonPressed(String buttonText) {
    setState(() {
      if ('0123456789.'.contains(buttonText)) {
        _handleDigitInput(buttonText);
      } else if ('+-×÷'.contains(buttonText)) {
        _handleOperatorInput(buttonText);
      } else if (buttonText == '=') {
        _handleEquals();
      } else if (buttonText == 'C') {
        _handleClear();
      } else if (buttonText == '⌫') {
        _handleBackspace();
      } else if (buttonText == 'M') {
        _display = _formatResult(_memory);
        _shouldClearDisplay = true;
      } else if (buttonText == 'M+') {
        _memory += double.tryParse(_display) ?? 0;
      } else if (buttonText == 'M-') {
        _memory -= double.tryParse(_display) ?? 0;
      }
    });
  }

  void _handleDigitInput(String digit) {
    if (_shouldClearDisplay) {
      _display = (digit == '.') ? '0.' : digit;
      _shouldClearDisplay = false;
    } else {
      if (digit == '.' && _display.contains('.')) return;
      _display += digit;
    }
  }

  // void _handleOperatorInput(String op) {
  //   if (_firstOperand == null || _shouldClearDisplay) {
  //     _firstOperand = double.tryParse(_display);
  //   } else {
  //     _calculate();
  //   }
  //   _operation = op;
  //   _history = '${_formatResult(_firstOperand!)} $_operation';
  //   _shouldClearDisplay = true;
  // }

  void _handleOperatorInput(String op) {
    // FIX: Added '|| _operation == null' to the condition.
    // If there is no pending operator (like after pressing =),
    // we should treat the current number as the first operand
    // for a new calculation, rather than trying to calculate.
    if (_firstOperand == null || _shouldClearDisplay || _operation == null) {
      _firstOperand = double.tryParse(_display);
    } else {
      _calculate();
    }
    _operation = op;
    _history = '${_formatResult(_firstOperand!)} $_operation';
    _shouldClearDisplay = true;
  }

  void _handleEquals() {
    if (_firstOperand == null || _operation == null) return;
    _calculate();
    _history = '';
    _operation = null;
    _shouldClearDisplay = true;
  }

  void _calculate() {
    if (_shouldClearDisplay && _operation != null) return;
    double secondOperand = double.tryParse(_display) ?? 0;
    double result = 0;

    if (_operation != null) {
      switch (_operation) {
        case '+':
          result = _firstOperand! + secondOperand;
          break;
        case '-':
          result = _firstOperand! - secondOperand;
          break;
        case '×':
          result = _firstOperand! * secondOperand;
          break;
        case '÷':
          result = secondOperand != 0 ? _firstOperand! / secondOperand : double.nan;
          break;
      }
    }

    _display = result.isNaN ? 'Error' : _formatResult(result);
    _firstOperand = result.isNaN ? null : result;
  }

  void _handleClear() {
    _display = '0';
    _history = '';
    _firstOperand = null;
    _operation = null;
    _shouldClearDisplay = true;
  }

  void _handleBackspace() {
    if (_shouldClearDisplay) return;
    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
    } else {
      _display = '0';
      _shouldClearDisplay = true;
    }
  }

  String _formatResult(double value) {
    if (value.isNaN) return 'Error';
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else {
      return value.toString();
    }
  }


  Widget _buildButtonRow(List<String> buttons) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons.map((text) {
          return Expanded(
            child: CalculatorButton(
              text: text,
              onPressed: () => _onButtonPressed(text),
              isOperator: '+-×÷='.contains(text),
              isAction: 'C⌫'.contains(text),
              isMemory: 'M M+ M-'.contains(text),
              isPressed: _pressedButton == text,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      body: Focus(

        focusNode: _focusNode,

        autofocus: true,

        onKeyEvent: _handleKeyEvent,

        child: Column(

          children: [

            Expanded(

              flex: 2,

              child: Container(

                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),

                alignment: Alignment.bottomRight,

                child: Column(

                  mainAxisAlignment: MainAxisAlignment.end,

                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [

                    FittedBox(

                      fit: BoxFit.contain,

                      child: Text(

                        _history,

                        style: const TextStyle(fontSize: 24, color: Colors.white54),

                        maxLines: 1,

                      ),

                    ),

                    const SizedBox(height: 8),

                    FittedBox(

                      fit: BoxFit.contain,

                      child: Text(

                        _display,

                        style: const TextStyle(fontSize: 64, color: Colors.white),

                        maxLines: 1,

                      ),

                    ),

                  ],

                ),

              ),

            ),

            Expanded(

              flex: 3,

              child: Column(

                children: [

                  _buildButtonRow(['C', '⌫', 'M', '÷']),

                  _buildButtonRow(['7', '8', '9', '×']),

                  _buildButtonRow(['4', '5', '6', '-']),

                  _buildButtonRow(['1', '2', '3', '+']),

                  _buildButtonRow(['M+', '0', '.', '=']),

                ],

              ),

            ),

          ],

        ),

      ),

    );

  }
}

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOperator;
  final bool isAction;
  final bool isMemory;
  final bool isPressed;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOperator = false,
    this.isAction = false,
    this.isMemory = false,
    this.isPressed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPressed
                ? [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.4),
                ]
                : [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: isPressed
                ? Colors.white.withOpacity(0.4)
                : Colors.white.withOpacity(0.2),
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(24),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: isOperator
                        ? Colors.orange
                        : isAction
                        ? Colors.redAccent
                        : isMemory
                        ? Colors.green
                        : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
