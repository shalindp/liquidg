import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/app_header.dart';
import '../widgets/stores_map/stores_map.dart';

class StoresScreen extends StatelessWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contentTop = AppHeader.heightOf(context) + TwSpacing.s2;
    return StoresMap(contentTop: contentTop);
  }
}
