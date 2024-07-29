import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import 'theme.dart';

class CommonSwitch extends StatelessWidget {
  const CommonSwitch({super.key, required this.value, this.onChanged});

  final bool value;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return yaruStyled
        ? YaruSwitch(
            value: value,
            onChanged: onChanged,
          )
        : Switch(value: value, onChanged: onChanged);
  }
}

class CommonCheckBox extends StatelessWidget {
  const CommonCheckBox({super.key, required this.value, this.onChanged});

  final bool value;
  final void Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return yaruStyled
        ? YaruCheckbox(
            value: value,
            onChanged: onChanged,
          )
        : Checkbox(value: value, onChanged: onChanged);
  }
}

class ImportantButton extends StatelessWidget {
  const ImportantButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final void Function()? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return yaruStyled
        ? ElevatedButton(
            onPressed: onPressed,
            child: child,
          )
        : FilledButton(onPressed: onPressed, child: child);
  }
}
