import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: NostrWidget(),
      ),
    );
  }
}

class NostrWidget extends StatefulWidget {
  const NostrWidget({super.key});

  @override
  State<NostrWidget> createState() => _NostrWidgetState();
}

class _NostrWidgetState extends State<NostrWidget> {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  _NostrWidgetState();
  final List<Map<String, dynamic>> messages = [
    {'createdAt': 0, "content": "Welcome!", "client": "ShiningStar"},
  ];
  final Image profileImage = const Image(
    width: 50,
    height: 50,
    image: NetworkImage(
        'https://image.nostr.build/33a0fd352b17f70ccb620c85e69a987ac22f2c0f6cb250e48a1aeba58cdbf354.png'),
  );

  final channel = WebSocketChannel.connect(Uri.parse('wss://relay.damus.io'));

  bool startAnimationState = false;

  Map<String, dynamic> userPictures = {};

  @override
  void initState() {
    Request requestWithFilter = Request(generate64RandomHexChars(), [
      Filter(
        kinds: [0, 1, 2],
        limit: 50,
      )
    ]);
    channel.sink.add(requestWithFilter.serialize());
    channel.stream.listen((payload) {
      try {
        final msg = Message.deserialize(payload);
        print(payload);
        if (msg.type == 'EVENT') {
          var newMessages = ({
            "createdAt": msg.message.createdAt,
            "content": msg.message.content,
            "client": _extractClientName(msg.message.tags),
          });
          _addNewMessage(newMessages);
        }
      } catch (err) {
        print(err.toString());
      }
    });
    super.initState();
  }

  // クライアント名抽出
  String _extractClientName(List<dynamic> tags) {
    for (var tag in tags) {
      if (tag is List && tag.isNotEmpty && tag[0] == "client") {
        return tag[1].toString();
      }
    }
    return "";
  }

  _addNewMessage(Map<String, dynamic> newMessage) {
    int insertIndex = 0; // 新しいメッセージをリストの先頭に挿入します。
    messages.insert(insertIndex, newMessage);
    listKey.currentState?.insertItem(insertIndex);
  }

  _buildAnimatedItem(
      Map<String, dynamic> messages, Animation<double> animation, int index) {
    var profileImageUrl = userPictures['nip05'.toString()] ??
        'https://image.nostr.build/33a0fd352b17f70ccb620c85e69a987ac22f2c0f6cb250e48a1aeba58cdbf354.png';
    return SizeTransition(
        sizeFactor: animation,
        child: (ListTile(
          leading: Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(),
            child: FittedBox(
              fit: BoxFit.fill,
              child: Image.network(profileImageUrl.toString()),
            ),
          ),
          title: Text(
            messages['content'],
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          subtitle: Text(messages['client'].toString(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              )),
        )));
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('ShiningStar demo')),
      body: Card(
        color: Colors.white,
        child: AnimatedList(
          key: listKey,
          initialItemCount: messages.length,
          itemBuilder: (context, index, animation) {
            return _buildAnimatedItem(messages[index], animation, index);
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Wassup, dude?',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      //TODO: send post
                      // if (_messageController.text.isNotEmpty) {
                      //   final message = Message(
                      //     generate64RandomHexChars(),
                      //     _messageController.text,
                      //     [Tag("client", "ShiningStar")],
                      //   );
                      //   channel.sink.add(message.serialize());
                      //   _messageController.clear();}
                    },
                  ),
                ],
              ))),
    );
  }
}
