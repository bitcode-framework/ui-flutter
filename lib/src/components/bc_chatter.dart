library bc_chatter;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Chat / messaging widget with message list, compose input and send.
///
/// Mirrors TS `BcChatter` contract (ADR-014 upgrade: mentions, threading,
/// recordId, onMention, onLoadMore) and validation contract VAL-M6-017/018.
///
/// VAL-M6-017: renders N message bubbles in order. Typing into the input and
/// pressing Enter or the send button clears the input and delivers the
/// composed text to [onSend].
///
/// VAL-M6-018: sending emits [onSend] with the trimmed text and a
/// BcChangeMeta whose source is pointer. Empty / whitespace-only messages
/// are rejected (never fire [onSend]). When [disabled] is true the input is
/// non-interactive, the send button is disabled, and no [onSend] fires.
///
/// When [threading] is true, [threads] is rendered as a nested tree and the
/// compose area gains a reply-to affordance (tap Reply on a message to set
/// the parent). [onSendWithParent] fires with the trimmed text, meta, and
/// optional parent id.
///
/// When the draft contains @mentions, [onMention] fires with the parsed
/// list (live parsing on every keystroke).
///
/// When [hasMore] is true, a "Load more" button is rendered at the top;
/// tapping it calls [onLoadMore].
class BcChatter extends StatefulWidget {
  /// Flat message list (legacy / simple mode). Ignored when [threading] is
  /// true and [threads] is non-empty.
  final List<BcChatterMessage> messages;

  /// Threaded message tree (when [threading] is enabled).
  final List<BcChatterMessage> threads;

  /// Enable threaded replies view. Default false.
  final bool threading;

  final String? placeholder;
  final bool disabled;
  final String? currentUser;
  final String emptyText;
  final Widget? emptyState;

  /// The record this chatter is bound to (for data-source binding).
  final String? recordId;

  /// The model name this chatter is bound to.
  final String? model;

  /// Whether more older messages can be loaded.
  final bool hasMore;

  /// Fired when the user submits a new comment (flat mode).
  final BcChangeHandler<String>? onSend;

  /// Fired when the user submits a new comment (threaded mode). Receives the
  /// trimmed text, meta, and optional parent comment id.
  final void Function(String text, BcChangeMeta meta, String? parentId)?
      onSendWithParent;

  /// Fired when @mentions are detected in the draft (live parsing).
  final void Function(List<BcChatterMention> mentions)? onMention;

  /// Fired when the user requests older messages (pagination).
  final VoidCallback? onLoadMore;

  const BcChatter({
    super.key,
    this.messages = const [],
    this.threads = const [],
    this.threading = false,
    this.placeholder,
    this.disabled = false,
    this.currentUser,
    this.emptyText = 'No messages',
    this.emptyState,
    this.recordId,
    this.model,
    this.hasMore = false,
    this.onSend,
    this.onSendWithParent,
    this.onMention,
    this.onLoadMore,
  });

  @override
  State<BcChatter> createState() => _BcChatterState();
}

class _BcChatterState extends State<BcChatter> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  String? _replyTo;

  static final _mentionRe = RegExp(r'@([a-zA-Z0-9_.\-]+)');

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isMineMessage(BcChatterMessage msg) {
    return widget.currentUser != null && msg.author == widget.currentUser;
  }

  List<BcChatterMention> _parseMentions(String text) {
    final seen = <String>{};
    final out = <BcChatterMention>[];
    for (final m in _mentionRe.allMatches(text)) {
      final username = m.group(1)!;
      if (seen.add(username)) {
        out.add(BcChatterMention(username: username));
      }
    }
    return out;
  }

  void _onInputChanged(String value) {
    if (widget.onMention != null) {
      final mentions = _parseMentions(value);
      if (mentions.isNotEmpty) {
        widget.onMention!(mentions);
      }
    }
  }

  void _setReplyTo(String commentId) {
    if (widget.disabled) return;
    setState(() {
      _replyTo = commentId;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyTo = null;
    });
  }

  void _send({required BcEventSource source}) {
    if (widget.disabled) return;
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final meta = BcChangeMeta(reason: BcChangeReason.submit, source: source);
    if (widget.threading && widget.onSendWithParent != null) {
      widget.onSendWithParent!(text, meta, _replyTo);
    } else {
      widget.onSend?.call(text, meta);
    }
    _inputController.clear();
    _replyTo = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildAvatar(BcChatterMessage msg, bool mine) {
    if (msg.avatar != null && msg.avatar!.isNotEmpty) {
      return CircleAvatar(
        radius: 14,
        backgroundImage: NetworkImage(msg.avatar!),
        backgroundColor: BcTheme.muted,
      );
    }
    final initial = msg.author.isEmpty
        ? '?'
        : msg.author.substring(0, 1).toUpperCase();
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: mine ? BcTheme.primary : BcTheme.muted,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: mine ? BcTheme.primaryForeground : BcTheme.foreground,
        ),
      ),
    );
  }

  Widget _buildMessage(BcChatterMessage msg, int index) {
    final mine = _isMineMessage(msg);
    return Container(
      key: ValueKey<String>('bc_chatter_msg_${msg.id}_$index'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!mine) ...[_buildAvatar(msg, mine), const SizedBox(width: 6)],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: mine ? BcTheme.primary : BcTheme.card,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(BcTheme.radius),
                  topRight: const Radius.circular(BcTheme.radius),
                  bottomLeft: mine
                      ? const Radius.circular(BcTheme.radius)
                      : Radius.zero,
                  bottomRight: mine
                      ? Radius.zero
                      : const Radius.circular(BcTheme.radius),
                ),
                border: mine ? null : Border.all(color: BcTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!mine)
                    Text(
                      msg.author,
                      key: ValueKey<String>(
                          'bc_chatter_author_${msg.id}_$index'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: BcTheme.mutedForeground,
                      ),
                    ),
                  Text(
                    msg.content,
                    key: ValueKey<String>(
                        'bc_chatter_content_${msg.id}_$index'),
                    style: TextStyle(
                      fontSize: 13,
                      color: mine ? BcTheme.primaryForeground : BcTheme.foreground,
                    ),
                  ),
                  if (msg.timestamp != null)
                    Text(
                      msg.timestamp!,
                      key: ValueKey<String>(
                          'bc_chatter_timestamp_${msg.id}_$index'),
                      style: TextStyle(
                        fontSize: 10,
                        color: mine
                            ? BcTheme.primaryForeground.withValues(alpha: 0.7)
                            : BcTheme.mutedForeground,
                      ),
                    ),
                  if (msg.mentions.isNotEmpty)
                    Padding(
                      key: ValueKey<String>(
                          'bc_chatter_mentions_${msg.id}_$index'),
                      padding: const EdgeInsets.only(top: 4),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: msg.mentions
                            .map((m) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: BcTheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '@${m.username}',
                                    key: ValueKey<String>(
                                        'bc_chatter_mention_${msg.id}_${m.username}'),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: BcTheme.primary,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (mine) ...[const SizedBox(width: 6), _buildAvatar(msg, mine)],
        ],
      ),
    );
  }

  Widget _buildThreadedMessage(BcChatterMessage msg) {
    return Column(
      key: ValueKey<String>('bc_chatter_thread_${msg.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMessage(msg, 0),
        if (widget.threading && !widget.disabled)
          Padding(
            padding: const EdgeInsets.only(left: 44, top: 2),
            child: TextButton(
              key: ValueKey<String>('bc_chatter_reply_${msg.id}'),
              onPressed: () => _setReplyTo(msg.id),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                minimumSize: const Size(0, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Reply',
                key: ValueKey<String>('bc_chatter_reply_label'),
                style: TextStyle(fontSize: 11, color: BcTheme.mutedForeground),
              ),
            ),
          ),
        if (msg.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                    left: BorderSide(color: BcTheme.border, width: 2)),
              ),
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: msg.replies
                    .map((r) => _buildMessage(r, 0))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInput() {
    final platform = Theme.of(context).platform;
    final isIOS = platform == TargetPlatform.iOS ||
        platform == TargetPlatform.macOS;

    final input = PlatformTextField(
      key: const ValueKey<String>('bc_chatter_input'),
      controller: _inputController,
      focusNode: _focusNode,
      enabled: !widget.disabled,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => _send(source: BcEventSource.pointer),
      material: (_, __) => MaterialTextFieldData(
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.placeholder ?? 'Type a message...',
          hintStyle: const TextStyle(
              fontSize: 13, color: BcTheme.mutedForeground),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 8),
          enabledBorder: const OutlineInputBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(BcTheme.radius)),
            borderSide: BorderSide(color: BcTheme.border),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(BcTheme.radius)),
            borderSide: BorderSide(color: BcTheme.primary),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius:
                const BorderRadius.all(Radius.circular(BcTheme.radius)),
            borderSide: BorderSide(
                color: BcTheme.border.withValues(alpha: 0.5)),
          ),
        ),
        style: const TextStyle(fontSize: 13),
      ),
      cupertino: (_, __) => CupertinoTextFieldData(
        placeholder: widget.placeholder ?? 'Type a message...',
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: widget.disabled ? BcTheme.muted : BcTheme.background,
          border: Border.all(color: BcTheme.border),
          borderRadius:
              const BorderRadius.all(Radius.circular(BcTheme.radius)),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    );

    return Padding(
      key: const ValueKey<String>('bc_chatter_compose'),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          Expanded(child: input),
          const SizedBox(width: 6),
          PlatformIconButton(
            key: const ValueKey<String>('bc_chatter_send'),
            onPressed: widget.disabled ? null : () => _send(source: BcEventSource.pointer),
            icon: Icon(
              isIOS ? CupertinoIcons.arrow_up_circle_fill : Icons.send,
              size: 24,
              color: widget.disabled ? BcTheme.mutedForeground : BcTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMore() {
    return Padding(
      key: const ValueKey<String>('bc_chatter_load_more'),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: TextButton(
          onPressed: widget.disabled ? null : widget.onLoadMore,
          child: const Text(
            'Load more',
            key: ValueKey<String>('bc_chatter_load_more_label'),
            style: TextStyle(fontSize: 12, color: BcTheme.mutedForeground),
          ),
        ),
      ),
    );
  }

  Widget _buildReplyIndicator() {
    return Padding(
      key: const ValueKey<String>('bc_chatter_reply_indicator'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Text(
            'Replying to comment',
            style: TextStyle(
              fontSize: 11,
              color: BcTheme.mutedForeground,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _cancelReply,
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 11,
                color: BcTheme.mutedForeground,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final useThreads = widget.threading && widget.threads != null;
    final list = useThreads ? widget.threads! : widget.messages;
    return Container(
      key: const ValueKey<String>('bc_chatter_root'),
      decoration: BoxDecoration(
        color: BcTheme.background,
        border: Border.all(color: BcTheme.border),
        borderRadius: const BorderRadius.all(Radius.circular(BcTheme.radius)),
      ),
      child: Column(
        children: [
          if (widget.hasMore) _buildLoadMore(),
          Expanded(
            child: list.isEmpty
                ? (widget.emptyState ??
                    Center(
                      key: const ValueKey<String>('bc_chatter_empty'),
                      child: Text(
                        widget.emptyText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: BcTheme.mutedForeground,
                        ),
                      ),
                    ))
                : ListView.builder(
                    key: const ValueKey<String>('bc_chatter_list'),
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final msg = list[index];
                      if (useThreads) {
                        return _buildThreadedMessage(msg);
                      }
                      return _buildMessage(msg, index);
                    },
                  ),
          ),
          if (widget.threading && _replyTo != null) _buildReplyIndicator(),
          _buildInput(),
        ],
      ),
    );
  }
}
