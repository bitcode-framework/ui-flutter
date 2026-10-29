// Social demo - BcChatter, BcActivity, BcTimelineSocial, BcRate, BcQRCode.
library social_section;

import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import '../demo_widgets.dart';

class SocialSection extends StatefulWidget {
  const SocialSection({super.key});

  @override
  State<SocialSection> createState() => _SocialSectionState();
}

class _SocialSectionState extends State<SocialSection> {
  int _rating = 3;
  List<BcChatterMessage> _messages = const [
    BcChatterMessage(
      id: '1',
      author: 'Alice',
      content: 'Hey team, the new build looks great!',
      timestamp: '10:30',
    ),
    BcChatterMessage(
      id: '2',
      author: 'Bob',
      content: 'Thanks! I fixed the layout bugs yesterday.',
      timestamp: '10:32',
    ),
    BcChatterMessage(
      id: '3',
      author: 'Alice',
      content: 'Awesome work. Shipping it today.',
      timestamp: '10:35',
    ),
  ];
  bool _liked = false;
  int _likeCount = 42;
  bool _following = false;
  int _followCount = 128;

  @override
  Widget build(BuildContext context) {
    return BcYStack(
      gap: 24,
      children: [
        const SectionHeader(
          title: 'Social',
          subtitle: 'Chat, activity timelines, social feeds, ratings, and QR codes.',
        ),

        // -- BcChatter --
        DemoCard(
          title: 'BcChatter',
          description: 'Chat / messaging widget with message list and compose input.',
          child: SizedBox(
            height: 280,
            child: BcChatter(
              messages: _messages,
              currentUser: 'Alice',
              placeholder: 'Type a message...',
              onSend: (text, _) {
                setState(() {
                  _messages = [
                    ..._messages,
                    BcChatterMessage(
                      id: '${_messages.length + 1}',
                      author: 'Alice',
                      content: text,
                      timestamp: 'now',
                    ),
                  ];
                });
              },
            ),
          ),
        ),

        // -- BcActivity --
        DemoCard(
          title: 'BcActivity',
          description: 'Activity timeline with actor, action, and variant coloring.',
          child: BcActivity(
            items: const [
              BcActivityEntry(
                id: '1',
                actor: 'Alice',
                action: 'created a new project',
                target: 'Flutter Demo',
                timestamp: '2 hours ago',
                variant: BcActivityVariant.success,
              ),
              BcActivityEntry(
                id: '2',
                actor: 'Bob',
                action: 'commented on',
                target: 'PR #42',
                timestamp: '5 hours ago',
                variant: BcActivityVariant.info,
              ),
              BcActivityEntry(
                id: '3',
                actor: 'Charlie',
                action: 'deleted',
                target: 'old-branch',
                timestamp: '1 day ago',
                variant: BcActivityVariant.destructive,
              ),
              BcActivityEntry(
                id: '4',
                actor: 'Diana',
                action: 'flagged',
                target: 'invoice #99',
                timestamp: '2 days ago',
                variant: BcActivityVariant.warning,
              ),
            ],
          ),
        ),

        // -- BcTimelineSocial --
        DemoCard(
          title: 'BcTimelineSocial',
          description: 'Social feed with posts, like/comment/share actions.',
          child: BcTimelineSocial(
            posts: const [
              BcSocialPost(
                id: '1',
                author: 'Alice Johnson',
                handle: '@alice',
                content: 'Just shipped the new Flutter demo with full component parity! So proud of the team.',
                timestamp: '3h',
                likes: 42,
                comments: 5,
                shares: 3,
                commentList: [
                  BcSocialComment(
                    id: 'c1',
                    author: 'Bob',
                    content: 'Congrats! Looks amazing.',
                    timestamp: '2h',
                  ),
                ],
              ),
              BcSocialPost(
                id: '2',
                author: 'Charlie Brown',
                handle: '@charlie',
                content: 'The Stencil adapter now exports 151 paths. Cross-framework UI is real.',
                timestamp: '5h',
                likes: 28,
                comments: 2,
                shares: 1,
                commentList: [],
              ),
            ],
          ),
        ),

        // -- BcRate --
        DemoCard(
          title: 'BcRate',
          description: 'Star rating input. Click a star to rate, click again to clear.',
          child: BcYStack(
            gap: 12,
            children: [
              BcXStack(
                gap: 16,
                crossAxisAlignment: BcXStackAlign.center,
                children: [
                  const Text('Your rating: '),
                  BcRate(
                    value: _rating,
                    count: 5,
                    size: BcRateSize.lg,
                    onChange: (v, _) => setState(() => _rating = v),
                  ),
                  Text('$_rating / 5',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              const Divider(),
              BcXStack(
                gap: 16,
                crossAxisAlignment: BcXStackAlign.center,
                children: const [
                  Text('Readonly (4): '),
                  BcRate(
                    value: 4,
                    readonly: true,
                    size: BcRateSize.md,
                  ),
                ],
              ),
            ],
          ),
        ),

        // -- BcQRCode --
        DemoCard(
          title: 'BcQRCode',
          description: 'Generates a QR code matrix from input data.',
          child: BcXStack(
            gap: 16,
            crossAxisAlignment: BcXStackAlign.center,
            children: const [
              BcQRCode(
                value: 'https://bitcode.io',
                size: 160,
                alt: 'BitCode website QR',
              ),
            ],
          ),
        ),

        // -- BcLike --
        DemoCard(
          title: 'BcLike',
          description: 'Like/unlike toggle with count.',
          child: BcXStack(
            gap: 16,
            crossAxisAlignment: BcXStackAlign.center,
            children: [
              BcLike(
                liked: _liked,
                count: _likeCount,
                onLikedChange: (v, _) => setState(() {
                  _liked = v;
                  _likeCount += v ? 1 : -1;
                }),
              ),
              Text(_liked ? 'Liked!' : 'Not liked'),
            ],
          ),
        ),

        // -- BcFollow --
        DemoCard(
          title: 'BcFollow',
          description: 'Follow/unfollow toggle with count.',
          child: BcFollow(
            following: _following,
            count: _followCount,
            onFollowingChange: (v, _) => setState(() {
              _following = v;
              _followCount += v ? 1 : -1;
            }),
          ),
        ),

        // -- BcComment --
        DemoCard(
          title: 'BcComment',
          description: 'Threaded comment with inline reply form.',
          child: BcComment(
            author: 'Jane Doe',
            body: 'This is a great demo! The new components look amazing.',
            timestamp: '2h ago',
            replyable: true,
            onReply: (text, _) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Reply: $text')),
              );
            },
          ),
        ),

        // -- BcShare --
        DemoCard(
          title: 'BcShare',
          description: 'Share button with Web Share API and fallback dialog.',
          child: BcShare(
            title: 'Check this out!',
            text: 'BitCode UI — cross-platform components.',
            url: 'https://bitcode.io',
            onShare: (result, _) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Share: $result')),
              );
            },
          ),
        ),
      ],
    );
  }
}