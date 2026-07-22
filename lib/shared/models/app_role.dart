enum AppRole {
  mechanic,
  wholesaler,
  customer,
  staff,
  unknown;

  bool get isPartner => this == mechanic || this == wholesaler;
}
