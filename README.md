# Remote Flutter Widget Demo

This app demonstrates how to render UI that is delivered at runtime via the [`rfw`](https://pub.dev/packages/rfw) package. On launch it downloads a Remote Flutter Widget definition from `http://192.168.5.123:8000/remote_card.rfwtxt`, feeds it locally generated `{id, label, value, valueText}` data, and displays the resulting cards in a list. When a card is tapped, the remote widget emits an event that is logged by the Flutter host.

## Project layout

- `remote_card.rfwtxt` – remote widget library served to the client (defines `CardEntry`)
- `lib/main.dart` – bootstraps the app and shows `RemoteCardListPage`
- `lib/models/demo_data.dart` – produces synthetic card data + maps it into RFW arguments
- `lib/services/remote_widget_fetch_service.dart` – pure HTTP client that downloads `.rfwtxt`
- `lib/services/remote_card_service.dart` – owns the RFW `Runtime`, registers local libs, parses remote libs
- `lib/remote_cards/remote_card_cubit.dart` – orchestrates loading the remote widget + demo data
- `lib/remote_cards/remote_card_state.dart` – simple status/data container for the cubit
- `lib/remote_cards/remote_card_list_view.dart` – Flutter widgets that render the list and handle events

## Running the demo

1. **Expose the remote widget file** (from the project root):

   ```bash
   python3 -m http.server 8000
   ```

   The cubit currently points to `http://192.168.5.123:8000/remote_card.rfwtxt`. Adjust `_remoteWidgetUri` in `lib/remote_cards/remote_card_cubit.dart` if your server runs elsewhere.

   Remember that if you run the app on a mobile device, it will not be able to access the localhost of the host device directly.

2. **Run the Flutter app** in another terminal:

   ```bash
   flutter run
   ```

When the app starts you should see a vertically scrolling list of full-width cards. Tapping a card triggers the remote event `card.tap`, and the host prints the card ID to the debug console. If the widget download fails, the app shows an error view with a **Retry** button.

## How it works

1. `RemoteCardListPage` creates a `RemoteCardCubit` when the screen loads.
2. The cubit calls `RemoteWidgetFetchService`, which downloads `remote_card.rfwtxt` over HTTP.
3. `RemoteCardService` takes that text, registers the built-in core/material widget libraries (once), and parses the remote `CardEntry` widget into the shared RFW `Runtime`.
4. `DemoDataRepository` generates `{id, label, value, valueText}` maps for a handful of cards.
5. For every card, `RemoteWidget` receives the shared runtime plus a `DynamicContent` payload (the map above) and renders the remote `CardEntry` widget as if it were local Flutter code.
6. When a user taps a card, the remote widget fires `card.tap`, which bubbles back to `_onRemoteEvent` so the host app can react (log, navigate, call an API, etc.).

## Limitations

- Remote widgets can only compose the local widget libraries you register (core + material here).
  - The above mentioned libraries are made by the Flutter developers.
  - Any new libraries need to be written from scratch, including any variables, conversions, etc.
  - Best would be to compose UI with only built-in (core + material) widgets.
- Pass-through data is picky with non-text values. A double or int cannot be inserted into text using toString(), string interpolation or similar methods. These should be converted to text before sending them over.
- Remote events cannot do any pre-processing of data beforehand. Practically, these will only ever send back the id of the widget which sent the event.
- Doing any logic inside of the remote widgets is really hard, and not recommended. Use only for 100% pure view widgets.
- Network failures leave you with the last successfully downloaded library. This sample just shows a retry button, but real apps should persist the library or ship a baked-in fallback.
- The demo pulls `.rfwtxt` over plain HTTP for readability. Production setups typically serve the faster binary `.rfw` format, but this requires compiling the files beforehand.

## How to implement

To implement these widgets into the real app there will be some extra steps required.

- The `.rfwtxt` or `.rfw` files will have to be stored on a server with an endpoint for getting the correct type (list, graph, gauge) and version. `/api/widget/graph/2.3`.
- The existing widgets will have to be either manually converted, or might be able to be automatically converted to the rfw format. Make sure to only make use of built-in Flutter widgets, or by building a custom rfw library.
- Data needs to be converted to the proper format before being sent over. This will likely need to happen on the client side; especially if the server returns raw data like talked about some time back.
- New versions will need to be compiled or written again.
- The client will need to keep track of the data for all widgets, as they will not be able to do so themselves.
