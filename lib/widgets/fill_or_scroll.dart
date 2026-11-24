import 'package:flutter/widgets.dart';

/// Fills the space it's given, so a [Spacer] still works, or scrolls.
class const FillOrScroll({super.key, required final Widget child})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
  );
}
