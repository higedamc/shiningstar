import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:shining_star/messageSendPage.dart';
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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
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
  _NostrWidgetState();
  final List<Map<String, dynamic>> messages = [
    {'createdAt': 0, "content": "これが最初のメッセージ"},
    {'createdAt': 1, "content": "2つ目のメッセージ"},
    {'createdAt': 2, "content": "これが3つ目だ!"},
  ];
  final Image profileImage = const Image(
    width: 50, // いい感じに大きさ調節しています。
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
            messages.add({
              "createdAt": _msg.message.createdAt,
              "content": _msg.message.content
            });
            messages.sort((a, b) {
              return b['createdAt'].compareTo(a['createdAt']);
            });
          });
        }
      } catch (err) {}
    });
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        startAnimationState = true;
      });
    });
  }

  Widget messageWidget(int index) {
    return Card(
      // clipBehavior: Clip.antiAliasWithSaveLayer,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(20),
      // ),
      color: Colors.white,
      child: ListTile(
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
        // CircleAvatar(
        //   backgroundImage: profileImage.image,
        //   minRadius: 30,
        //   maxRadius: 40,
        // ),

        title: Text(
          messages[index]['content'],
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          // style: const TextStyle(
          //   color: Colors.black,
          //   backgroundColor: Colors.white),
        ),
      ),
    );
  }

  // Widget messageWidget(int index) {
  //   return Container(
  //     decoration: const BoxDecoration(
  //       border: Border(
  //         bottom: BorderSide(color: Colors.black12, width: 1),
  //       ),
  //     ),
  //     margin: const EdgeInsets.fromLTRB(10, 0, 10, 0), // 下線の左右に余白を作りたかった
  //     padding: const EdgeInsets.fromLTRB(0, 10, 0, 10), // いい感じに上下の余白を作ります。
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start, // 上詰めにする
  //       children: [
  //         ClipRRect(
  //           // プロフィール画像を丸くします。
  //           borderRadius: BorderRadius.circular(25),
  //           child: profileImage,
  //         ),
  //         Expanded(
  //           child: Padding(
  //             padding: const EdgeInsets.only(left: 15),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Text('吾輩は猫である', // 名前です。
  //                     style: TextStyle(fontWeight: FontWeight.bold)),
  //                 Text(
  //                   messages[index]["content"],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ShiningStar demo')),
      body: Center(
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return messageWidget(index);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MessageSendPage(channel),
                fullscreenDialog: true),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
