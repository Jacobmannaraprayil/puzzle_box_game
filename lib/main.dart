import 'package:flutter/material.dart';

void main() {
  runApp(const PuzzleApp());
}

class PuzzleApp extends StatelessWidget {
  const PuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workforce Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const PuzzleGameScreen(),
    );
  }
}

const int boxRows = 4;
const int boxCols = 4;

class BlockShape {
  final int id;
  final List<Offset> baseCells;
  final Color color;

  Offset position;
  final Offset originalPosition;

  bool isSnappedInsideBox;
  int? snappedRow;
  int? snappedCol;
  int rotation;

  BlockShape({
    required this.id,
    required this.baseCells,
    required this.color,
    required this.position,
    required this.originalPosition,
    this.isSnappedInsideBox = false,
    this.snappedRow,
    this.snappedCol,
    this.rotation = 0,
  });

  List<Offset> get cells {
    final List<Offset> rotated = [];
    for (final cell in baseCells) {
      final int row = cell.dy.toInt();
      final int col = cell.dx.toInt();
      int newRow, newCol;

      switch (rotation % 4) {
        case 0:
          newRow = row;
          newCol = col;
          break;
        case 1:
          newRow = col;
          newCol = -row;
          break;
        case 2:
          newRow = -row;
          newCol = -col;
          break;
        case 3:
          newRow = -col;
          newCol = row;
          break;
        default:
          newRow = row;
          newCol = col;
      }

      rotated.add(Offset(newCol.toDouble(), newRow.toDouble()));
    }

    int minRow =
        rotated.map((c) => c.dy.toInt()).reduce((a, b) => a < b ? a : b);
    int minCol =
        rotated.map((c) => c.dx.toInt()).reduce((a, b) => a < b ? a : b);

    return rotated
        .map((c) => Offset(
              (c.dx.toInt() - minCol).toDouble(),
              (c.dy.toInt() - minRow).toDouble(),
            ))
        .toList();
  }

  int get maxRow => cells.map((c) => c.dy.toInt()).reduce((a, b) => a > b ? a : b);
  int get maxCol => cells.map((c) => c.dx.toInt()).reduce((a, b) => a > b ? a : b);
}

class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  late double boxSize;
  late double cellSize;
  late Offset boxTopLeft;

  late List<BlockShape> blocks;
  late List<List<int?>> gridOccupancy;

  @override
  void initState() {
    super.initState();
  }

  void _initGrid() {
    gridOccupancy = List.generate(
      boxRows,
      (_) => List<int?>.filled(boxCols, null),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;

    const double topMargin = 60;
    const double bottomMargin = 20;

    // Layout height needed:
    // box(4c) + 20px + row1(2c) + 0.5c + row2(3c)
    // total = 9.5 cells
    final double maxCellByHeight =
        (size.height - topMargin - bottomMargin - 20) / 9.5;

    // Limit box width
    final double maxBoxWidth = size.width * 0.6;
    final double maxCellByWidth = maxBoxWidth / boxCols;

    cellSize = maxCellByHeight < maxCellByWidth
        ? maxCellByHeight
        : maxCellByWidth;

    boxSize = cellSize * boxRows;

    final double boxLeft = (size.width - boxSize) / 2;
    final double boxTop = topMargin;
    boxTopLeft = Offset(boxLeft, boxTop);

    _initGrid();
    _initBlocks(size);
  }

  void _initBlocks(Size size) {
    const double gapXCells = 0.4;
    const double gapYCells = 0.5;

    final double gapX = gapXCells * cellSize;
    final double gapY = gapYCells * cellSize;

    const int wI2 = 2, hI2 = 1;
    const int wT4 = 3, hT4 = 2;
    const int wO4 = 2, hO4 = 2;
    const int wL4 = 2, hL4 = 3;

    final double row1Y = boxTopLeft.dy + boxSize + 20;

    final double totalRow1Width =
        (wI2 + wT4 + wO4) * cellSize + 2 * gapX;

    final double startXRow1 = (size.width - totalRow1Width) / 2;

    final double i2Row1X = startXRow1;
    final double t4Row1X = i2Row1X + wI2 * cellSize + gapX;
    final double o4Row1X = t4Row1X + wT4 * cellSize + gapX;

    final double row2Y = row1Y + hT4 * cellSize + gapY;

    final double totalRow2Width =
        (wL4 + wI2) * cellSize + gapX;

    final double startXRow2 = (size.width - totalRow2Width) / 2;

    final double l4Row2X = startXRow2;
    final double i2Row2X = l4Row2X + wL4 * cellSize + gapX;

    blocks = [
      BlockShape(
        id: 1,
        baseCells: const [Offset(0, 0), Offset(1, 0)],
        color: Colors.red,
        position: Offset(i2Row1X, row1Y),
        originalPosition: Offset(i2Row1X, row1Y),
      ),
      BlockShape(
        id: 2,
        baseCells: const [
          Offset(0, 0), Offset(1, 0), Offset(2, 0),
          Offset(1, 1)
        ],
        color: Colors.green,
        position: Offset(t4Row1X, row1Y),
        originalPosition: Offset(t4Row1X, row1Y),
      ),
      BlockShape(
        id: 3,
        baseCells: const [
          Offset(0, 0), Offset(1, 0),
          Offset(0, 1), Offset(1, 1)
        ],
        color: Colors.orange,
        position: Offset(o4Row1X, row1Y),
        originalPosition: Offset(o4Row1X, row1Y),
      ),
      BlockShape(
        id: 4,
        baseCells: const [
          Offset(0, 0),
          Offset(0, 1),
          Offset(0, 2),
          Offset(1, 2),
        ],
        color: Colors.purple,
        position: Offset(l4Row2X, row2Y),
        originalPosition: Offset(l4Row2X, row2Y),
      ),
      BlockShape(
        id: 5,
        baseCells: const [Offset(0, 0), Offset(1, 0)],
        color: Colors.blue,
        position: Offset(i2Row2X, row2Y),
        originalPosition: Offset(i2Row2X, row2Y),
      ),
    ];
  }

  bool _isInsideBox(int r, int c) {
    return r >= 0 && r < boxRows && c >= 0 && c < boxCols;
  }

  void _clearBlockFromGrid(BlockShape block) {
    if (!block.isSnappedInsideBox) return;

    for (final cell in block.cells) {
      final int r = block.snappedRow! + cell.dy.toInt();
      final int c = block.snappedCol! + cell.dx.toInt();
      if (_isInsideBox(r, c) && gridOccupancy[r][c] == block.id) {
        gridOccupancy[r][c] = null;
      }
    }
  }

  bool _canSnapBlock(BlockShape block, Offset gridPos) {
    for (final cell in block.cells) {
      final int r = (gridPos.dy + cell.dy).toInt();
      final int c = (gridPos.dx + cell.dx).toInt();

      if (!_isInsideBox(r, c)) return false;

      final occupying = gridOccupancy[r][c];
      if (occupying != null && occupying != block.id) {
        return false;
      }
    }
    return true;
  }

  void _occupyGrid(BlockShape block) {
    for (final cell in block.cells) {
      final int r = block.snappedRow! + cell.dy.toInt();
      final int c = block.snappedCol! + cell.dx.toInt();
      if (_isInsideBox(r, c)) {
        gridOccupancy[r][c] = block.id;
      }
    }
  }

  bool _touchesBox(BlockShape block) {
    final double w = (block.maxCol + 1) * cellSize;
    final double h = (block.maxRow + 1) * cellSize;

    final Rect blockRect = Rect.fromLTWH(
      block.position.dx,
      block.position.dy,
      w,
      h,
    );

    final Rect boxRect = Rect.fromLTWH(
      boxTopLeft.dx,
      boxTopLeft.dy,
      boxSize,
      boxSize,
    );

    return blockRect.overlaps(boxRect);
  }

  void _onDragEnd(BlockShape block) {
    _clearBlockFromGrid(block);

    final Offset relative = block.position - boxTopLeft;
    double gridRow = relative.dy / cellSize;
    double gridCol = relative.dx / cellSize;

    int snapRow = gridRow.round();
    int snapCol = gridCol.round();

    final Offset gridPos = Offset(snapCol.toDouble(), snapRow.toDouble());

    if (_canSnapBlock(block, gridPos)) {
      final double newLeft = boxTopLeft.dx + snapCol * cellSize;
      final double newTop = boxTopLeft.dy + snapRow * cellSize;

      setState(() {
        block.position = Offset(newLeft, newTop);
        block.isSnappedInsideBox = true;
        block.snappedRow = snapRow;
        block.snappedCol = snapCol;
        _occupyGrid(block);
      });
    } else {
      final bool touching = _touchesBox(block);

      setState(() {
        if (touching) {
          block.position = block.originalPosition;
        }
        block.isSnappedInsideBox = false;
        block.snappedRow = null;
        block.snappedCol = null;
      });
    }
  }

  void _rotate(BlockShape block) {
    setState(() {
      _clearBlockFromGrid(block);

      block.rotation = (block.rotation + 1) % 4;

      if (block.snappedRow != null) {
        final pos = Offset(
          block.snappedCol!.toDouble(),
          block.snappedRow!.toDouble(),
        );

        if (_canSnapBlock(block, pos)) {
          block.position = Offset(
            boxTopLeft.dx + block.snappedCol! * cellSize,
            boxTopLeft.dy + block.snappedRow! * cellSize,
          );
          _occupyGrid(block);
        } else {
          block.position = block.originalPosition;
          block.isSnappedInsideBox = false;
          block.snappedRow = null;
          block.snappedCol = null;
        }
      }
    });
  }

  void _reset(Size size) {
    setState(() {
      _initGrid();
      _initBlocks(size);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Workforce Puzzle"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _reset(size),
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 10,
            child: Column(
              children: const [
                Text(
                  "Fill the box with all the blocks.",
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  "Double-tap a block to rotate it.",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          // --- BOX ---
          Positioned(
            left: boxTopLeft.dx,
            top: boxTopLeft.dy,
            child: Container(
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                border: Border.all(width: 3),
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: CustomPaint(
                painter: GridPainter(rows: 4, cols: 4),
              ),
            ),
          ),

          // --- BLOCKS ---
          ...blocks.map((b) {
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              left: b.position.dx,
              top: b.position.dy,
              child: _BlockWidget(
                block: b,
                cellSize: cellSize,
                onMove: (pos) {
                  setState(() => b.position = pos);
                },
                onEnd: () => _onDragEnd(b),
                onRotate: () => _rotate(b),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BlockWidget extends StatelessWidget {
  final BlockShape block;
  final double cellSize;
  final ValueChanged<Offset> onMove;
  final VoidCallback onEnd;
  final VoidCallback onRotate;

  const _BlockWidget({
    required this.block,
    required this.cellSize,
    required this.onMove,
    required this.onEnd,
    required this.onRotate,
  });

  @override
  Widget build(BuildContext context) {
    final width = (block.maxCol + 1) * cellSize;
    final height = (block.maxRow + 1) * cellSize;

    return GestureDetector(
      onPanUpdate: (d) => onMove(block.position + d.delta),
      onPanEnd: (_) => onEnd(),
      onDoubleTap: onRotate,
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: BlockPainter(
            cells: block.cells,
            cellSize: cellSize,
            color: block.color,
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final int rows, cols;

  GridPainter({required this.rows, required this.cols});

  @override
  paint(Canvas c, Size s) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final cellW = s.width / cols;
    final cellH = s.height / rows;

    for (int i = 1; i < cols; i++) {
      double x = i * cellW;
      c.drawLine(Offset(x, 0), Offset(x, s.height), paint);
    }
    for (int i = 1; i < rows; i++) {
      double y = i * cellH;
      c.drawLine(Offset(0, y), Offset(s.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

class BlockPainter extends CustomPainter {
  final List<Offset> cells;
  final double cellSize;
  final Color color;

  BlockPainter({
    required this.cells,
    required this.cellSize,
    required this.color,
  });

  @override
  paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (final cell in cells) {
      final rect = Rect.fromLTWH(
        cell.dx * cellSize,
        cell.dy * cellSize,
        cellSize,
        cellSize,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BlockPainter old) {
    return old.cells != cells ||
        old.cellSize != cellSize ||
        old.color != color;
  }
}
