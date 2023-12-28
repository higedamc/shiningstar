import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessageSendPage extends StatefulWidget {
  WebSocketChannel channel;

  MessageSendPage(this.channel, {super.key});



  @override
  _MessageSendPageState createState() => _MessageSendPageState(channel);
}

class _MessageSendPageState extends State<MessageSendPage> {
  WebSocketChannel channel;
  String _text = '';
  String _privKey = ''; // 秘密鍵

  _MessageSendPageState(this.channel);

  // テキストフィールドと _privKey を合わせる
  void _handleText(String e) {
    setState(() {
      _text = e;
    });
  }

  void _handleKey(String e) {
    setState(() {
      _privKey = e;
    });
  }

   void _sendMessage() {
    if (_privKey == '' && _text == '') return; // 鍵かテキストが空欄なら送信しない
    Event event = Event.from(
      kind: 1,
      content: _text,
      privkey: _privKey,
      tags: [],
    ); // Event の作成
    channel.sink.add(event.serialize()); // イベントを追加する。
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メッセージ送信'),
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _sendMessage(),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '秘密鍵',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  enabled: true,
                  onChanged: _handleKey,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'メッセージ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  enabled: true,
                  onChanged: _handleText,
                  minLines: 3,
                  maxLines: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}