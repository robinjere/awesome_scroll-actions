import 'package:flutter/widgets.dart';

/// The Iconsax (linear) glyphs used by the Awesome Scroll Actions design,
/// bundled as a subset icon font so they render identically on every
/// platform.
abstract final class AwesomeScrollIcons {
  static const String _family = 'AwesomeScrollIcons';
  static const String _package = 'awesome_scroll_actions';

  static const IconData arrowUp = IconData(0xe89a, fontFamily: _family, fontPackage: _package);
  static const IconData arrowDown = IconData(0xe81b, fontFamily: _family, fontPackage: _package);
  static const IconData flash = IconData(0xe9a6, fontFamily: _family, fontPackage: _package);
  static const IconData mobile = IconData(0xe8b7, fontFamily: _family, fontPackage: _package);
  static const IconData scan = IconData(0xe9a1, fontFamily: _family, fontPackage: _package);
  static const IconData moneyChange = IconData(0xeb36, fontFamily: _family, fontPackage: _package);
  static const IconData barGraph = IconData(0xeb46, fontFamily: _family, fontPackage: _package);
  static const IconData bankCard = IconData(0xe9e1, fontFamily: _family, fontPackage: _package);
  static const IconData addCircle = IconData(0xe887, fontFamily: _family, fontPackage: _package);
  static const IconData add = IconData(0xe9d0, fontFamily: _family, fontPackage: _package);
}
