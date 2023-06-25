import 'package:flutter/material.dart';
import 'package:musicpod/l10n/l10n.dart';

class FailedImportsContent extends StatelessWidget {
  const FailedImportsContent({
    super.key,
    required this.failedImports,
  });

  final List<String> failedImports;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 400,
      width: 400,
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  context.l10n.failedToImport,
                  style: TextStyle(
                    color: theme.colorScheme.onInverseSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: failedImports.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    failedImports[index],
                    style: TextStyle(color: theme.colorScheme.onInverseSurface),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
