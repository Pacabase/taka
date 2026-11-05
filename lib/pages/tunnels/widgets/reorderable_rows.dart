import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  final _rowKeys = <Key, GlobalKey>{};
  _Drag? _drag;
  // Shown until the moved order arrives, so the row doesn't jump back.
  List<Widget>? _moved;
  // Stays hovered until the pointer moves, as its own hover starts a frame late.
  Key? _dropped;

  List<Widget> get _children => _moved ?? widget.children;

  @override
  void didUpdateWidget(ReorderableRows oldWidget) {
    super.didUpdateWidget(oldWidget);
    final keys = [for (final child in widget.children) child.key];
    if (!listEquals(keys, [
      for (final child in oldWidget.children) child.key,
    ])) {
      _moved = null;
    }
    _rowKeys.removeWhere((key, _) => !keys.contains(key));
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
                  children: [
                    for (final (index, child) in _children.indexed)
                      KeyedSubtree(
                        key: _rowKeys.putIfAbsent(child.key!, GlobalKey.new),
                        child: GestureDetector(
                          onVerticalDragStart: (_) => _start(index),
                          onVerticalDragUpdate: _update,
                          onVerticalDragEnd: (_) => _end(),
                          onVerticalDragCancel: _end,
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
                        child: _lifted(_children[drag.from]),
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
    if (_moved != null) return;

    final heights = [
      for (final child in _children)
        _rowKeys[child.key]!.currentContext!.size!.height,
    ];
    final tops = List.generate(
      heights.length,
      (index) => heights.take(index).fold(0.0, (sum, height) => sum + height),
    );
    setState(() => _drag = _Drag(index, tops, heights));
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
        _dropped = _children[from].key;
        if (to != from) {
          _moved = [..._children]
            ..removeAt(from)
            ..insert(to, _children[from]);
        }
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

  double get slot =>
      heights.indexed
          .where((row) => row.$1 != from && _placeOf(row.$1) < to)
          .fold(0.0, (sum, row) => sum + row.$2) -
      tops[from];

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

  double shiftOf(int index) => switch (_placeOf(index)) {
    _ when index == from => 0,
    final place when index < from && place >= to => _height,
    final place when index > from && place < to => -_height,
    _ => 0,
  };

  int _placeOf(int index) => index < from ? index : index - 1;
}

class const _Lifted({required final bool isLifted, required super.child})
    extends InheritedWidget {
  @override
  bool updateShouldNotify(_Lifted oldWidget) => isLifted != oldWidget.isLifted;
}
