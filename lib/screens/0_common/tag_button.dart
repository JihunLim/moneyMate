import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CircleButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(), backgroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.all(24),
      ),
      child: Text(label),
    );
  }
}


/*  사용법
import 'package:flutter/material.dart';
import 'circle_button.dart';

class YourWidget extends StatefulWidget {
  @override
  _YourWidgetState createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
  String selectedTag = '기타';

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        CircleButton(
          label: 'Eat',
          onPressed: () => setState(() => selectedTag = 'Eat'),
        ),
        CircleButton(
          label: 'Buy',
          onPressed: () => setState(() => selectedTag = 'Buy'),
        ),
        // Add more buttons here as needed
      ],
    );
  }
}
*/