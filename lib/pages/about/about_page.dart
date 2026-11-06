import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taka/theme/taka_colors.dart';
import 'package:taka/widgets/app_icon.dart';

const _legalese = 'Copyright © 2026 the Taka project authors.';

Stream<LicenseEntry> bundledLicenses() async* {
  for (final (packages, file) in [
    (['Lucide'], 'assets/icons/LICENSE'),
    (['Inter'], 'fonts/LICENSE-Inter.txt'),
    (['JetBrains Mono'], 'fonts/LICENSE-JetBrainsMono.txt'),
  ]) {
    yield LicenseEntryWithLineBreaks(
      packages,
      await rootBundle.loadString(file),
    );
  }
  yield* Stream.fromIterable(
    agentLicences(await rootBundle.loadString('assets/agent_licences.json')),
  );
}

/// Licences of the background helper's packages that Flutter doesn't list
/// already.
Iterable<LicenseEntry> agentLicences(String json) => [
  for (final entry in jsonDecode(json) as List<Object?>)
    if (entry case {
      'package': final String package,
      'licence': final String licence,
    })
      LicenseEntryWithLineBreaks([package], licence),
];

class const AboutPage({super.key, required final String version})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = TakaColors.of(context);
    final secondary = TextStyle(color: colors.textSecondary);

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 32,
            padding: const EdgeInsets.only(left: 4, right: 12),
            color: colors.background,
            child: Row(
              spacing: 4,
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.pop(context),
                  icon: AppIcon(
                    AppIcons.chevronLeft,
                    color: colors.textSecondary,
                  ),
                ),
                const Text(
                  'About Taka',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  Image.asset('assets/icon/icon.png', width: 64, height: 64),
                  const SizedBox(height: 4),
                  const Text(
                    'Taka',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text('Version $version', style: secondary),
                  Text(
                    'SSH tunnels and SOCKS proxies, through your own ssh.',
                    style: secondary,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => showLicensePage(
                      context: context,
                      applicationName: 'Taka',
                      applicationVersion: version,
                      applicationLegalese: _legalese,
                    ),
                    child: const Text('Open-source licenses'),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Icons by Lucide. Fonts: Inter and JetBrains Mono. Colors from '
              "base16 One Light and OneDark, after Atom's One themes.\n"
              '$_legalese',
              textAlign: TextAlign.center,
              style: secondary.copyWith(fontSize: 12, height: 18 / 12),
            ),
          ),
        ],
      ),
    );
  }
}
