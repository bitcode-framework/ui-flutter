library bc_comment;

import 'package:flutter/material.dart';

import '../core/bc_i18n.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Reason the comment reply was submitted.
enum BcCommentSubmitReason { submit, programmatic }

/// Threaded comment with author, body, optional timestamp, and inline reply
/// form (ADR-007 parity).
///
/// Pure widget: the parent owns the comment list. The optional inline reply
/// form is uncontrolled (draft + onReply submit).
class BcComment extends StatefulWidget {
  final String author;
  final String? avatar;
  final String body;
  final String? timestamp;
  final bool replyable;
  final String? replyPlaceholder;
  final bool disabled;
  final BcChangeHandler<String>? onReply;
  final Widget? child;

  const BcComment({
    super.key,
    required this.author,
    required this.body,
    this.avatar,
    this.timestamp,
    this.replyable = false,
    this.replyPlaceholder,
    this.disabled = false,
    this.onReply,
    this.child,
  });

  @override
  State<BcComment> createState() => _BcCommentState();
}

class _BcCommentState extends State<BcComment> {
  final TextEditingController _draftController = TextEditingController();
  bool _showReply = false;
  bool _draftEmpty = true;

  @override
  void initState() {
    super.initState();
    _draftController.addListener(_onDraftChange);
  }

  void _onDraftChange() {
    final empty = _draftController.text.trim().isEmpty;
    if (empty != _draftEmpty) {
      setState(() => _draftEmpty = empty);
    }
  }

  @override
  void dispose() {
    _draftController.removeListener(_onDraftChange);
    _draftController.dispose();
    super.dispose();
  }

  void _toggleReply() {
    if (widget.disabled) return;
    setState(() => _showReply = !_showReply);
  }

  void _submit() {
    final text = _draftController.text.trim();
    if (text.isEmpty || widget.disabled) return;
    widget.onReply?.call(
      text,
      const BcChangeMeta(
        reason: BcChangeReason.submit,
        source: BcEventSource.pointer,
      ),
    );
    _draftController.clear();
    setState(() => _showReply = false);
  }

  Widget _buildAvatar() {
    final avatar = widget.avatar ?? '';
    final isUrl = avatar.startsWith('http') ||
        avatar.startsWith('/') ||
        avatar.startsWith('data:');
    if (isUrl) {
      return ClipOval(
        child: Image.network(
          avatar,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsAvatar(),
        ),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() {
    final src = (widget.avatar?.isNotEmpty ?? false) ? widget.avatar! : widget.author;
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: BcTheme.secondary,
      ),
      child: Text(
        src.isNotEmpty ? src.substring(0, src.length >= 2 ? 2 : 1).toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: BcTheme.secondaryForeground,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Comment by ${widget.author}',
      child: Container(
        key: const Key('bc-comment-root'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildAvatar(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.timestamp != null)
                    Row(
                      children: [
                        Text(
                          widget.author,
                          key: const Key('bc-comment-author'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: BcTheme.foreground,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.timestamp!,
                          key: const Key('bc-comment-timestamp'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: BcTheme.mutedForeground,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      widget.author,
                      key: const Key('bc-comment-author'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: BcTheme.foreground,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    widget.body,
                    key: const Key('bc-comment-body'),
                    style: const TextStyle(fontSize: 14, color: BcTheme.foreground),
                  ),
                  if (widget.child != null) ...[const SizedBox(height: 8), widget.child!],
                  if (widget.replyable) ...[
                    const SizedBox(height: 8),
                    if (!_showReply)
                      TextButton(
                        key: const Key('bc-comment-reply-toggle'),
                        onPressed: widget.disabled ? null : _toggleReply,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: BcTheme.mutedForeground,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: Text(bcI18n.t('bc.comment.replyButton')),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              key: const Key('bc-comment-reply-input'),
                              controller: _draftController,
                              enabled: !widget.disabled,
                              minLines: 2,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: widget.replyPlaceholder ??
                                    bcI18n.t('bc.comment.defaultReplyPlaceholder'),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(BcTheme.radius),
                                ),
                              ),
                              onSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton(
                                  key: const Key('bc-comment-reply-submit'),
                                  onPressed: (widget.disabled || _draftEmpty)
                                      ? null
                                      : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: BcTheme.primary,
                                    foregroundColor: BcTheme.primaryForeground,
                                    minimumSize: const Size(0, 32),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                  child: Text(bcI18n.t('bc.comment.replyButton')),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  key: const Key('bc-comment-reply-cancel'),
                                  onPressed: widget.disabled ? null : _toggleReply,
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(0, 32),
                                    foregroundColor: BcTheme.foreground,
                                  ),
                                  child: Text(bcI18n.t('bc.comment.cancelButton')),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
