import 'package:ddp/ddp.dart';
import 'package:test/test.dart';

void main() {
  test('IdManager', () {
    print(16.toRadixString(16));
  });


  final client = DdpClient('DdpClientTest', 'ws://localhost:3000/websocket', 'http://localhost');
  test('DdpClientTest', ()  async {
   
    await client.connect();
    await Future.delayed(Duration(minutes: 2));
  }, timeout: Timeout(Duration(minutes: 2)));
}
