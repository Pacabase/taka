import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:taka/theme/taka_colors.dart';

/// ReorderableListView's fixed 250ms animations feel slow for a short list.
/// [onReorder]'s `to` is the row's index among the others. [spanOf] is how
/// many rows a drag from a row carries along, itself included.
class const ReorderableRows({
  super.key,
  required final List<Widget> children,
  required final void Function(int from, int to) onReorder,
  final int Function(int index)? spanOf,
}) extends StatefulWidget {
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
                              visible: !(drag?.covers(index) ?? false),
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
                        child: _lifted(
                          Column(
                            children: widget.children
                                .skip(drag.from)
                                .take(drag.span)
                                .toList(),
                          ),
                        ),
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
        widget.spanOf?.call(index) ?? 1,
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
  final int span,
  final List<double> tops,
  final List<double> heights,
) {
  double dy = 0;
  late int to = from;
  bool isDropping = false;

  int get _end => from + span;

  double get _top => tops[from];

  double get _height => tops[_end - 1] + heights[_end - 1] - _top;

  bool covers(int index) => index >= from && index < _end;

  List<int> get _others => [
    for (var index = 0; index < tops.length; index++)
      if (!covers(index)) index,
  ];

  double get slot =>
      tops.first +
      _others.take(to).fold(0.0, (top, index) => top + heights[index]) -
      _top;

  void moveBy(double delta) {
    dy = (dy + delta).clamp(-_top, tops.last + heights.last - _top - _height);
    to = [
      for (final index in _others)
        if (tops[index] + heights[index] / 2 case final center
            when index < from && center < _top + dy ||
                index >= _end && center < _top + dy + _height)
          index,
    ].length;
  }

  double shiftOf(int index) {
    final rank = index < from ? index : index - span;
    return switch (index) {
      _ when index < from && rank >= to => _height,
      _ when index >= _end && rank < to => -_height,
      _ => 0,
    };
  }
}

class const _Lifted({required final bool isLifted, required super.child})
    extends InheritedWidget {
  @override
  bool updateShouldNotify(_Lifted oldWidget) => isLifted != oldWidget.isLifted;
}
