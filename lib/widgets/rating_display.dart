import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RatingDisplay extends StatelessWidget {
  final int value;
  const RatingDisplay({this.value = 0});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < value
              ? MdiIcons.checkboxMarkedCircle
              : MdiIcons.closeCircleOutline,
        );
      }),
    );
  }
}
