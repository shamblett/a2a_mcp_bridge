@TestOn('vm')
library;

import 'package:test/test.dart';

import 'package:mcp_dart/mcp_dart.dart';

class AuthProvider implements OAuthClientProvider {
  /// Get current tokens if available
  @override
  Future<OAuthTokens?> tokens() async =>
      OAuthTokens(accessToken: '', refreshToken: '');

  /// Redirect to authorization endpoint
  @override
  Future<void> redirectToAuthorization() async {
    return;
  }
}

final implementation = Implementation(
  name: 'A2A MCP Bridge Manual Test',
  version: '1.0.1',
);
final options = ClientOptions();
final client = Client(implementation, options: options);

final serverUrl = Uri.parse('http://localhost:3080/mcp');
final serverOptions = StreamableHttpClientTransportOptions(
  authProvider: AuthProvider(),
);
final clientTransport = StreamableHttpClientTransport(
  serverUrl,
  opts: serverOptions,
);

const agentUrl = 'http://localhost:9999';

Future<void> main() async {
  // Start the client
  await client.connect(clientTransport);

  test('Server Version', () async {
    final serverVersion = client.getServerVersion();
    expect(serverVersion, isNotNull);
    expect(serverVersion?.name, 'A2A MCP Bridge Manual Test');
    expect(serverVersion?.version, '1.0.1');
  });
  test('List Tools', () async {
    final tools = await client.listTools();
    expect(tools.tools.length, 6);
    expect(tools.tools.first.name, 'register_agent');
    expect(tools.tools[1].name, 'list_agents');
    expect(tools.tools[2].name, 'unregister_agent');
    expect(tools.tools[3].name, 'send_message');
    expect(tools.tools[4].name, 'get_task_result');
    expect(tools.tools.last.name, 'cancel_task');
  });
  test('List Agents', () async {
    final params = CallToolRequest(name: 'list_agents');
    final result = await client.callTool(params);
    expect(result.isError, isFalse);
    final content = result.structuredContent;
    expect(content!['result'] is Map, isTrue);
    final res = content['result'];
    expect(res['result'] is List, isTrue);
    expect(res['result'].first is String, isTrue);
  });

  test('Register Agent Agent contacted', () async {
    final params = CallToolRequest(
      name: 'register_agent',
      arguments: {'url': agentUrl},
    );
    final result = await client.callTool(params);
    expect(result.isError, isFalse);
    final content = result.structuredContent;
    expect(content!['agent_name'], 'Hello World Agent');
    expect(content['url'], agentUrl);
    final params1 = CallToolRequest(name: 'list_agents');
    final result1 = await client.callTool(params1);
    expect(result1.isError, isFalse);
    final content1 = result1.structuredContent;
    expect(content1?.length, 1);
    expect(content1!['result'], {
      'result': ['Hello World Agent'],
    });
  });
  test('Send Message - valid arguments', () async {
    final paramsReg = CallToolRequest(
      name: 'register_agent',
      arguments: {'url': agentUrl},
    );
    await client.callTool(paramsReg);
    final params = CallToolRequest(
      name: 'send_message',
      arguments: {'url': agentUrl, 'message': 'Hello agent'},
    );
    final result = await client.callTool(params);
    expect(result.isError, isFalse);
    final content = result.structuredContent;
    expect(content!['task_id'] is String, isTrue);
    expect(
      content['response'],
      'Response from <Hello World Agent> agent\n\nHello World',
    );
  });
  test('Unregister Agent - valid arguments', () async {
    final params = CallToolRequest(
      name: 'unregister_agent',
      arguments: {'url': 'http://localhost:9999'},
    );
    final result = await client.callTool(params);
    expect(result.isError, isFalse);
    final content = result.structuredContent;
    expect(
      content!['agent_name'],
      anyOf('Hello World Agent', 'Agent Not Found'),
    );
  });
  test('Get Task Result - valid arguments', () async {
    final paramsReg = CallToolRequest(
      name: 'register_agent',
      arguments: {'url': agentUrl},
    );
    await client.callTool(paramsReg);
    var params = CallToolRequest(
      name: 'send_message',
      arguments: {'url': agentUrl, 'message': 'Hello agent'},
    );
    var result = await client.callTool(params);
    expect(result.isError, isFalse);
    var content = result.structuredContent;
    final taskId = content!['task_id'];
    params = CallToolRequest(
      name: 'get_task_result',
      arguments: {'task_id': taskId},
    );
    result = await client.callTool(params);
    expect(result.isError, isFalse);
    final content1 = result.structuredContent;
    expect(
      content1!['message'],
      'Response from <Hello World Agent> agent\n\nHello World',
    );
  });
  test('Cancel Task - valid arguments', () async {
    final paramsReg = CallToolRequest(
      name: 'register_agent',
      arguments: {'url': agentUrl},
    );
    await client.callTool(paramsReg);
    var params = CallToolRequest(
      name: 'send_message',
      arguments: {'url': agentUrl, 'message': 'Hello agent'},
    );
    var result = await client.callTool(params);
    expect(result.isError, isFalse);
    var content = result.structuredContent;
    final taskId = content!['task_id'];
    params = CallToolRequest(
      name: 'cancel_task',
      arguments: {'task_id': taskId},
    );
    result = await client.callTool(params);
    expect(result.isError, isFalse);
    final content1 = result.structuredContent;
    expect(content1!['task_id'], taskId);
  });
}
