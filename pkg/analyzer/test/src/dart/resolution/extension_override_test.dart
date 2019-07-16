// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'driver_resolution.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ExtensionOverrideTest);
  });
}

@reflectiveTest
class ExtensionOverrideTest extends DriverResolutionTest {
  ExtensionElement extension;
  ExtensionOverride extensionOverride;

  @override
  AnalysisOptionsImpl get analysisOptions => AnalysisOptionsImpl()
    ..contextFeatures = new FeatureSet.forTesting(
        sdkVersion: '2.3.0', additionalFeatures: [Feature.extension_methods]);

  void findDeclarationAndOverride(
      {@required String declarationName,
      @required String overrideSearch,
      String declarationUri}) {
    if (declarationUri == null) {
      ExtensionDeclaration declaration =
          findNode.extensionDeclaration('extension $declarationName');
      extension = declaration?.declaredElement as ExtensionElement;
    } else {
      extension =
          findElement.importFind(declarationUri).extension_(declarationName);
    }
    extensionOverride = findNode.extensionOverride(overrideSearch);
  }

  test_getter_noPrefix_noTypeArguments() async {
    await assertNoErrorsInCode('''
class A {}
extension E on A {
  int get g => 0;
}
void f(A a) {
  E(a).g;
}
''');
    findDeclarationAndOverride(declarationName: 'E ', overrideSearch: 'E(a)');
    validateOverride();
    validatePropertyAccess();
  }

  test_getter_noPrefix_typeArguments() async {
    await assertNoErrorsInCode('''
class A {}
extension E<T> on A {
  int get g => 0;
}
void f(A a) {
  E<int>(a).g;
}
''');
    findDeclarationAndOverride(declarationName: 'E', overrideSearch: 'E<int>');
    validateOverride(typeArguments: [intType]);
    validatePropertyAccess();
  }

  test_getter_prefix_noTypeArguments() async {
    newFile('/test/lib/lib.dart', content: '''
class A {}
extension E on A {
  int get g => 0;
}
''');
    await assertNoErrorsInCode('''
import 'lib.dart' as p;
void f(p.A a) {
  p.E(a).g;
}
''');
    findDeclarationAndOverride(
        declarationName: 'E',
        declarationUri: 'package:test/lib.dart',
        overrideSearch: 'E(a)');
    validateOverride();
    validatePropertyAccess();
  }

  test_getter_prefix_typeArguments() async {
    newFile('/test/lib/lib.dart', content: '''
class A {}
extension E<T> on A {
  int get g => 0;
}
''');
    await assertNoErrorsInCode('''
import 'lib.dart' as p;
void f(p.A a) {
  p.E<int>(a).g;
}
''');
    findDeclarationAndOverride(
        declarationName: 'E',
        declarationUri: 'package:test/lib.dart',
        overrideSearch: 'E<int>');
    validateOverride(typeArguments: [intType]);
    validatePropertyAccess();
  }

  test_method_noPrefix_noTypeArguments() async {
    await assertNoErrorsInCode('''
class A {}
extension E on A {
  void m() {}
}
void f(A a) {
  E(a).m();
}
''');
    findDeclarationAndOverride(declarationName: 'E ', overrideSearch: 'E(a)');
    validateOverride();
    validateInvocation();
  }

  test_method_noPrefix_typeArguments() async {
    await assertNoErrorsInCode('''
class A {}
extension E<T> on A {
  void m() {}
}
void f(A a) {
  E<int>(a).m();
}
''');
    findDeclarationAndOverride(declarationName: 'E', overrideSearch: 'E<int>');
    validateOverride(typeArguments: [intType]);
    validateInvocation();
  }

  test_method_prefix_noTypeArguments() async {
    newFile('/test/lib/lib.dart', content: '''
class A {}
extension E on A {
  void m() {}
}
''');
    await assertNoErrorsInCode('''
import 'lib.dart' as p;
void f(p.A a) {
  p.E(a).m();
}
''');
    findDeclarationAndOverride(
        declarationName: 'E',
        declarationUri: 'package:test/lib.dart',
        overrideSearch: 'E(a)');
    validateOverride();
    validateInvocation();
  }

  test_method_prefix_typeArguments() async {
    newFile('/test/lib/lib.dart', content: '''
class A {}
extension E<T> on A {
  void m() {}
}
''');
    await assertNoErrorsInCode('''
import 'lib.dart' as p;
void f(p.A a) {
  p.E<int>(a).m();
}
''');
    findDeclarationAndOverride(
        declarationName: 'E',
        declarationUri: 'package:test/lib.dart',
        overrideSearch: 'E<int>');
    validateOverride(typeArguments: [intType]);
    validateInvocation();
  }

  test_setter_noPrefix_noTypeArguments() async {
    await assertNoErrorsInCode('''
class A {}
extension E on A {
  set s(int x) {}
}
void f(A a) {
  E(a).s = 0;
}
''');
    findDeclarationAndOverride(declarationName: 'E ', overrideSearch: 'E(a)');
    validateOverride();
    validatePropertyAccess();
  }

  test_setter_noPrefix_typeArguments() async {
    await assertNoErrorsInCode('''
class A {}
extension E<T> on A {
  set s(int x) {}
}
void f(A a) {
  E<int>(a).s = 0;
}
''');
    findDeclarationAndOverride(declarationName: 'E', overrideSearch: 'E<int>');
    validateOverride(typeArguments: [intType]);
    validatePropertyAccess();
  }

  test_setter_prefix_noTypeArguments() async {
    newFile('/test/lib/lib.dart', content: '''
class A {}
extension E on A {
  set s(int x) {}
}
''');
    await assertNoErrorsInCode('''
import 'lib.dart' as p;
void f(p.A a) {
  p.E(a).s = 0;
}
''');
    findDeclarationAndOverride(
        declarationName: 'E',
        declarationUri: 'package:test/lib.dart',
        overrideSearch: 'E(a)');
    validateOverride();
    validatePropertyAccess();
  }

  test_setter_prefix_typeArguments() async {
    newFile('/test/lib/lib.dart', content: '''
class A {}
extension E<T> on A {
  set s(int x) {}
}
''');
    await assertNoErrorsInCode('''
import 'lib.dart' as p;
void f(p.A a) {
  p.E<int>(a).s = 0;
}
''');
    findDeclarationAndOverride(
        declarationName: 'E',
        declarationUri: 'package:test/lib.dart',
        overrideSearch: 'E<int>');
    validateOverride(typeArguments: [intType]);
    validatePropertyAccess();
  }

  test_setterAndGetter_noPrefix_noTypeArguments() async {
    await assertNoErrorsInCode('''
class A {}
extension E on A {
  int get s => 0;
  set s(int x) {}
}
void f(A a) {
  E(a).s += 0;
}
''');
    findDeclarationAndOverride(declarationName: 'E ', overrideSearch: 'E(a)');
    validateOverride();
    validatePropertyAccess();
  }

  test_setterAndGetter_noPrefix_typeArguments() async {
    await assertNoErrorsInCode('''
class A {}
extension E<T> on A {
  int get s => 0;
  set s(int x) {}
}
void f(A a) {
  E<int>(a).s += 0;
}
''');
    findDeclarationAndOverride(declarationName: 'E', overrideSearch: 'E<int>');
    validateOverride(typeArguments: [intType]);
    validatePropertyAccess();
  }

  test_setterAndGetter_prefix_noTypeArguments() async {
    newFile('/test/lib/lib.dart', content: '''
class A {}
extension E on A {
  int get s => 0;
  set s(int x) {}
}
''');
    await assertNoErrorsInCode('''
import 'lib.dart' as p;
void f(p.A a) {
  p.E(a).s += 0;
}
''');
    findDeclarationAndOverride(
        declarationName: 'E',
        declarationUri: 'package:test/lib.dart',
        overrideSearch: 'E(a)');
    validateOverride();
    validatePropertyAccess();
  }

  test_setterAndGetter_prefix_typeArguments() async {
    newFile('/test/lib/lib.dart', content: '''
class A {}
extension E<T> on A {
  int get s => 0;
  set s(int x) {}
}
''');
    await assertNoErrorsInCode('''
import 'lib.dart' as p;
void f(p.A a) {
  p.E<int>(a).s += 0;
}
''');
    findDeclarationAndOverride(
        declarationName: 'E',
        declarationUri: 'package:test/lib.dart',
        overrideSearch: 'E<int>');
    validateOverride(typeArguments: [intType]);
    validatePropertyAccess();
  }

  void validateInvocation() {
    MethodInvocation invocation = extensionOverride.parent as MethodInvocation;
    Element resolvedElement = invocation.methodName.staticElement;
    expect(resolvedElement, extension.getMethod('m'));
  }

  void validateOverride({List<DartType> typeArguments}) {
    expect(extensionOverride.extensionName.staticElement, extension);
    if (typeArguments == null) {
      expect(extensionOverride.typeArguments, isNull);
    } else {
      expect(
          extensionOverride.typeArguments.arguments
              .map((annotation) => annotation.type),
          unorderedEquals(typeArguments));
    }
    expect(extensionOverride.argumentList.arguments, hasLength(1));
  }

  void validatePropertyAccess() {
    PropertyAccess access = extensionOverride.parent as PropertyAccess;
    Element resolvedElement = access.propertyName.staticElement;
    PropertyAccessorElement expectedElement;
    if (access.propertyName.inSetterContext()) {
      expectedElement = extension.getSetter('s');
      if (access.propertyName.inGetterContext()) {
        PropertyAccessorElement expectedGetter = extension.getGetter('s');
        Element actualGetter =
            access.propertyName.auxiliaryElements.staticElement;
        expect(actualGetter, expectedGetter);
      }
    } else {
      expectedElement = extension.getGetter('g');
    }
    expect(resolvedElement, expectedElement);
  }
}