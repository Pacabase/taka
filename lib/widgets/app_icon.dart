import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taka/theme/taka_colors.dart';

class const AppIconData._(final String name) {}

abstract final class AppIcons {
  static const chevronLeft = AppIconData._('chevron-left');
  static const pencil = AppIconData._('pencil');
  static const plus = AppIconData._('plus');
  static const trash = AppIconData._('trash-2');
  static const triangleAlert = AppIconData._('triangle-alert');
}

class const AppIcon(
  final AppIconData icon, {
  super.key,
  final double size = 16.0,
  final Color? color,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      widthFactor: 1.0,
      heightFactor: 1.0,
      child: _PixelSnap(
        devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
        child: SvgPicture(
          _IconLoader(
            'assets/icons/${icon.name}.svg',
            strokeWidth: 24.0 / size,
          ),
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(
            color ?? TakaColors.of(context).text,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class const _IconLoader(super.assetName, {required final double strokeWidth})
    extends SvgAssetLoader {
  @override
  String provideSvg(ByteData? message) {
    return super
        .provideSvg(message)
        .replaceFirst(
          RegExp('stroke-width="[^"]*"'),
          'stroke-width="$strokeWidth"',
        );
  }

  @override
  SvgCacheKey cacheKey(BuildContext? context) {
    return SvgCacheKey(
      theme: getTheme(context),
      colorMapper: colorMapper,
      keyData: (assetName, strokeWidth),
    );
  }

  @override
  int get hashCode => Object.hash(assetName, strokeWidth);

  @override
  bool operator ==(Object other) {
    return other is _IconLoader &&
        other.assetName == assetName &&
        other.strokeWidth == strokeWidth;
  }
}

class const _PixelSnap({required final double devicePixelRatio, super.child})
    extends SingleChildRenderObjectWidget {
  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderPixelSnap(devicePixelRatio);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderPixelSnap renderObject) {
    renderObject.devicePixelRatio = devicePixelRatio;
  }
}

class _RenderPixelSnap(var double _devicePixelRatio) extends RenderProxyBox {
  set devicePixelRatio(double value) {
    if (value == _devicePixelRatio) return;

    _devicePixelRatio = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // The 1px stroke is only crisp centred on a device pixel when it is an odd number of them wide.
    final nudge = _devicePixelRatio.round().isOdd ? 0.5 : 0.0;
    final origin = localToGlobal(Offset.zero) * _devicePixelRatio;
    final snapped = Offset(
      (origin.dx - nudge).round() + nudge,
      (origin.dy - nudge).round() + nudge,
    );

    super.paint(context, offset + (snapped - origin) / _devicePixelRatio);
  }
}
