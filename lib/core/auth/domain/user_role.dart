enum UserRole {
  admin,
  manager,
  worker,
  driver,
  customer,
  guest;

  bool get isStaff =>
      this == UserRole.admin ||
      this == UserRole.manager ||
      this == UserRole.worker ||
      this == UserRole.driver;

  bool get canManageInventory =>
      this == UserRole.admin || this == UserRole.manager;

  bool get isDriver => this == UserRole.driver;

  bool get isCustomer => this == UserRole.customer || this == UserRole.guest;
}
