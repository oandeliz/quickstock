import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickstock/features/admin/data/team_invitation_service.dart';

void main() {
  group('TeamInvitationService & teamMembersProvider', () {
    test('initial state contains baseline active team members', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final members = container.read(teamMembersProvider);
      expect(members.length, 3);
      expect(members[0].name, 'Sarah Jenkins');
      expect(members[0].status, TeamMemberStatus.active);
      expect(members[1].name, 'Mike Ross');
      expect(members[2].name, 'Carlos Ruiz');
    });

    test('inviteMember prepends new member with pendingInvite status', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(teamMembersProvider.notifier);
      final newMember = await notifier.inviteMember(
        name: 'Alice Cooper',
        email: 'alice@quickstock.internal',
        role: 'Driver',
      );

      expect(newMember.name, 'Alice Cooper');
      expect(newMember.email, 'alice@quickstock.internal');
      expect(newMember.role, 'Driver');
      expect(newMember.status, TeamMemberStatus.pendingInvite);

      final members = container.read(teamMembersProvider);
      expect(members.length, 4);
      expect(members.first.name, 'Alice Cooper');
      expect(members.first.status, TeamMemberStatus.pendingInvite);
    });

    test('inviteStaffMember maps roles correctly and generates unique IDs', () async {
      const service = TeamInvitationService();
      final manager = await service.inviteStaffMember(
        name: 'Bob Manager',
        email: 'bob@example.com',
        role: 'Manager',
      );

      expect(manager.role, 'Manager');
      expect(manager.status, TeamMemberStatus.pendingInvite);
      expect(manager.id, startsWith('usr_'));
    });
  });
}
