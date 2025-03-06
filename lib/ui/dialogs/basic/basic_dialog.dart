import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'basic_dialog_model.dart';

class BasicDialog extends StackedView<BasicDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const BasicDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    BasicDialogModel viewModel,
    Widget? child,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              request.title ?? '',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(request.description ?? ''),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (request.secondaryButtonTitle != null)
                  TextButton(
                    onPressed: () =>
                        completer(DialogResponse(confirmed: false)),
                    child: Text(request.secondaryButtonTitle!),
                  ),
                TextButton(
                  onPressed: () => completer(DialogResponse(confirmed: true)),
                  child: Text(request.mainButtonTitle ?? 'OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  BasicDialogModel viewModelBuilder(BuildContext context) => BasicDialogModel();
}
