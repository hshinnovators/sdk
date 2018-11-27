// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/lsp_protocol/protocol_generated.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'server_abstract.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ReferencesTest);
  });
}

@reflectiveTest
class ReferencesTest extends AbstractLspAnalysisServerTest {
  test_references() async {
    final contents = '''
    f^oo() {
      [[foo]]();
    }
    ''';

    await initialize();
    await openFile(mainFileUri, withoutMarkers(contents));
    final res = await getReferences(mainFileUri, positionFromMarker(contents));

    expect(res, hasLength(1));
    Location loc = res.single;
    expect(loc.range, equals(rangeFromMarkers(contents)));
    expect(loc.uri, equals(mainFileUri.toString()));
  }

  test_references_across_files() async {
    final mainContents = '''
    import 'referenced.dart';

    main() {
      [[foo]]();
    }
    ''';

    final referencedContents = '''
    /// Ensure the function is on a line that
    /// does not exist in the mainContents file
    /// to ensure we're translating offsets to line/col
    /// using the correct files LineInfo
    /// ...
    /// ...
    /// ...
    /// ...
    /// ...
    ^foo() {}
    ''';

    final referencedFileUri =
        Uri.file(join(projectFolderPath, 'lib', 'referenced.dart'));

    await initialize();
    await openFile(mainFileUri, withoutMarkers(mainContents));
    await openFile(referencedFileUri, withoutMarkers(referencedContents));
    final res = await getReferences(
        referencedFileUri, positionFromMarker(referencedContents));

    expect(res, hasLength(1));
    Location loc = res.single;
    expect(loc.range, equals(rangeFromMarkers(mainContents)));
    expect(loc.uri, equals(mainFileUri.toString()));
  }
}