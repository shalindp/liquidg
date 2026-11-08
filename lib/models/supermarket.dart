enum Supermarket {
  woolworths('Woolworths', 'assets/icons/woolworths_logo.png', 1),
  paknsave('PAK’nSAVE', 'assets/icons/paknsave_logo.png', 1),
  newWorld('New World', 'assets/icons/newworld_logo.svg', 0.75);

  const Supermarket(this.label, this.logoAsset, this.logoScale);

  final String label;
  final String logoAsset;
  final double logoScale;

  static Supermarket? fromRetailerId(int id) => switch (id) {
    1 => Supermarket.woolworths,
    2 => Supermarket.paknsave,
    3 => Supermarket.newWorld,
    _ => null,
  };
}
