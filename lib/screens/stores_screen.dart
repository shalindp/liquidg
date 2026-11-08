import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/stores_header.dart';
import '../widgets/stores_map/stores_map.dart';

class StoresScreen extends StatelessWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoresMap(contentTop: StoresHeader.heightOf(context) + TwSpacing.s2);
  }
}
