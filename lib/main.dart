import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dynamo_counter/amplify_outputs.dart';
import 'package:dynamo_counter/counter.dart';
import 'package:dynamo_counter/models/ModelProvider.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  final api = AmplifyAPI(
    options: APIPluginOptions(
      modelProvider: ModelProvider.instance,
    ),
  );
  await Amplify.addPlugin(api);
  await Amplify.configure(amplifyConfig);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Counter _counter = Counter();

  @override
  void initState() {
    super.initState();
    _counter.initCounter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: StreamBuilder(
          stream: _counter.countStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!;
              return Center(
                child: Text(
                  data.value.toString(),
                  style: const TextStyle(fontSize: 20),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
          }),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _counter.decrement,
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _counter.increment,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _counter.unSubscribe();
    super.dispose();
  }
}
