import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../applications/domain/entities/application_entity.dart';
import '../../../applications/presentation/controllers/applications_provider.dart';
import '../../../auth/presentation/controllers/auth_provider.dart';

class InboxScreen extends ConsumerStatefulWidget {
  final ApplicationEntity? initialApplication;

  const InboxScreen({
    super.key,
    this.initialApplication,
  });

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  String? _activeThreadId;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialApplication != null) {
      _activeThreadId = widget.initialApplication!.id;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String appId) async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _messageController.clear();
      try {
        await ref.read(applicationsControllerProvider).sendChatMessage(appId, text);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send message: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.currentUser;
    final isOwner = currentUser?.role == 'startup_owner';

    final appsAsync = ref.watch(applicationsStreamProvider);

    return appsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error loading inbox: $err')),
      ),
      data: (apps) {
        // If we have an active thread, find the application details
        final activeApp = _activeThreadId == null
            ? null
            : apps.firstWhere((a) => a.id == _activeThreadId, orElse: () => apps.first);

        final titleText = activeApp == null
            ? 'Inbox Messages'
            : (isOwner ? activeApp.studentName : activeApp.startupName);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(titleText),
            automaticallyImplyLeading: false,
            leading: activeApp == null
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => setState(() => _activeThreadId = null),
                  ),
          ),
          body: SafeArea(
            child: activeApp == null
                ? _buildThreadList(apps, isOwner)
                : _buildChatPane(activeApp),
          ),
          bottomNavigationBar: activeApp == null ? _buildBottomNav(context, 3) : null,
        );
      },
    );
  }

  Widget _buildThreadList(List<ApplicationEntity> apps, bool isOwner) {
    if (apps.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textSecondary),
              SizedBox(height: 16),
              Text(
                'No conversations yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
              ),
              SizedBox(height: 8),
              Text(
                'Tapping on "Feedback/Chat" on any application tracking screen will start a live conversation thread here.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        final lastMsgText = app.lastMessageText ?? 'Applied for "${app.opportunityTitle}". Tap to start chatting.';
        final lastMsgTime = app.lastMessageTime ?? app.appliedAt;
        final senderName = app.lastMessageSenderName ?? 'System';

        final threadTitle = isOwner ? app.studentName : app.startupName;
        final logo = isOwner ? '' : app.startupLogoUrl;

        return GestureDetector(
          onTap: () {
            setState(() {
              _activeThreadId = app.id;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: isOwner
                      ? Text(
                          threadTitle.isNotEmpty ? threadTitle[0].toUpperCase() : 'C',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : (logo.startsWith('/') || logo.contains('content://'))
                          ? ClipOval(
                              child: Image.file(
                                File(logo),
                                fit: BoxFit.cover,
                                width: 44,
                                height: 44,
                              ),
                            )
                          : Text(
                              logo.isNotEmpty ? logo : '🚀',
                              style: const TextStyle(fontSize: 22),
                            ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            threadTitle,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            '${lastMsgTime.hour}:${lastMsgTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$senderName: $lastMsgText',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatPane(ApplicationEntity app) {
    final messagesAsync = ref.watch(applicationMessagesStreamProvider(app.id));

    return Column(
      children: [
        // Sub-header details
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Text(
            'Role: ${app.opportunityTitle}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        // Message timeline bubbles
        Expanded(
          child: messagesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (messages) {
              if (messages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'No messages in this chat. Type a message below to start your conversation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment:
                          msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: msg.isMe ? AppColors.primary : Colors.grey.shade200,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: msg.isMe ? const Radius.circular(16) : Radius.zero,
                              bottomRight: msg.isMe ? Radius.zero : const Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              color: msg.isMe ? Colors.white : AppColors.text,
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${msg.sender} • ${msg.time.hour}:${msg.time.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Message input text field bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(app.id),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _sendMessage(app.id),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, int activeIndex) {
    return BottomNavigationBar(
      currentIndex: activeIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      onTap: (index) {
        if (index == 0) context.go('/explore');
        if (index == 1) context.go('/saved');
        if (index == 2) context.go('/applications');
        if (index == 3) context.go('/inbox');
        if (index == 4) context.go('/profile');
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_outline),
          label: 'Saved',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          label: 'Applications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Inbox',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
