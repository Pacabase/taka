import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taka/pages/about/about_page.dart';
import 'package:taka/pages/settings/settings_bloc.dart';
import 'package:taka/pages/tunnels/widgets/native_switch.dart';
import 'package:taka/theme/taka_colors.dart';
import 'package:taka/widgets/app_icon.dart';

class const SettingsPage({super.key, required final String version})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = TakaColors.of(context);
    void send(AgentCommand command) =>
        context.read<SettingsBloc>().add(SettingsEvent.send(command));

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  'Settings',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) => switch (state) {
              SettingsLoading() => const SizedBox.shrink(),
              SettingsReady(
                settings: AgentSettings(
                  :final launchesAtLogin,
                  :final isLogging,
                ),
              ) =>
                Column(
                  children: [
                    if (launchesAtLogin != null)
                      _SettingRow(
                        title: 'Launch at Login',
                        detail: 'Start Taka in the menu bar when you log in.',
                        trailing: NativeSwitch(
                          value: launchesAtLogin,
                          color: colors.green,
                          label: 'Launch at Login',
                          onToggle: () => send(
                            AgentCommand.setLaunchAtLogin(on: !launchesAtLogin),
                          ),
                        ),
                      ),
                    _SettingRow(
                      title: 'Debug Logging',
                      detail: 'Keep a detailed log, to report a problem.',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          if (isLogging)
                            TextButton(
                              onPressed: () =>
                                  send(const AgentCommand.showLogs()),
                              child: const Text('Show Logs'),
                            ),
                          NativeSwitch(
                            value: isLogging,
                            color: colors.green,
                            label: 'Debug Logging',
                            onToggle: () => send(
                              AgentCommand.setDebugLogging(on: !isLogging),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            },
          ),
          Divider(height: 1, indent: 6, endIndent: 6, color: colors.background),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => AboutPage(version: version),
              ),
            ),
            child: _SettingRow(
              title: 'About Taka',
              trailing: AppIcon(
                AppIcons.chevronRight,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class const _SettingRow({
  required final String title,
  final String? detail,
  required final Widget trailing,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = TakaColors.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (detail case final detail?)
                  Text(
                    detail,
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
