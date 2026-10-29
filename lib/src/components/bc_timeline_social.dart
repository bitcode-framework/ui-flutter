library bc_timeline_social;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Social feed widget with threaded posts and nested comments.
///
/// Mirrors TS `BcTimelineSocial` contract and validation contract VAL-M6-021/022.
///
/// VAL-M6-021: renders N posts, each with author avatar/initials, handle,
/// content, and a footer row of action buttons (like, comment, share). Each
/// post's nested comments render below the content. Empty posts renders
/// emptyState.
///
/// VAL-M6-022: like/comment/share taps fire onPostAction with post id and
/// action type; comment submit fires onCommentSubmit with post id and text.
/// Each callback carries a BcChangeMeta with pointer source.
class BcTimelineSocial extends StatefulWidget {
  final List<BcSocialPost> posts;
  final bool disabled;
  final String emptyText;
  final Widget? emptyState;
  final BcChangeHandler<BcPostActionPayload>? onPostAction;
  final BcChangeHandler<BcCommentPayload>? onCommentSubmit;

  const BcTimelineSocial({
    super.key,
    this.posts = const [],
    this.disabled = false,
    this.emptyText = 'No posts yet',
    this.emptyState,
    this.onPostAction,
    this.onCommentSubmit,
  });

  @override
  State<BcTimelineSocial> createState() => _BcTimelineSocialState();
}

/// Payload for post actions (like/comment/share).
class BcPostActionPayload {
  final String postId;
  final String action;

  const BcPostActionPayload(this.postId, this.action);
}

/// Payload for comment submit.
class BcCommentPayload {
  final String postId;
  final String text;

  const BcCommentPayload(this.postId, this.text);
}

class _BcTimelineSocialState extends State<BcTimelineSocial> {
  final Map<String, TextEditingController> _commentControllers = {};
  final Map<String, bool> _expandedComments = {};
  bool _isExpanded(String postId) => _expandedComments[postId] ?? false;

  TextEditingController _controllerFor(String postId) {
    return _commentControllers.putIfAbsent(
        postId, () => TextEditingController());
  }

  @override
  void dispose() {
    for (final c in _commentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onPostAction(BcSocialPost post, String action) {
    if (widget.disabled) return;
    widget.onPostAction?.call(
      BcPostActionPayload(post.id, action),
      const BcChangeMeta(
        reason: BcChangeReason.select,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _submitComment(BcSocialPost post) {
    if (widget.disabled) return;
    final text = _controllerFor(post.id).text.trim();
    if (text.isEmpty) return;
    widget.onCommentSubmit?.call(
      BcCommentPayload(post.id, text),
      const BcChangeMeta(
        reason: BcChangeReason.submit,
        source: BcEventSource.pointer,
      ),
    );
    _controllerFor(post.id).clear();
  }

  void _toggleComments(BcSocialPost post) {
    if (widget.disabled) return;
    setState(() {
      _expandedComments[post.id] = !_isExpanded(post.id);
    });
  }

  Widget _buildAvatar(BcSocialPost post) {
    if (post.avatar != null && post.avatar!.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(post.avatar!),
        backgroundColor: BcTheme.muted,
      );
    }
    final initial = post.author.isEmpty
        ? '?'
        : post.author.substring(0, 1).toUpperCase();
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: BcTheme.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: BcTheme.primaryForeground,
        ),
      ),
    );
  }

  Widget _buildAction(
      String postId, String label, IconData icon, int count, String action) {
    return GestureDetector(
      key: Key('bc_social_action_${postId}_$action'),
      onTap: () {
        final post = widget.posts.firstWhere((p) => p.id == postId);
        if (action == 'comment') {
          _toggleComments(post);
        }
        _onPostAction(post, action);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: BcTheme.mutedForeground),
            const SizedBox(width: 4),
            Text(
              '$label ($count)',
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

  Widget _buildCommentInput(BcSocialPost post) {
    return Row(
      key: Key('bc_social_comment_input_${post.id}'),
      children: [
        Expanded(
          child: TextField(
            key: Key('bc_social_comment_field_${post.id}'),
            controller: _controllerFor(post.id),
            enabled: !widget.disabled,
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Write a comment...',
              hintStyle: TextStyle(
                  fontSize: 12, color: BcTheme.mutedForeground),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(BcTheme.radius)),
                borderSide: BorderSide(color: BcTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(BcTheme.radius)),
                borderSide: BorderSide(color: BcTheme.primary),
              ),
            ),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          key: Key('bc_social_comment_send_${post.id}'),
          onPressed: widget.disabled ? null : () => _submitComment(post),
          icon: const Icon(Icons.send, size: 18, color: BcTheme.primary),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  Widget _buildComment(BcSocialComment comment) {
    return Padding(
      key: ValueKey<String>('bc_social_comment_${comment.id}'),
      padding: const EdgeInsets.only(left: 42, top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: BcTheme.muted,
            child: Text(
              comment.author.isEmpty
                  ? '?'
                  : comment.author.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 10, color: BcTheme.foreground),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.author,
                  key: ValueKey<String>(
                      'bc_social_comment_author_${comment.id}'),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  comment.content,
                  key: ValueKey<String>(
                      'bc_social_comment_content_${comment.id}'),
                  style: const TextStyle(fontSize: 12),
                ),
                if (comment.timestamp != null)
                  Text(
                    comment.timestamp!,
                    key: ValueKey<String>(
                        'bc_social_comment_timestamp_${comment.id}'),
                    style: const TextStyle(
                        fontSize: 10, color: BcTheme.mutedForeground),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPost(BcSocialPost post, int index) {
    return Container(
      key: ValueKey<String>('bc_social_post_${post.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BcTheme.card,
        border: Border.all(color: BcTheme.border),
        borderRadius: const BorderRadius.all(Radius.circular(BcTheme.radius)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _buildAvatar(post),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.author,
                          key: ValueKey<String>(
                              'bc_social_author_${post.id}'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: BcTheme.foreground,
                          ),
                        ),
                        if (post.handle != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            post.handle!,
                            key: ValueKey<String>(
                                'bc_social_handle_${post.id}'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: BcTheme.mutedForeground,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (post.timestamp != null)
                      Text(
                        post.timestamp!,
                        key: ValueKey<String>(
                            'bc_social_timestamp_${post.id}'),
                        style: const TextStyle(
                          fontSize: 11,
                          color: BcTheme.mutedForeground,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Content
          Text(
            post.content,
            key: ValueKey<String>('bc_social_content_${post.id}'),
            style: const TextStyle(fontSize: 13, color: BcTheme.foreground),
          ),
          const SizedBox(height: 8),
          // Action footer
          Row(
            key: ValueKey<String>('bc_social_actions_${post.id}'),
            children: [
              _buildAction(post.id, 'Like', Icons.favorite_border,
                  post.likes, 'like'),
              const SizedBox(width: 12),
              _buildAction(post.id, 'Comment', Icons.mode_comment_outlined,
                  post.comments, 'comment'),
              const SizedBox(width: 12),
              _buildAction(post.id, 'Share', Icons.share_outlined,
                  post.shares, 'share'),
            ],
          ),
          // Comment input + nested comments (when expanded)
          if (_isExpanded(post.id)) ...[
            const SizedBox(height: 8),
            _buildCommentInput(post),
            if (post.commentList.isNotEmpty)
              ...post.commentList.map((c) => _buildComment(c)),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.posts.isEmpty) {
      return widget.emptyState ??
          Center(
            key: const ValueKey<String>('bc_social_empty'),
            child: Text(
              widget.emptyText,
              style: const TextStyle(
                fontSize: 14,
                color: BcTheme.mutedForeground,
              ),
            ),
          );
    }

    return Semantics(
      container: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.posts.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildPost(widget.posts[i], i),
            ),
        ],
      ),
    );
  }
}
