import 'package:fvm_demo/models/demo_data.dart';

// Simple state with just 1 class.
enum RemoteCardStatus { initial, loading, success, failure }

class RemoteCardState {
  const RemoteCardState._({
    required this.status,
    this.cards = const <DemoCardData>[],
    this.errorMessage,
  });

  const RemoteCardState.initial() : this._(status: RemoteCardStatus.initial);

  const RemoteCardState.loading() : this._(status: RemoteCardStatus.loading);

  // Contains the fetched cards on success.
  // These cards are just the data, the remote widget definition is handled in the cubit/service.
  const RemoteCardState.success(List<DemoCardData> cards)
      : this._(status: RemoteCardStatus.success, cards: cards);

  const RemoteCardState.failure(String message)
      : this._(status: RemoteCardStatus.failure, errorMessage: message);

  final RemoteCardStatus status;
  final List<DemoCardData> cards;
  final String? errorMessage;

  // Convenience booleans used by the view layer.
  bool get isLoading => status == RemoteCardStatus.loading;
  bool get hasError => status == RemoteCardStatus.failure;
  bool get hasData => cards.isNotEmpty;
}
