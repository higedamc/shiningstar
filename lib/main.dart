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
    {'createdAt': 0, "content": "Welcome!"},
  ];
  final Image profileImage = const Image(
    width: 50,
    height: 50,
    image: NetworkImage(
        // 'https://1.bp.blogspot.com/-BnPjHnaxR8Q/YEGP_e4vImI/AAAAAAABdco/2i7s2jl14xUhqtxlR2P3JIsFz76EDZv3gCNcBGAsYHQ/s180-c/buranko_boy_smile.png'),
        'https://image.nostr.build/33a0fd352b17f70ccb620c85e69a987ac22f2c0f6cb250e48a1aeba58cdbf354.png'),
  );

  final channel = WebSocketChannel.connect(Uri.parse('wss://relay.damus.io'));

  bool startAnimationState = false;

  @override
  void initState() {
    Request requestWithFilter = Request(generate64RandomHexChars(), [
      Filter(
        kinds: [1],
        limit: 50,
      )
    ]);
    channel.sink.add(requestWithFilter.serialize());
    channel.stream.listen((payload) {
      try {
        final _msg = Message.deserialize(payload);
        print(payload);
        if (_msg.type == 'EVENT') {
          setState(() {
            var newMessages = ({
              "createdAt": _msg.message.createdAt,
              "content": _msg.message.content
            });
            // messages.sort((a, b) {
            //   return b['createdAt'].compareTo(a['createdAt']);
            // });
            _addNewMessage(newMessages);
          });
        }
      } catch (err) {}
    });
    super.initState();
  }

  _addNewMessage(Map<String, dynamic> newMessage) {
    int insertIndex = 0; // 新しいメッセージをリストの先頭に挿入します。
    messages.insert(insertIndex, newMessage);
    listKey.currentState?.insertItem(insertIndex);
  }

  _buildAnimatedItem(
      Map<String, dynamic> messag, Animation<double> animation, int index) {
    return SizeTransition(
        sizeFactor: animation,
        child: (ListTile(
          leading: Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(),
            child: FittedBox(
              fit: BoxFit.fill,
              child: Image.network(
                  'https://image.nostr.build/33a0fd352b17f70ccb620c85e69a987ac22f2c0f6cb250e48a1aeba58cdbf354.png'),
            ),
          ),
        )));
  }

  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          null;
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
