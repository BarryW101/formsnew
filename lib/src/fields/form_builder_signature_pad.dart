import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:signature/signature.dart';

class FormBuilderSignaturePad extends FormBuilderField<Uint8List> {
  /// Controls the value of the signature pad.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final SignatureController controller;

  /// Width of the canvas
  final double width;

  /// Height of the canvas
  final double height;

  /// Color of the canvas
  final Color backgroundColor;

  /// Text to be displayed on the clear button which clears user input from the canvas
  final String clearButtonText;

  /// Styles the canvas border
  final Border border;

  FormBuilderSignaturePad({
    Key key,
    //From Super
    @required String name,
    FormFieldValidator<Uint8List> validator,
    Uint8List initialValue,
    bool readOnly = false,
    InputDecoration decoration = const InputDecoration(),
    ValueChanged<Uint8List> onChanged,
    ValueTransformer<Uint8List> valueTransformer,
    bool enabled = true,
    FormFieldSetter<Uint8List> onSaved,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    VoidCallback onReset,
    FocusNode focusNode,
    this.backgroundColor,
    this.clearButtonText,
    this.width,
    this.height = 200,
    this.controller,
    this.border,
  }) : super(
          key: key,
          initialValue: initialValue,
          name: name,
          validator: validator,
          valueTransformer: valueTransformer,
          onChanged: onChanged,
          readOnly: readOnly,
          autovalidateMode: autovalidateMode,
          onSaved: onSaved,
          enabled: enabled,
          onReset: onReset,
          decoration: decoration,
          builder: (FormFieldState<Uint8List> field) {
            final _FormBuilderSignaturePadState state = field;
            final theme = Theme.of(state.context);
            final localizations = MaterialLocalizations.of(state.context);

            return InputDecorator(
              decoration: decoration.copyWith(
                enabled: !state.readOnly,
                errorText: decoration?.errorText ?? field.errorText,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(border: border),
                    child: GestureDetector(
                      onVerticalDragUpdate: (_) {},
                      child: Signature(
                        controller: state.effectiveController,
                        width: width,
                        height: height,
                        backgroundColor: backgroundColor,
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(child: SizedBox()),
                      TextButton.icon(
                        onPressed: () {
                          state.effectiveController.clear();
                          field.didChange(null);
                        },
                        label: Text(
                          clearButtonText ?? localizations.cancelButtonLabel,
                          style: TextStyle(color: theme.errorColor),
                        ),
                        icon: Icon(Icons.clear, color: theme.errorColor),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );

  @override
  _FormBuilderSignaturePadState createState() =>
      _FormBuilderSignaturePadState();
}

class _FormBuilderSignaturePadState extends FormBuilderFieldState<Uint8List> {
  @override
  FormBuilderSignaturePad get widget => super.widget as FormBuilderSignaturePad;

  SignatureController get effectiveController =>
      widget.controller ?? _controller;

  final SignatureController _controller = SignatureController();

  @override
  void initState() {
    super.initState();
    effectiveController.addListener(() async {
      requestFocus();
      var _value = await effectiveController.toImage() != null
          ? await effectiveController.toPngBytes()
          : null;
      didChange(_value);
    });
  }

  @override
  void reset() {
    effectiveController?.clear();
    super.reset();
  }

/*@override
  void didUpdateWidget(FormBuilderSignaturePad oldWidget) {
    print("Widget did update...");
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && widget.controller == null) {
        _controller = SignatureController(points: oldWidget.controller.value);
      }
      if (widget.controller != null) {
        setValue(widget.controller.value);
        if (oldWidget.controller == null) _controller = null;
      }
    }
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (signatureController.value != value) {
      didChange(signatureController.value);
    }
  }*/
}
