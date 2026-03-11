//  f.Sentence - More than text editor.
    Copyright (C) 2026  Zoran Jeremić

//  This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

//  This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';
import 'package:parchment/parchment.dart';
import 'package:hive/hive.dart';

class DocumentViewerScreen extends StatefulWidget {
  final String? fileName;
  const DocumentViewerScreen({super.key, this.fileName});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  FleatherController? _controller;
  late Box _box;
  final String _defaultDocName = "novo_pisanje";
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _box = Hive.box('documents_box');
    _loadDocument();
    _controller!.addListener(_autoSave);
  }

  void _loadDocument() {
    final String key = widget.fileName ?? _defaultDocName;
    final String? savedData = _box.get(key);

    if (savedData != null) {
      final doc = ParchmentDocument.fromJson(jsonDecode(savedData));
      _controller = FleatherController(document: doc);
    } else {
      _controller = FleatherController();
    }
  }

  void _autoSave() {
    final String key = widget.fileName ?? _defaultDocName;
    final deltaData = jsonEncode(_controller!.document.toDelta());
    _box.put(key, deltaData);
    debugPrint("Document saved at: ${DateTime.now()}");
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardVisible = bottomInset > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false, 
      appBar: AppBar(
        title: Text(
          widget.fileName ?? 'f.Sentence',
          style: const TextStyle(fontWeight: FontWeight.w300),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FleatherEditor(
                controller: _controller!,
                focusNode: _focusNode,
                padding: EdgeInsets.only(
                  top: 16, 
                  bottom: isKeyboardVisible ? bottomInset + 80 : 120
                ),
              ),
            ),
          ),

          if (isKeyboardVisible)
            Positioned(
              bottom: bottomInset + 16,
              left: 16,
              right: 16,
              child: Material(
                elevation: 6,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                clipBehavior: Clip.antiAlias,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: FleatherToolbar.basic(
                          controller: _controller!,
                        ),
                      ),
                    ),
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
    _controller?.removeListener(_autoSave);
    _controller?.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
