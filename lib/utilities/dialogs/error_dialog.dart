import 'package:flutter/cupertino.dart';
import 'package:mynotes/utilities/dialogs/generic_dialogs.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text
  ) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error occurred',
    content: text,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}