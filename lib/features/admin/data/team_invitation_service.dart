import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TeamMemberStatus { active, pendingInvite }

class TeamMember {
  final String id;
  final String name;
  final String email;
  final String role; // 'Manager', 'Warehouse Worker', 'Driver'
  final TeamMemberStatus status;
  final DateTime createdAt;

  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.status = TeamMemberStatus.active,
    required this.createdAt,
  });

  TeamMember copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    TeamMemberStatus? status,
    DateTime? createdAt,
  }) {
    return TeamMember(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TeamInvitationService {
  const TeamInvitationService();

  /// Dispatches an invitation for a new team member to AWS Cognito
  /// (AdminCreateUser / AWS Lambda Admin Action equivalent).
  Future<TeamMember> inviteStaffMember({
    required String name,
    required String email,
    required String role,
  }) async {
    // Determine the corresponding Cognito User Group
    final cognitoGroup = switch (role.toLowerCase()) {
      'manager' => 'Managers',
      'warehouse worker' || 'worker' => 'Workers',
      'driver' => 'Drivers',
      _ => 'Workers',
    };

    debugPrint(
      'Dispatching AdminCreateUser to AWS Cognito: '
      'email=$email, name=$name, group=$cognitoGroup, with temporary password dispatch.',
    );

    // Simulate backend network dispatch latency
    await Future.delayed(const Duration(milliseconds: 300));

    final id =
        'usr_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';

    return TeamMember(
      id: id,
      name: name,
      email: email,
      role: role,
      status: TeamMemberStatus.pendingInvite,
      createdAt: DateTime.now(),
    );
  }
}

final teamInvitationServiceProvider = Provider<TeamInvitationService>((ref) {
  return const TeamInvitationService();
});

class TeamMembersNotifier extends Notifier<List<TeamMember>> {
  @override
  List<TeamMember> build() {
    return [
      TeamMember(
        id: 'usr_001',
        name: 'Sarah Jenkins',
        email: 'sarah.jenkins@quickstock.internal',
        role: 'Manager',
        status: TeamMemberStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      TeamMember(
        id: 'usr_002',
        name: 'Mike Ross',
        email: 'mike.ross@quickstock.internal',
        role: 'Driver',
        status: TeamMemberStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      TeamMember(
        id: 'usr_003',
        name: 'Carlos Ruiz',
        email: 'carlos.ruiz@quickstock.internal',
        role: 'Warehouse Worker',
        status: TeamMemberStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }

  Future<TeamMember> inviteMember({
    required String name,
    required String email,
    required String role,
  }) async {
    final service = ref.read(teamInvitationServiceProvider);
    final member = await service.inviteStaffMember(
      name: name,
      email: email,
      role: role,
    );
    // Prepend the new member in Pending Invite status
    state = [member, ...state];
    return member;
  }
}

final teamMembersProvider =
    NotifierProvider<TeamMembersNotifier, List<TeamMember>>(() {
  return TeamMembersNotifier();
});
