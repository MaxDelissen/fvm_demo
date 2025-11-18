import 'dart:async';

import 'package:fvm_demo/services/remote_widget_fetch_service.dart';
import 'package:rfw/formats.dart';
import 'package:rfw/rfw.dart';

/// Keeps the RFW runtime alive for the whole app and knows how to hydrate it
/// with the remote card widget library.
///
/// In the RFW (Remote Flutter Widgets) world you:
/// 1. Register local widget libraries such as `core/widgets` and
///    `material/widgets` so that remote code can reference standard widgets.
/// 2. Download a `.rfwtxt` file which declares a *remote* widget library.
/// 3. Parse that file and push it into a shared [Runtime].
/// 4. Render widgets by asking the runtime for a fully qualified widget name.
///
/// This service hides those steps behind a single [loadRemoteCard] call so any
/// UI code can just use [remoteCardWidget] with the updated [runtime].
class RemoteCardService {
  RemoteCardService({RemoteWidgetFetchService? fetchService})
      : _fetchService = fetchService ?? RemoteWidgetFetchService();

  // Remote runtime identifiers at a glance:
  // - `_remoteName` labels the library we download from the server.
  static const LibraryName _remoteName =
      LibraryName(<String>['remote', 'card']);

  /// `coreName`/`materialName` point to the built-in widget libraries that
  /// ship inside the app. This makes these available to remote code.
  /// I need to look further into how we can make custom local libraries available for the remote code.
  /// For now, core and material are sufficient to build basic UIs.
  /// Core has most of the layout and primitive widgets (Row, Column, Text, Container, etc.)
  /// Material has material design widgets (Buttons, AppBar, Cards, etc.)
  static const LibraryName coreName = LibraryName(<String>['core', 'widgets']);
  static const LibraryName materialName =
      LibraryName(<String>['material', 'widgets']);

  /// The entry point we ask the runtime to render. (which we use in the view)
  /// CardEntry is the widget defined in the remote rfwtxt file.
  /// We access it via remoteCardService.remoteCardWidget.
  /// _remoteName is the library name defined above.
  static const FullyQualifiedWidgetName remoteCardWidget =
      FullyQualifiedWidgetName(_remoteName, 'CardEntry');

  /// Simple http client to download the remote widget file.
  /// Split this to keep networking code separate from RFW-specific logic.
  final RemoteWidgetFetchService _fetchService;

  /// Shared RFW runtime that stores both local (core/material) and remote libs.
  final Runtime runtime = Runtime();

  /// Ensures we only register the local widget libraries once per app run.
  bool _registeredLocals = false;

  /// Downloads a remote RFW library, parses it, and installs it into [runtime].
  ///
  /// After this completes, the [remoteCardWidget] entry point becomes available
  /// for every [RemoteWidget] instance that uses the same runtime.
  Future<void> loadRemoteCard(Uri uri) async {
    // The literal `.rfwtxt` contents downloaded from the given [uri].
    final String libraryText = await _fetchService.fetchLibrary(uri);

    // Make sure local libraries are registered only once.
    if (!_registeredLocals) {
      // Wire up the built-in widget libraries so the remote code can reference
      // common Flutter primitives (layout, text, buttons, etc.).
      runtime
        ..update(coreName, createCoreWidgets())
        ..update(materialName, createMaterialWidgets());
      _registeredLocals = true;
    }

    // Parse the textual `.rfwtxt` library and update the runtime with the
    // widgets declared under the `remote.card` namespace.
    runtime.update(_remoteName, parseLibraryFile(libraryText));
  }
}
