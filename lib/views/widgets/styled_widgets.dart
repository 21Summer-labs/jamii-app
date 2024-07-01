import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class Display1Text extends StatelessWidget {
  final String text;

  Display1Text(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTheme.display1);
  }
}

class Heading1Text extends StatelessWidget {
  final String text;

  Heading1Text(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTheme.heading1);
  }
}

class Heading2Text extends StatelessWidget {
  final String text;

  Heading2Text(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTheme.heading2);
  }
}

class Heading3Text extends StatelessWidget {
  final String text;

  Heading3Text(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTheme.heading3);
  }
}

class Heading4Text extends StatelessWidget {
  final String text;
  final bool uppercase;

  Heading4Text(this.text, {this.uppercase = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      uppercase ? text.toUpperCase() : text,
      style: uppercase ? AppTheme.heading4Uppercase : AppTheme.heading4,
    );
  }
}

class Paragraph1Text extends StatelessWidget {
  final String text;

  Paragraph1Text(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTheme.paragraph1);
  }
}

class Paragraph2Text extends StatelessWidget {
  final String text;

  Paragraph2Text(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTheme.paragraph2);
  }
}

class StyledButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  StyledButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class StyledHyperlink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  StyledHyperlink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(text, style: AppTheme.hyperlink),
    );
  }
}