/// Block Renderer - Dart barrel (ADR-017 §3, Agent H contract mirror).
///
/// Public API for the block renderer contract mirror. Mirrors the TypeScript
/// `@bitcode/ui-schema/block-renderer` subpath export-for-export.
///
/// NOTE: This is the CONTRACT MIRROR only (types, registry interface, renderer
/// contract). The full Flutter BcBlockRenderer widget + Dart engine port is a
/// dedicated follow-up.
library bitcode.ui_schema.block_renderer;

export 'block_node.dart';
export 'registry.dart';
export 'renderer_contract.dart';
