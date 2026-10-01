import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';
import 'src/widgets.dart';

class YesNoSelection extends StatefulWidget {
  const YesNoSelection(
      {super.key, required this.state, required this.onSelection, required this.onNumberAttendeesChanged});
  final Attending state;
  final void Function(Attending selection) onSelection;
  final void Function(int numAttendees) onNumberAttendeesChanged;

  @override
  State<YesNoSelection> createState() => _YesNoState();
}

class _YesNoState extends State<YesNoSelection>{
  @override
  Widget build(BuildContext context) {
    switch (widget.state) {
      case Attending.yes:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              FilledButton(
                onPressed: () => widget.onSelection(Attending.yes),
                child: const Text('YES'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => widget.onSelection(Attending.no),
                child: const Text('NO'),
              ),
              TextField(
                onChanged: (value) => widget.onNumberAttendeesChanged(int.parse(value)),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Your party size',
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ],
          ),
        );
      case Attending.no:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              TextButton(
                onPressed: () => widget.onSelection(Attending.yes),
                child: const Text('YES'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => widget.onSelection(Attending.no),
                child: const Text('NO'),
              ),
            ],
          ),
        );
      default:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              StyledButton(
                onPressed: () => widget.onSelection(Attending.yes),
                child: const Text('YES'),
              ),
              const SizedBox(width: 8),
              StyledButton(
                onPressed: () => widget.onSelection(Attending.no),
                child: const Text('NO'),
              ),
            ],
          ),
        );
    }
  }
}
  

