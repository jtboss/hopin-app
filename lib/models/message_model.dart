import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

/// Message model for in-app chat functionality
class MessageModel {
  final String messageId;
  final String channelId;
  final String senderId;
  final UserModel sender;
  final String content;
  final MessageType type;
  final DateTime sentAt;
  final Map<String, DateTime> readBy;
  final List<MessageAttachment>? attachments;

  const MessageModel({
    required this.messageId,
    required this.channelId,
    required this.senderId,
    required this.sender,
    required this.content,
    required this.type,
    required this.sentAt,
    required this.readBy,
    this.attachments,
  });

  /// Creates a copy of this message with the given fields replaced
  MessageModel copyWith({
    String? messageId,
    String? channelId,
    String? senderId,
    UserModel? sender,
    String? content,
    MessageType? type,
    DateTime? sentAt,
    Map<String, DateTime>? readBy,
    List<MessageAttachment>? attachments,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      channelId: channelId ?? this.channelId,
      senderId: senderId ?? this.senderId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      type: type ?? this.type,
      sentAt: sentAt ?? this.sentAt,
      readBy: readBy ?? this.readBy,
      attachments: attachments ?? this.attachments,
    );
  }

  /// Converts the model to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'channelId': channelId,
      'senderId': senderId,
      'sender': sender.toJson(),
      'content': content,
      'type': type.name,
      'sentAt': Timestamp.fromDate(sentAt),
      'readBy': readBy.map((userId, readAt) => MapEntry(userId, Timestamp.fromDate(readAt))),
      'attachments': attachments?.map((a) => a.toJson()).toList(),
    };
  }

  /// Creates a MessageModel from JSON data
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['messageId'] ?? '',
      channelId: json['channelId'] ?? '',
      senderId: json['senderId'] ?? '',
      sender: UserModel.fromJson(json['sender'] ?? {}),
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      sentAt: (json['sentAt'] as Timestamp).toDate(),
      readBy: (json['readBy'] as Map<String, dynamic>? ?? {}).map(
        (userId, timestamp) => MapEntry(userId, (timestamp as Timestamp).toDate()),
      ),
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((a) => MessageAttachment.fromJson(a))
          .toList(),
    );
  }

  /// Creates a MessageModel from a Firestore DocumentSnapshot
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['messageId'] = doc.id;
    return MessageModel.fromJson(data);
  }

  /// Check if message has been read by a specific user
  bool isReadBy(String userId) => readBy.containsKey(userId);

  /// Get formatted time string
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(sentAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.messageId == messageId;
  }

  @override
  int get hashCode => messageId.hashCode;

  @override
  String toString() {
    return 'MessageModel(messageId: $messageId, senderId: $senderId, type: $type, content: ${content.substring(0, content.length > 20 ? 20 : content.length)}...)';
  }
}

/// Types of messages that can be sent
enum MessageType {
  text,         // Regular text message
  system,       // System generated message (ride updates, etc.)
  location,     // Location sharing
  image,        // Image attachment
  rideUpdate,   // Ride status update
}

/// Message attachment model
class MessageAttachment {
  final String attachmentId;
  final AttachmentType type;
  final String url;
  final String fileName;
  final int? fileSize;
  final Map<String, dynamic>? metadata;

  const MessageAttachment({
    required this.attachmentId,
    required this.type,
    required this.url,
    required this.fileName,
    this.fileSize,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'attachmentId': attachmentId,
      'type': type.name,
      'url': url,
      'fileName': fileName,
      'fileSize': fileSize,
      'metadata': metadata,
    };
  }

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      attachmentId: json['attachmentId'] ?? '',
      type: AttachmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AttachmentType.image,
      ),
      url: json['url'] ?? '',
      fileName: json['fileName'] ?? '',
      fileSize: json['fileSize'],
      metadata: json['metadata'],
    );
  }

  MessageAttachment copyWith({
    String? attachmentId,
    AttachmentType? type,
    String? url,
    String? fileName,
    int? fileSize,
    Map<String, dynamic>? metadata,
  }) {
    return MessageAttachment(
      attachmentId: attachmentId ?? this.attachmentId,
      type: type ?? this.type,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Types of attachments
enum AttachmentType {
  image,
  location,
  document,
}

/// Chat channel model for organizing conversations
class ChatChannelModel {
  final String channelId;
  final String rideId;
  final List<String> participants;
  final List<UserModel> participantUsers;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCounts;
  final DateTime createdAt;
  final ChannelType type;
  final ChannelStatus status;

  const ChatChannelModel({
    required this.channelId,
    required this.rideId,
    required this.participants,
    required this.participantUsers,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSenderId,
    required this.unreadCounts,
    required this.createdAt,
    required this.type,
    required this.status,
  });

  /// Creates a copy of this channel with the given fields replaced
  ChatChannelModel copyWith({
    String? channelId,
    String? rideId,
    List<String>? participants,
    List<UserModel>? participantUsers,
    String? lastMessage,
    DateTime? lastMessageAt,
    String? lastMessageSenderId,
    Map<String, int>? unreadCounts,
    DateTime? createdAt,
    ChannelType? type,
    ChannelStatus? status,
  }) {
    return ChatChannelModel(
      channelId: channelId ?? this.channelId,
      rideId: rideId ?? this.rideId,
      participants: participants ?? this.participants,
      participantUsers: participantUsers ?? this.participantUsers,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }

  /// Converts the model to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'channelId': channelId,
      'rideId': rideId,
      'participants': participants,
      'participantUsers': participantUsers.map((u) => u.toJson()).toList(),
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCounts': unreadCounts,
      'createdAt': Timestamp.fromDate(createdAt),
      'type': type.name,
      'status': status.name,
    };
  }

  /// Creates a ChatChannelModel from JSON data
  factory ChatChannelModel.fromJson(Map<String, dynamic> json) {
    return ChatChannelModel(
      channelId: json['channelId'] ?? '',
      rideId: json['rideId'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
      participantUsers: (json['participantUsers'] as List<dynamic>? ?? [])
          .map((u) => UserModel.fromJson(u))
          .toList(),
      lastMessage: json['lastMessage'],
      lastMessageAt: json['lastMessageAt'] != null 
          ? (json['lastMessageAt'] as Timestamp).toDate() 
          : null,
      lastMessageSenderId: json['lastMessageSenderId'],
      unreadCounts: Map<String, int>.from(json['unreadCounts'] ?? {}),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      type: ChannelType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChannelType.ride,
      ),
      status: ChannelStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ChannelStatus.active,
      ),
    );
  }

  /// Creates a ChatChannelModel from a Firestore DocumentSnapshot
  factory ChatChannelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['channelId'] = doc.id;
    return ChatChannelModel.fromJson(data);
  }

  /// Get unread count for a specific user
  int getUnreadCount(String userId) => unreadCounts[userId] ?? 0;

  /// Check if channel has unread messages for a user
  bool hasUnreadMessages(String userId) => getUnreadCount(userId) > 0;

  /// Get other participants (excluding current user)
  List<UserModel> getOtherParticipants(String currentUserId) {
    return participantUsers.where((user) => user.uid != currentUserId).toList();
  }

  /// Get formatted last message time
  String get formattedLastMessageTime {
    if (lastMessageAt == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt!);
    
    if (difference.inDays > 7) {
      return '${lastMessageAt!.day}/${lastMessageAt!.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatChannelModel && other.channelId == channelId;
  }

  @override
  int get hashCode => channelId.hashCode;

  @override
  String toString() {
    return 'ChatChannelModel(channelId: $channelId, rideId: $rideId, participants: ${participants.length}, type: $type)';
  }
}

/// Types of chat channels
enum ChannelType {
  ride,         // Ride-specific conversation
  direct,       // Direct message between two users
  group,        // Group conversation
}

/// Status of chat channels
enum ChannelStatus {
  active,       // Active conversation
  archived,     // Archived conversation
  muted,        // Muted conversation
}