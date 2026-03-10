import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class FSentenceEditor extends StatefulWidget {
  const FSentenceEditor({super.key});

  @override
  State<FSentenceEditor> createState() => _FSentenceEditorState();
}

class _FSentenceEditorState extends State<FSentenceEditor> {
  // Kontroler koji drži sav tekst i stilove
  final QuillController _controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('f.Sentence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // TOOLBAR: Ovde su tvoja dugmad (Bold, Italic, Liste...)
          QuillSimpleToolbar(
            controller: _controller,
            QuillSimpleToolbarConfigurations(
              showFontSize: false,
              showFontFamily: false,
              showSearchButton: false,
              showSubscript: false,
              showSuperscript: false,
              showSmallButton: false,
              showInlineCode: false,
              showLink: true,
              showUndo: true,
              showRedo: true,
              multiRowsDisplay: false,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: QuillEditor.basic(
                controller: _controller,
                configurations: const QuillEditorConfigurations(
                  placeholder: 'Počni da pišeš...',
                  readOnly: false,
                  autoFocus: true,
                  expands: true,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
