import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:taka/theme/taka_colors.dart';

/// A column of keyed [children] that can be dragged into a new order.
///
/// ReorderableListView's animations take a fixed 250ms, which feels slow for
/// a short list. [onReorder] gets the index a row moved to among the others.
class const ReorderableRows({
  super.key,
  required final List<Widget> children,
  required final void Function(int from, int to) onReorder,
}) extends StatefulWidget {
  /// Whether [context] is in the row being dragged, which shows as hovered.
  static bool isLifted(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Lifted>()?.isLifted ?? false;

  @override
  State<ReorderableRows> createState() => _ReorderableRowsState();
}

class _ReorderableRowsState extends State<ReorderableRows> {
  static const _duration = Duration(milliseconds: 120);

  final _column = GlobalKey();
  _Drag? _drag;
  // Stays hovered until the pointer moves, as its own hover starts a frame late.
  Key? _dropped;

  @override
  void didUpdateWidget(ReorderableRows oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(
      [for (final child in widget.children) child.key],
      [for (final child in oldWidget.children) child.key],
    )) {
      _drag = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final drag = _drag;

    return Listener(
      onPointerHover: (_) {
        if (_dropped != null) setState(() => _dropped = null);
      },
      child: SizedBox.expand(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              IgnorePointer(
                ignoring: drag != null,
                child: Column(
                  key: _column,
                  children: [
                    for (final (index, child) in widget.children.indexed)
                      KeyedSubtree(
                        key: child.key,
                        child: GestureDetector(
                          supportedDevices: const {PointerDeviceKind.mouse},
                          onVerticalDragStart: (_) => _start(index),
                          onVerticalDragUpdate: _update,
                          onVerticalDragEnd: (_) => _end(),
                          child: TweenAnimationBuilder(
                            tween: Tween(end: drag?.shiftOf(index) ?? 0),
                            duration: drag == null ? Duration.zero : _duration,
                            curve: Curves.easeOut,
                            builder: (context, dy, child) =>
                                Transform.translate(
                                  offset: Offset(0, dy),
                                  child: child,
                                ),
                            child: Visibility.maintain(
                              visible: drag?.from != index,
                              child: _Lifted(
                                isLifted: child.key == _dropped,
                                child: child,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (drag != null)
                Positioned(
                  top: drag.tops[drag.from],
                  left: 0,
                  right: 0,
                  child: TweenAnimationBuilder(
                    tween: Tween(end: drag.isDropping ? drag.slot : drag.dy),
                    duration: drag.isDropping ? _duration : Duration.zero,
                    curve: Curves.easeOut,
                    onEnd: () {
                      if (drag.isDropping) _drop();
                    },
                    builder: (context, dy, child) => Transform.translate(
                      offset: Offset(0, dy),
                      child: child,
                    ),
                    child: IgnorePointer(
                      child: _Lifted(
                        isLifted: true,
                        child: _lifted(widget.children[drag.from]),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lifted(Widget child) => DecoratedBox(
    decoration: BoxDecoration(
      color: TakaColors.of(context).surface,
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 8),
      ],
    ),
    child: child,
  );

  void _start(int index) {
    final column = _column.currentContext!.findRenderObject()! as RenderFlex;
    final rows = column.getChildrenAsList();
    setState(
      () => _drag = _Drag(
        index,
        [for (final row in rows) (row.parentData! as FlexParentData).offset.dy],
        [for (final row in rows) row.size.height],
      ),
    );
  }

  void _update(DragUpdateDetails details) {
    if (_drag case final drag? when !drag.isDropping) {
      setState(() => drag.moveBy(details.delta.dy));
    }
  }

  void _end() {
    if (_drag case final drag? when !drag.isDropping) {
      if (drag.dy == drag.slot) return _drop();
      setState(() => drag.isDropping = true);
    }
  }

  void _drop() {
    if (_drag case _Drag(:final from, :final to)) {
      setState(() {
        _drag = null;
        _dropped = widget.children[from].key;
      });
      if (to != from) widget.onReorder(from, to);
    }
  }
}

class _Drag(
  final int from,
  final List<double> tops,
  final List<double> heights,
) {
  double dy = 0;
  late int to = from;
  bool isDropping = false;

  double get _height => heights[from];

  double get slot => to <= from
      ? tops[to] - tops[from]
      : tops[to] + heights[to] - tops[from] - _height;

  void moveBy(double delta) {
    final top = tops[from];
    dy = (dy + delta).clamp(-top, tops.last + heights.last - top - _height);
    to = [
      for (final (index, height) in heights.indexed)
        if (tops[index] + height / 2 case final center
            when index < from && center < top + dy ||
                index > from && center < top + dy + _height)
          index,
    ].length;
  }

  double shiftOf(int index) => switch (index) {
    _ when index < from && index >= to => _height,
    _ when index > from && index <= to => -_height,
    _ => 0,
  };
}

class const _Lifted({required final bool isLifted, required super.child})
    extends InheritedWidget {
  @override
  bool updateShouldNotify(_Lifted oldWidget) => isLifted != oldWidget.isLifted;
}
