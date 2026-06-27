import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_flutter/bloc/reference_frame_bloc.dart';
import 'package:app_flutter/domain/reference_frame.dart';

class ReferenceFrameEditor extends StatefulWidget {
  final ReferenceFrameBloc bloc;
  final String nodeId;
  final bool alternateSystemsFeatureEnabled;

  const ReferenceFrameEditor({
    super.key,
    required this.bloc,
    required this.nodeId,
    this.alternateSystemsFeatureEnabled = false,
  });

  @override
  State<ReferenceFrameEditor> createState() => _ReferenceFrameEditorState();
}

class _ReferenceFrameEditorState extends State<ReferenceFrameEditor> {
  ReferenceFrame _frame = const ReferenceFrame();
  final _astronomicalController = TextEditingController();
  final _alternateController = TextEditingController();
  StreamSubscription<ReferenceFrameState>? _subscription;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _astronomicalController.text = _frame.astronomicalBody;
    _alternateController.text = _frame.alternateSystem ?? '';
    _subscription = widget.bloc.stream.listen((state) {
      if (!mounted) return;
      if (state is ReferenceFrameLoaded) {
        _frame = state.frame;
        _astronomicalController.text = _frame.astronomicalBody;
        _alternateController.text = _frame.alternateSystem ?? '';
      }
      setState(() {
        _errorMessage = state is ReferenceFrameError ? state.message : null;
      });
    });
    widget.bloc.load(widget.nodeId);
  }

  @override
  void dispose() {
    _astronomicalController.dispose();
    _alternateController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _onSave() async {
    final frame = ReferenceFrame(
      astronomicalBody: _astronomicalController.text,
      alternateSystem: widget.alternateSystemsFeatureEnabled
          ? (_alternateController.text.isEmpty ? null : _alternateController.text)
          : null,
    );
    await widget.bloc.save(
      widget.nodeId,
      frame,
      alternateSystemsFeatureEnabled: widget.alternateSystemsFeatureEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _astronomicalController,
            decoration: InputDecoration(
              labelText: 'Astronomical Body',
              border: const OutlineInputBorder(),
              errorText: _errorMessage,
            ),
          ),
          if (widget.alternateSystemsFeatureEnabled) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _alternateController,
              decoration: const InputDecoration(
                labelText: 'Alternate System',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _onSave,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
