/*
* Package : a2a
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 10/07/2025
* Copyright :  S.Hamblett
*/

import 'package:a2a_mcp_bridge/a2a_mcp_bridge.dart';

///
/// An example showing usage of the MCP to A2A bridge.
///
/// The server starts on http://localhost:3080/mcp by default, the port can be changed.
/// To see the server details now run the mcp/a2a_query_mcp_server.dart example -
///
///   'dart example/mcp/a2a_query_mcp_server.dart localhost:3080/mcp'
///
Future<void> main() async {
  // Create and start the bridge
  A2ALog.info('Creating MCP Bridge');
  A2AMCPBridge a2aMcpBridge = A2AMCPBridge(
    name: 'A2A MCP Bridge Manual Test',
    version: '1.0.1',
  );
  try {
    await a2aMcpBridge
        .startServer(); // Set your port if you do not want the default
  } catch (e) {
    A2ALog.fatal('MCP Bridge failed to start $e');
    return;
  }
}
