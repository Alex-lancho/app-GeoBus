import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData iconData;
  final String label;
  final VoidCallback onPressed;

  const ActionButton({
    Key? key,
    required this.iconData,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilledButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: colorScheme.onPrimary),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }
}
