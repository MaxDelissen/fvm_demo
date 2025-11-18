import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fvm_demo/models/demo_data.dart';
import 'package:fvm_demo/remote_cards/remote_card_cubit.dart';
import 'package:fvm_demo/remote_cards/remote_card_state.dart';
import 'package:fvm_demo/services/remote_card_service.dart';
import 'package:rfw/rfw.dart';

class RemoteCardListPage extends StatelessWidget {
  const RemoteCardListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the cubit for the page, would happen in the blocprovider in real app.
    return BlocProvider<RemoteCardCubit>(
      create: (_) => RemoteCardCubit()..loadRemoteCard(),
      child: const RemoteCardListView(),
    );
  }
}

class RemoteCardListView extends StatelessWidget {
  const RemoteCardListView({super.key});

  // Might be usefull for navigation to specific settings.
  void _onRemoteEvent(String name, DynamicMap arguments) {
    if (name == 'card.tap') {
      debugPrint('Card tapped: ${arguments['id']}');
    } else {
      debugPrint('Unhandled remote event "$name": $arguments');
    }
  }

  @override
  Widget build(BuildContext context) {
    final RemoteCardCubit cubit = context.read<RemoteCardCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Remote Cards')),
      body: SafeArea(
        child: BlocBuilder<RemoteCardCubit, RemoteCardState>(
          builder: (BuildContext context, RemoteCardState state) {
            if (state.isLoading || state.status == RemoteCardStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.hasError) {
              return _buildError(context, cubit, state.errorMessage);
            }

            // Success state with data.
            return _buildList(context, cubit, state.cards);
          },
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    RemoteCardCubit cubit,
    List<DemoCardData> cards,
  ) {
    // Each row renders the same remote widget definition with different data.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (BuildContext context, int index) {
          // Get the card data for this item. (aka label, value)
          final DemoCardData card = cards[index];
          // Dynamic content is used to pass data into the remote widget.
          // 'card' is the object key used in the remote widget definition to access this data.
          // For example: data.card.label in the rfwtxt file.
          // toArguments converts the DemoCardData into a <String, Object> map.
          final DynamicContent content = DynamicContent()
            ..update('card', card.toArguments());
          // The actual 'iFrame'-ish widget that renders the remote widget.
          // Runtime contains the loaded remote widget library.
          // Data contains the dynamic content for this instance. (the card data we just mapped)
          // widget is the definition of the remote widget to render. It comes from RemoteCardService which links it to the definition in the downloaded library.
          // onEvent is a callback for events emitted by the remote widget. Has name and arguments. Name shows what event it is. (defined in the rfwtxt file), arguments contains any data sent with the event.
          return SizedBox(
            child: RemoteWidget(
              runtime: cubit.runtime,
              data: content,
              widget: RemoteCardService.remoteCardWidget,
              onEvent: _onRemoteEvent,
            ),
          );
        },
      ),
    );
  }

  // Error handling. Not important for the demo.
  Widget _buildError(
    BuildContext context,
    RemoteCardCubit cubit,
    String? errorMessage,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              errorMessage ?? 'Failed to load remote widget.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: cubit.loadRemoteCard,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
