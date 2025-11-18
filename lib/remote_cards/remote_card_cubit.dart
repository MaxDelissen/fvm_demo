import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fvm_demo/models/demo_data.dart';
import 'package:fvm_demo/services/remote_card_service.dart';
import 'package:rfw/rfw.dart';

import 'remote_card_state.dart';

/// fetching of the the remote widget definition and building demo data.
class RemoteCardCubit extends Cubit<RemoteCardState> {
  RemoteCardCubit() : super(const RemoteCardState.initial());

  /// Service to load the remote widget definition.
  /// This one is made by us to encapsulate the logic of downloading and parsing the remote widget.
  final RemoteCardService _service = RemoteCardService();

  /// Repository to fetch demo data for the cards.
  /// In the real app this would be some data service or repository. (linked to api)
  /// This repository just returns randomised demo data.
  final DemoDataRepository _repository = const DemoDataRepository();

  /// The remote widget definition uri.
  /// The location where to .rfwtxt file is hosted.
  /// This would be changed to an endpoint, to support multiple remote widgets.
  final Uri _remoteWidgetUri =
      Uri.parse('http://192.168.5.123:8000/remote_card.rfwtxt');

  // Expose the runtime so the view can render RemoteWidget instances.
  // The runtime contains the loaded remote widget library.
  Runtime get runtime => _service.runtime;

  Future<void> loadRemoteCard() async {
    emit(const RemoteCardState.loading());
    try {
      // Load the remote widget definition. (see documentation in RemoteCardService)
      await _service.loadRemoteCard(_remoteWidgetUri);
      // Fetch demo data for the cards, not important for the demo.
      final List<DemoCardData> cards = _repository.fetchCards();
      emit(RemoteCardState.success(cards));
    } catch (error) {
      emit(RemoteCardState.failure('Failed to load remote widget: $error'));
    }
  }
}
