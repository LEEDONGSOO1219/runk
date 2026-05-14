import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_cards.dart';

enum _FriendsView { list, chat }

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  _FriendsView _view = _FriendsView.list;

  static const _friends = [
    _FriendItem(name: '김지훈', message: '오늘 5.2km 달렸어요', time: '2시간 전'),
    _FriendItem(name: '이민지', message: '주간 목표 달성!', time: '5시간 전'),
    _FriendItem(name: '박서연', message: '새 기록 갱신', time: '1일 전'),
    _FriendItem(name: '최준호', message: '아침 러닝 완료', time: '1일 전'),
    _FriendItem(name: '정다운', message: '10km 도전 중', time: '2일 전'),
  ];

  static const _chats = [
    _ChatItem(name: '김지훈', message: '오늘 같이 뛸래?', time: '10분 전', unread: 2),
    _ChatItem(name: '이민지', message: '기록 대박이다!', time: '1시간 전'),
    _ChatItem(name: '박서연', message: '내일 아침에 봐요', time: '3시간 전'),
    _ChatItem(name: '최준호', message: '페이스 어떻게 유지해?', time: '1일 전', unread: 1),
  ];

  @override
  Widget build(BuildContext context) {
    final showingFriends = _view == _FriendsView.list;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 34, 22, 32),
          children: [
            Text(
              '친구',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '함께 달리는 사람들의 작은 신호',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 24),
            _SegmentedTabs(
              selected: _view,
              onChanged: (view) => setState(() => _view = view),
            ),
            if (showingFriends) ...[
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('친구 추가'),
              ),
              const SizedBox(height: 24),
              for (final friend in _friends) _FriendCard(friend: friend),
            ] else ...[
              const SizedBox(height: 24),
              for (final chat in _chats) _ChatCard(chat: chat),
            ],
          ],
        ),
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.selected, required this.onChanged});

  final _FriendsView selected;
  final ValueChanged<_FriendsView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          _SegmentButton(
            label: '친구 목록',
            selected: selected == _FriendsView.list,
            onTap: () => onChanged(_FriendsView.list),
          ),
          _SegmentButton(
            label: '채팅',
            selected: selected == _FriendsView.chat,
            onTap: () => onChanged(_FriendsView.chat),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceHigh : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.text : AppColors.muted,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({required this.friend});

  final _FriendItem friend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const _Avatar(),
            const SizedBox(width: 14),
            Expanded(
              child: _PersonText(name: friend.name, message: friend.message),
            ),
            Text(
              friend.time,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatCard extends StatelessWidget {
  const _ChatCard({required this.chat});

  final _ChatItem chat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const _Avatar(),
            const SizedBox(width: 14),
            Expanded(
                child: _PersonText(name: chat.name, message: chat.message)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (chat.unread > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${chat.unread}',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarFill = isDark ? const Color(0xFF20242B) : Colors.white;
    final line = isDark ? const Color(0xFF2A3038) : const Color(0xFFE0E4EA);
    final muted = isDark ? const Color(0xFF9AA3AF) : const Color(0xFF6B7280);

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: avatarFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: line),
      ),
      child: Icon(Icons.person, size: 20, color: muted),
    );
  }
}

class _PersonText extends StatelessWidget {
  const _PersonText({required this.name, required this.message});

  final String name;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            color: AppColors.text,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          message,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FriendItem {
  const _FriendItem({
    required this.name,
    required this.message,
    required this.time,
  });
  final String name;
  final String message;
  final String time;
}

class _ChatItem {
  const _ChatItem({
    required this.name,
    required this.message,
    required this.time,
    this.unread = 0,
  });
  final String name;
  final String message;
  final String time;
  final int unread;
}
