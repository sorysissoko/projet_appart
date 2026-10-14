import 'package:logger/logger.dart';
//import 'package:flutter/foundation.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    colors: true,
    printEmojis: true,
  ),
 // level: kReleaseMode ? Level.nothing : Level.debug,

);
