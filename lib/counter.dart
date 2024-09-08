import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dynamo_counter/models/Count.dart';

final class Counter {
  final StreamController<Count> _streamController =
      StreamController<Count>.broadcast();
  StreamSubscription<GraphQLResponse<Count>>? _subscription;
  late Count _countCache;

  Stream<Count> get countStream => _streamController.stream;

  Future<void> initCounter() async {
    final remoteCounts = await _fetchCount();
    if (remoteCounts.isEmpty) {
      final count = await _createCount();
      _streamController.add(count);
      _countCache = count;
    } else {
      final count = remoteCounts.first;
      _streamController.add(count);
      _countCache = count;
    }
    subscribe();
  }

  void subscribe() {
    final request = ModelSubscriptions.onUpdate(Count.classType);
    final operation = Amplify.API.subscribe(request);
    _subscription = operation.listen(
      (event) {
        final result = event.data;
        if (result == null) return;
        _streamController.add(result);
        _countCache = result;
      },
    );
  }

  void unSubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> increment() async {
    final currentCount = _countCache;
    final newCount = currentCount.copyWith(value: currentCount.value! + 1);
    final request = ModelMutations.update(newCount);
    final response = await Amplify.API.mutate(request: request).response;
    safePrint(response);
    if (response.hasErrors) {
      for (var element in response.errors) {
        safePrint(element.message);
      }
    }
  }

  Future<void> decrement() async {
    final currentCount = _countCache;
    final newCount = currentCount.copyWith(value: currentCount.value! - 1);
    final request = ModelMutations.update(newCount);
    final response = await Amplify.API.mutate(request: request).response;
    safePrint(response);
    if (response.hasErrors) {
      for (var element in response.errors) {
        safePrint(element.message);
      }
    }
  }

  Future<List<Count>> _fetchCount() async {
    final request = ModelQueries.list(Count.classType);
    final response = await Amplify.API.query(request: request).response;

    return response.data?.items.whereType<Count>().toList() ?? List.empty();
  }

  Future<Count> _createCount() async {
    final request = ModelMutations.create(Count(value: 0));
    final response = await Amplify.API.mutate(request: request).response;
    return response.data!;
  }
}
