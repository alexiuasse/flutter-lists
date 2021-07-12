import 'package:flutter/material.dart';
import 'package:lists/data/bloc/item_bloc.dart';

import 'list_bloc.dart';

// InheritedWidget objects have the ability to be
// searched for anywhere 'below' them in the widget tree.
class BlocProvider extends InheritedWidget {
  // these blocs are the objects that we want to access throughout the app
  final ListBloc? listBloc;
  final ItemBloc? itemBloc;

  /// Inherited widgets require a child widget
  /// which they implicitly return in the same way
  /// all widgets return other widgets in their 'Widget.build' method.
  const BlocProvider({
    Key? key,
    required Widget child,
    this.listBloc,
    this.itemBloc,
  }) : super(key: key, child: child);

  /// this method is used to access an instance of
  /// an inherited widget from lower in the tree.
  /// `BuildContext.dependOnInheritedWidgetOfExactType` is a built in
  /// Flutter method that does the hard work of traversing the tree for you
  static BlocProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BlocProvider>();
  }

  @override
  bool updateShouldNotify(BlocProvider old) {
    return true;
  }
}
