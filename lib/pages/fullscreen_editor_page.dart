// fullscreen_editor_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show
        ChangeSource,
        QuillController,
        Document,
        QuillEditor,
        QuillEditorConfig,
        QuillSimpleToolbar,
        QuillSimpleToolbarConfig;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:ebook_tutorial_app/pages/drawing_layer.dart';

class FullscreenEditorPage extends StatefulWidget {
  final List<Map<String, dynamic>> initialDeltaJson;
  final List<Map<String, dynamic>> initialDrawingJson;
  final int pageIndex;
  final double initialScrollRatio;
  final List<int> paragraphStartOffsets;
  final bool isNewPage;

  const FullscreenEditorPage({
    super.key,
    required this.initialDeltaJson,
    required this.initialDrawingJson,
    required this.pageIndex,
    this.initialScrollRatio = 0.0,
    this.paragraphStartOffsets = const <int>[],
    this.isNewPage = false,
  });

  @override
  State<FullscreenEditorPage> createState() => _FullscreenEditorPageState();
}

class _FullscreenEditorPageState extends State<FullscreenEditorPage> {
  late QuillController _quillController;
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();

  double _scrollPercent = 0.0;
  bool _isToolbarVisible = false;

  // Drawing state
  bool _isDrawing = false;
  final List<Stroke> _strokes = <Stroke>[];
  Stroke? _currentStroke;
  final List<Stroke> _redoStack = <Stroke>[];

  double _strokeWidth = 3.0;
  double _eraserWidth = 16.0;
  Color _strokeColor = Colors.black;
  bool _isErasing = false;
  PenKind _penKind = PenKind.pen;
  EraserMode _eraserMode = EraserMode.drawOnly;

  final ValueNotifier<int> _repaintTick = ValueNotifier<int>(0);

  final List<Color> _palette = const [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.grey,
  ];

  bool _didJump = false;

  @override
  void initState() {
    super.initState();

    final doc = Document.fromJson(widget.initialDeltaJson);
    _quillController = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    if (widget.initialDrawingJson.isNotEmpty) {
      for (final m in widget.initialDrawingJson) {
        _strokes.add(Stroke.fromJson(m));
      }
    }

    _scrollCtrl.addListener(_updateScrollPercent);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deferredJumpToRatioAndParagraph();
    });
  }

  @override
  void dispose() {
    _quillController.dispose();
    _scrollCtrl.removeListener(_updateScrollPercent);
    _scrollCtrl.dispose();
    _focusNode.dispose();
    _repaintTick.dispose();
    super.dispose();
  }

  void _updateScrollPercent() {
    final max = _scrollCtrl.position.maxScrollExtent;
    final offset = _scrollCtrl.offset;
    setState(() {
      _scrollPercent = max == 0 ? 0 : (offset / max).clamp(0.0, 1.0);
    });
  }

  void _deferredJumpToRatioAndParagraph() {
    int tries = 0;
    void attempt() {
      if (!mounted) return;
      if (_scrollCtrl.hasClients &&
          _scrollCtrl.position.viewportDimension > 0) {
        if (!_didJump) {
          final ratio = widget.initialScrollRatio.clamp(0.0, 1.0);
          _jumpToRatio(ratio);
          _moveCaretToNearestParagraph(ratio);
          _didJump = true;
        }
        return;
      }
      if (tries++ < 12) {
        WidgetsBinding.instance.addPostFrameCallback((_) => attempt());
      }
    }

    attempt();
  }

  void _jumpToRatio(double ratio) {
    if (!_scrollCtrl.hasClients) return;
    final max = _scrollCtrl.position.maxScrollExtent;
    final target = (max * ratio).clamp(0.0, max);
    _scrollCtrl.jumpTo(target);
  }

  void _moveCaretToNearestParagraph(double ratio) {
    final starts = widget.paragraphStartOffsets;
    if (starts.isEmpty) {
      final len = _quillController.document.length;
      final caret = (len * ratio).round().clamp(0, len > 0 ? len - 1 : 0);
      _quillController.updateSelection(
        TextSelection.collapsed(offset: caret),
        ChangeSource.local,
      );
      _focusNode.requestFocus();
      return;
    }
    final idx = (ratio * (starts.length - 1)).round().clamp(
      0,
      starts.length - 1,
    );
    final caret = starts[idx].clamp(
      0,
      _quillController.document.length > 0
          ? _quillController.document.length - 1
          : 0,
    );
    _quillController.updateSelection(
      TextSelection.collapsed(offset: caret),
      ChangeSource.local,
    );
    _focusNode.requestFocus();
  }

  void _saveAndExit() async {
    final deltaJson = _quillController.document.toDelta().toJson();
    final drawingJson = _strokes.map((s) => s.toJson()).toList(growable: false);

    if (!mounted) return;
    Navigator.pop(context, {
      'delta': deltaJson,
      'drawings': drawingJson,
      'index': widget.pageIndex,
    });
  }

  void _onDiamondTap() {
    if (_isDrawing) {
      setState(() {
        _isDrawing = false;
        _isToolbarVisible = true;
      });
    } else {
      setState(() {
        _isToolbarVisible = !_isToolbarVisible;
      });
    }
  }

  void _toggleDrawing() {
    setState(() {
      _isDrawing = !_isDrawing;
      if (_isDrawing) {
        _focusNode.unfocus();
        _isToolbarVisible = false;
      } else {
        _isToolbarVisible = false;
      }
    });
  }

  // === AI 아이콘 동작 ===
  void _onAiTap() {
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListTile(
                    leading: Icon(Icons.auto_awesome),
                    title: Text('AI 도구'),
                    subtitle: Text('향후 연결될 AI 작성 보조 기능입니다.'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.summarize_outlined),
                    title: const Text('요약하기'),
                    onTap: () => _applyAiAction('요약하기'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit_note_outlined),
                    title: const Text('문장 다듬기'),
                    onTap: () => _applyAiAction('문장 다듬기'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.lightbulb_outline),
                    title: const Text('아이디어 생성'),
                    onTap: () => _applyAiAction('아이디어 생성'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
    );
  }

  void _applyAiAction(String actionName) {
    Navigator.of(context).maybePop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('[$actionName] 기능은 준비 중입니다.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  // === AI 아이콘 동작 끝 ===

  void _setTool(bool erasing) {
    setState(() {
      _isErasing = erasing;
      if (erasing) _penKind = PenKind.pen;
    });
  }

  void _toggleEraserMode() {
    setState(() {
      _eraserMode =
          _eraserMode == EraserMode.drawOnly
              ? EraserMode.coverAll
              : EraserMode.drawOnly;
    });
  }

  void _setPen(PenKind k) {
    setState(() {
      _penKind = k;
      _isErasing = false;
    });
  }

  void _setColor(Color c) {
    setState(() {
      _strokeColor = c;
      _isErasing = false;
    });
  }

  void _startStroke(Offset pos) {
    final oy = _scrollCtrl.hasClients ? _scrollCtrl.offset : 0.0;
    final docPos = Offset(pos.dx, pos.dy + oy);

    final effectiveColor =
        _isErasing
            ? (_eraserMode == EraserMode.coverAll
                ? Colors.white
                : Colors.transparent)
            : (_penKind == PenKind.highlighter
                ? _strokeColor.withValues(alpha: 0.35)
                : _strokeColor);

    final effectiveWidth =
        _isErasing
            ? _eraserWidth
            : (_penKind == PenKind.marker
                ? _strokeWidth * 2
                : _penKind == PenKind.highlighter
                ? _strokeWidth * 3
                : _strokeWidth);

    final s = Stroke(
      points: [docPos],
      width: effectiveWidth,
      color: effectiveColor,
      erasing: _isErasing,
      kind: _penKind,
      eraseCoversAll: _eraserMode == EraserMode.coverAll,
    );

    _currentStroke = s;
    _strokes.add(s);
    _redoStack.clear();
    _repaintTick.value++;
  }

  void _appendPoint(Offset pos) {
    final s = _currentStroke;
    if (s == null) return;
    final oy = _scrollCtrl.hasClients ? _scrollCtrl.offset : 0.0;
    final docPos = Offset(pos.dx, pos.dy + oy);
    if (s.points.isEmpty || (s.points.last - docPos).distanceSquared > 0.25) {
      s.addPoint(docPos);
      _repaintTick.value++;
    }
  }

  void _endStroke() {
    _currentStroke = null;
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    final last = _strokes.removeLast();
    _redoStack.add(last);
    _repaintTick.value++;
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    final s = _redoStack.removeLast();
    _strokes.add(s);
    _repaintTick.value++;
  }

  Widget _colorRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 2),
      child:
          !_isErasing
              ? Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _palette
                        .map(
                          (c) => GestureDetector(
                            onTap: () => _setColor(c),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      c == _strokeColor
                                          ? Colors.black
                                          : Colors.black12,
                                  width: c == _strokeColor ? 2 : 1,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              )
              : const SizedBox.shrink(),
    );
  }

  Widget _penButtons() {
    IconButton b(IconData icon, PenKind k, String tip) => IconButton(
      icon: Icon(
        icon,
        color: _penKind == k && !_isErasing ? Colors.black : Colors.black45,
      ),
      tooltip: tip,
      onPressed: () => _setPen(k),
    );
    return Row(
      children: [
        b(Icons.edit, PenKind.pen, '펜'),
        b(Icons.brush, PenKind.marker, '마커'),
        b(Icons.highlight, PenKind.highlighter, '형광펜'),
        b(Icons.mode_edit_outline, PenKind.pencil, '연필'),
      ],
    );
  }

  Widget _drawingToolbar() {
    return Material(
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.auto_fix_normal,
                    color: _isErasing ? Colors.black : Colors.black45,
                  ),
                  onPressed: () => _setTool(true),
                ),
                IconButton(
                  icon: Icon(
                    _eraserMode == EraserMode.drawOnly
                        ? Icons.layers
                        : Icons.layers_clear,
                    color: _isErasing ? Colors.black : Colors.black45,
                  ),
                  onPressed: _toggleEraserMode,
                ),
                const SizedBox(width: 2),
                _penButtons(),
                IconButton(icon: const Icon(Icons.undo), onPressed: _undo),
                IconButton(icon: const Icon(Icons.redo), onPressed: _redo),
              ],
            ),
            _colorRow(),
            const SizedBox(height: 4),
            if (!_isErasing)
              Row(
                children: [
                  const SizedBox(width: 8),
                  const Text('굵기'),
                  Expanded(
                    child: Slider(
                      value: _strokeWidth,
                      min: 1,
                      max: 24,
                      onChanged: (v) => setState(() => _strokeWidth = v),
                    ),
                  ),
                ],
              ),
            if (_isErasing)
              Row(
                children: [
                  const SizedBox(width: 8),
                  const Text('지우개 굵기'),
                  Expanded(
                    child: Slider(
                      value: _eraserWidth,
                      min: 6,
                      max: 48,
                      onChanged: (v) => setState(() => _eraserWidth = v),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 드로잉 아이콘 옆에 AI 아이콘 추가
    final drawingActions = <Widget>[
      IconButton(
        icon: Icon(_isDrawing ? Icons.brush : Icons.brush_outlined),
        color: const Color.fromARGB(255, 137, 208, 236),
        onPressed: _toggleDrawing,
        tooltip: '드로잉',
      ),
      IconButton(
        icon: const Icon(Icons.auto_awesome),
        color: const Color.fromARGB(255, 131, 214, 239),
        onPressed: _onAiTap,
        tooltip: 'AI 도구',
      ),
    ];

    final scrollOffset = _scrollCtrl.hasClients ? _scrollCtrl.offset : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('전체 편집'),
        backgroundColor: const Color.fromRGBO(164, 204, 232, 1),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveAndExit),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: kToolbarHeight,
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    _isToolbarVisible ? Icons.diamond : Icons.diamond_outlined,
                    color: const Color.fromARGB(255, 131, 214, 239),
                  ),
                  onPressed: _onDiamondTap,
                  tooltip: '도구 표시/숨기기',
                ),
                ...drawingActions,
              ],
            ),
          ),
          Divider(color: Colors.grey[300], thickness: 0.5, height: 0.5),
          if (_isDrawing)
            _drawingToolbar()
          else
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState:
                  _isToolbarVisible
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
              firstChild: Material(
                color: Colors.white,
                child: QuillSimpleToolbar(
                  controller: _quillController,
                  config: const QuillSimpleToolbarConfig(
                    showClipboardPaste: true,
                    showAlignmentButtons: true,
                    showColorButton: true,
                    showBackgroundColorButton: true,
                    showFontFamily: true,
                    showHeaderStyle: true,
                    showFontSize: true,
                    showBoldButton: true,
                    showItalicButton: true,
                    showUnderLineButton: true,
                    showStrikeThrough: true,
                  ),
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          Expanded(
            child: RepaintBoundary(
              child: Stack(
                children: [
                  IgnorePointer(
                    ignoring: _isDrawing,
                    child: RepaintBoundary(
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: QuillEditor(
                          controller: _quillController,
                          scrollController: _scrollCtrl,
                          focusNode: _focusNode,
                          config: QuillEditorConfig(
                            scrollable: true,
                            autoFocus: false,
                            padding: EdgeInsets.zero,
                            expands: false,
                            embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: !_isDrawing,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (d) => _startStroke(d.localPosition),
                        onPanUpdate: (d) => _appendPoint(d.localPosition),
                        onPanEnd: (_) => _endStroke(),
                        child: CustomPaint(
                          isComplex: true,
                          willChange: true,
                          painter: DrawingPainter(
                            strokes: _strokes,
                            scrollOffset: scrollOffset,
                            repaint: _repaintTick,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 20,
                    child: Opacity(
                      opacity: 0.7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(_scrollPercent * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isDrawing)
                    Positioned(
                      bottom: 12,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '드로잉 모드',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
