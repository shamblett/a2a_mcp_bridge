/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 07/11/2025
* Copyright :  S.Hamblett
*/

part of '../a2a_mcp_bridge.dart';

///
/// Simple logging.
///
class A2ALog {
  static void info(String text) => print('${Colorize(text).blue()}');

  static void warn(String text) => print('${Colorize(text).yellow()}');

  static void fatal(String text) => print('${Colorize(text).red()}');
}
