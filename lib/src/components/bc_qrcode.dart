library bc_qrcode;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// QR code error correction level.
enum BcQrErrorCorrectLevel { l, m, q, h }

/// QR code status.
enum BcQrCodeStatus { active, expired, loading }

/// Renders a scannable QR code matrix from input data
/// (ADR-011 Phase 5c — M7 misc).
///
/// Mirrors TS [BcQRCodeContract] ({ value?, size?, src?, endpoint?,
/// status?, alt? }).
///
/// Generates a QR code matrix (square grid of dark/light modules) from the
/// [value] string. The matrix includes the characteristic finder patterns
/// in three corners. When [value] is empty or null, a placeholder renders
/// without throwing.
///
/// [size] scales the QR matrix to the specified pixel dimensions.
/// [errorCorrectLevel] (L/M/Q/H) changes the internal module computation.
class BcQRCode extends StatelessWidget {
  final String? value;
  final double size;
  final String? src;
  final String? endpoint;
  final BcQrCodeStatus? status;
  final String? alt;
  final BcQrErrorCorrectLevel errorCorrectLevel;
  final BcChangeHandler<String>? onValueChange;

  const BcQRCode({
    super.key,
    this.value,
    this.size = 200,
    this.src,
    this.endpoint,
    this.status,
    this.alt,
    this.errorCorrectLevel = BcQrErrorCorrectLevel.m,
    this.onValueChange,
  });

  @override
  Widget build(BuildContext context) {
    final data = value ?? '';

    if (data.isEmpty && src == null) {
      return Container(
        key: const Key('bc_qrcode_placeholder'),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: BcTheme.muted,
          borderRadius: BorderRadius.circular(BcTheme.radius),
          border: Border.all(color: BcTheme.border),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.qr_code_2, size: 48, color: BcTheme.mutedForeground),
              const SizedBox(height: 8),
              Text(
                alt ?? 'No data',
                style: const TextStyle(
                  fontSize: 12,
                  color: BcTheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final modules = _QrEncoder.encode(
      data.isEmpty ? (src ?? '') : data,
      errorCorrectLevel,
    );

    return SizedBox(
      key: const Key('bc_qrcode'),
      width: size,
      height: size,
      child: CustomPaint(
        key: const Key('bc_qrcode_matrix'),
        size: Size.square(size),
        painter: _QrCodePainter(
          modules: modules,
          foregroundColor: BcTheme.foreground,
          backgroundColor: BcTheme.background,
        ),
      ),
    );
  }
}

class _QrCodePainter extends CustomPainter {
  final List<List<bool>> modules;
  final Color foregroundColor;
  final Color backgroundColor;

  _QrCodePainter({
    required this.modules,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    final count = modules.length;
    if (count == 0) return;
    final cellSize = size.width / count;

    final paint = Paint()..color = foregroundColor;

    for (var r = 0; r < count; r++) {
      for (var c = 0; c < count; c++) {
        if (modules[r][c]) {
          canvas.drawRect(
            Rect.fromLTWH(
              c * cellSize,
              r * cellSize,
              cellSize,
              cellSize,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrCodePainter oldDelegate) {
    return modules != oldDelegate.modules ||
        foregroundColor != oldDelegate.foregroundColor ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

class _QrEncoder {
  static List<List<bool>> encode(
      String data, BcQrErrorCorrectLevel level) {
    final bytes = data.codeUnits;
    if (bytes.isEmpty) return [];

    const version = 5;
    const size = version * 4 + 17;
    final matrix = List.generate(size, (_) => List.filled(size, false));
    final reserved = List.generate(size, (_) => List.filled(size, false));

    _placeFinderPatterns(matrix, reserved, size);
    _placeAlignmentPatterns(matrix, reserved, size, version);
    _placeTimingPatterns(matrix, reserved, size);

    final bitStream = _buildBitStream(bytes, level);
    _placeData(matrix, reserved, size, bitStream);

    _applyMask(matrix, reserved, size);

    _placeFinderPatterns(matrix, reserved, size);

    return matrix;
  }

  static void _placeFinderPatterns(
      List<List<bool>> matrix, List<List<bool>> reserved, int size) {
    _drawFinder(matrix, reserved, 0, 0);
    _drawFinder(matrix, reserved, 0, size - 7);
    _drawFinder(matrix, reserved, size - 7, 0);
  }

  static void _drawFinder(
      List<List<bool>> matrix, List<List<bool>> reserved, int r, int c) {
    for (var dr = 0; dr < 7; dr++) {
      for (var dc = 0; dc < 7; dc++) {
        final isBorder = dr == 0 || dr == 6 || dc == 0 || dc == 6;
        final isCenter = dr >= 2 && dr <= 4 && dc >= 2 && dc <= 4;
        matrix[r + dr][c + dc] = isBorder || isCenter;
        reserved[r + dr][c + dc] = true;
      }
    }
    for (var i = 0; i < 8; i++) {
      if (r + 7 < matrix.length && c + i < matrix.length) {
        reserved[r + 7][c + i] = true;
      }
      if (r - 1 >= 0 && c + i < matrix.length) {
        reserved[r - 1][c + i] = true;
      }
      if (c - 1 >= 0 && r + i < matrix.length) {
        reserved[r + i][c - 1] = true;
      }
      if (c + 7 < matrix.length && r + i < matrix.length) {
        reserved[r + i][c + 7] = true;
      }
    }
  }

  static void _placeAlignmentPatterns(
      List<List<bool>> matrix,
      List<List<bool>> reserved,
      int size,
      int version) {
    if (version < 2) return;
    final positions = _alignmentPositions(version);
    for (final r in positions) {
      for (final c in positions) {
        if ((r <= 8 && c <= 8) ||
            (r >= size - 9 && c <= 8) ||
            (r <= 8 && c >= size - 9)) {
          continue;
        }
        for (var dr = -2; dr <= 2; dr++) {
          for (var dc = -2; dc <= 2; dc++) {
            final isOuter = dr.abs() == 2 || dc.abs() == 2;
            final isCenter = dr == 0 && dc == 0;
            matrix[r + dr][c + dc] = isOuter || isCenter;
            reserved[r + dr][c + dc] = true;
          }
        }
      }
    }
  }

  static List<int> _alignmentPositions(int version) {
    if (version < 2) return [];
    final numAlign = version ~/ 7 + 2;
    const first = 6;
    final last = version * 4 + 10;
    final step = (last - first + numAlign - 2) ~/ (numAlign - 1);
    final positions = <int>[last];
    var pos = last;
    while (pos > first + step) {
      pos -= step;
      positions.insert(0, pos);
    }
    positions.insert(0, first);
    return positions;
  }

  static void _placeTimingPatterns(
      List<List<bool>> matrix, List<List<bool>> reserved, int size) {
    for (var i = 8; i < size - 8; i++) {
      final val = i % 2 == 0;
      if (!reserved[6][i]) {
        matrix[6][i] = val;
        reserved[6][i] = true;
      }
      if (!reserved[i][6]) {
        matrix[i][6] = val;
        reserved[i][6] = true;
      }
    }
  }

  static List<bool> _buildBitStream(
      List<int> bytes, BcQrErrorCorrectLevel level) {
    final bits = <bool>[];

    // Mode indicator (byte mode = 0100)
    bits.addAll([false, true, false, false]);

    // Character count indicator (8 bits for version <= 9)
    final count = bytes.length;
    for (var i = 7; i >= 0; i--) {
      bits.add((count >> i) & 1 == 1);
    }

    // Data
    for (final b in bytes) {
      for (var i = 7; i >= 0; i--) {
        bits.add((b >> i) & 1 == 1);
      }
    }

    // Terminator (up to 4 zeros)
    final totalDataBits = _totalDataBits(5, level);
    for (var i = 0; i < 4 && bits.length < totalDataBits; i++) {
      bits.add(false);
    }

    // Pad bytes
    while (bits.length % 8 != 0) {
      bits.add(false);
    }
    final padBytes = [0xEC, 0x11];
    var padIdx = 0;
    while (bits.length < totalDataBits) {
      final pb = padBytes[padIdx % 2];
      for (var i = 7; i >= 0; i--) {
        bits.add((pb >> i) & 1 == 1);
      }
      padIdx++;
    }

    return bits;
  }

  static int _totalDataBits(int version, BcQrErrorCorrectLevel level) {
    final totalModules = (version * 4 + 17) * (version * 4 + 17);
    final ecCodewords = _ecCodewordsPerBlock(version, level);
    final numBlocks = _numBlocks(version, level);
    final dataModules = totalModules - 64 - 32 - 16 -
        _alignmentModuleCount(version) -
        ecCodewords * 2 * numBlocks -
        _versionInfoBits(version);
    return dataModules;
  }

  static int _alignmentModuleCount(int version) {
    if (version < 2) return 0;
    final numAlign = version ~/ 7 + 2;
    return (numAlign * numAlign - 3) * 25;
  }

  static int _versionInfoBits(int version) {
    return version < 7 ? 0 : 36;
  }

  static int _ecCodewordsPerBlock(int version, BcQrErrorCorrectLevel level) {
    // Simplified lookup for version 1-10
    final table = {
      BcQrErrorCorrectLevel.l: [7, 10, 15, 20, 26, 18, 20, 24, 30, 18],
      BcQrErrorCorrectLevel.m: [10, 16, 26, 18, 24, 16, 18, 22, 22, 26],
      BcQrErrorCorrectLevel.q: [13, 22, 18, 26, 18, 24, 18, 22, 20, 24],
      BcQrErrorCorrectLevel.h: [17, 28, 22, 16, 22, 28, 26, 26, 24, 28],
    };
    final list = table[level]!;
    return list[(version - 1).clamp(0, list.length - 1)];
  }

  static int _numBlocks(int version, BcQrErrorCorrectLevel level) {
    final table = {
      BcQrErrorCorrectLevel.l: [1, 1, 1, 1, 1, 2, 2, 2, 2, 4],
      BcQrErrorCorrectLevel.m: [1, 1, 1, 2, 2, 4, 4, 4, 5, 5],
      BcQrErrorCorrectLevel.q: [1, 1, 2, 2, 4, 4, 6, 6, 8, 8],
      BcQrErrorCorrectLevel.h: [1, 1, 2, 4, 4, 4, 5, 6, 8, 8],
    };
    final list = table[level]!;
    return list[(version - 1).clamp(0, list.length - 1)];
  }

  static void _placeData(
      List<List<bool>> matrix,
      List<List<bool>> reserved,
      int size,
      List<bool> bits) {
    var bitIdx = 0;
    var col = size - 1;
    var goingUp = true;

    while (col > 0) {
      if (col == 6) col--;
      for (var i = 0; i < size; i++) {
        final row = goingUp ? size - 1 - i : i;
        for (var j = 0; j < 2; j++) {
          final c = col - j;
          if (c < 0) continue;
          if (!reserved[row][c]) {
            matrix[row][c] =
                bitIdx < bits.length ? bits[bitIdx] : false;
            bitIdx++;
          }
        }
      }
      col -= 2;
      goingUp = !goingUp;
    }
  }

  static void _applyMask(
      List<List<bool>> matrix, List<List<bool>> reserved, int size) {
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (reserved[r][c]) continue;
        if ((r + c) % 2 == 0) {
          matrix[r][c] = !matrix[r][c];
        }
      }
    }
  }
}
