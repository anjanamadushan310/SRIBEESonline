/// SRIBEESonline - Main shell + Home tab
///
/// `HomeScreen` is the app's tabbed shell (Home / Saved / Orders / Profile)
/// matching the "SRIBEES Online" prototype: a shared magenta header and white
/// bottom nav with a center sparkle FAB stay fixed while the body switches
/// between tab bodies (IndexedStack keeps each tab's state). Cart and Product
/// open as pushed routes on top of the shell.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/sribees_design.dart';
import '../../../core/providers/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';
import '../../orders/screens/orders_screen.dart';
import '../../products/screens/product_details_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../saved/screens/saved_screen.dart';

// ---------------------------------------------------------------------------
// Shell
// ---------------------------------------------------------------------------

class HomeScreen extends ConsumerWidget {
  final String? branchName;
  const HomeScreen({super.key, this.branchName});

  void _openCart(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(mainTabProvider);

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          SribeesHeader(
            onMenu: () => showToast(context, 'Menu'),
            onCart: () => _openCart(context),
          ),
          Expanded(
            child: IndexedStack(
              index: tab,
              children: const [
                _HomeTab(),
                SavedTab(),
                OrdersTab(),
                ProfileTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SribeesBottomNav(
        selected: tab,
        onTap: (i) => ref.read(mainTabProvider.notifier).state = i,
      ),
      floatingActionButton: SribeesSparkleFab(
        onTap: () => showToast(context, '✨ AI shopping assistant'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// ---------------------------------------------------------------------------
// Deal data (gradient placeholders, mirrors the prototype)
// ---------------------------------------------------------------------------

class _Deal {
  final String key;
  final String name;
  final double price;
  final String unit;
  final String rating;
  const _Deal(this.key, this.name, this.price, this.unit, this.rating);
}

const _deals = <_Deal>[
  _Deal('bananas', 'Organic Bananas', 900, '1kg · Fresh from farm', '4.8'),
  _Deal('apples', 'Fuji Apples', 1350, 'Pack of 4 · Crisp & sweet', '4.9'),
  _Deal('broccoli', 'Fresh Broccoli', 600, '500g · Farm picked', '4.7'),
  _Deal('spinach', 'Fresh Spinach', 450, '250g · Pesticide free', '4.8'),
];

class _Category {
  final String name;
  final IconData icon;
  final Color iconColor;
  final Color a;
  final Color b;
  const _Category(this.name, this.icon, this.iconColor, this.a, this.b);
}

const _categories = <_Category>[
  _Category('Agro', Icons.eco_outlined, Color(0xFF3F7A2C), Color(0xFFCFE8C0),
      Color(0xFFA6D68F)),
  _Category('Groceries', Icons.shopping_bag_outlined, Color(0xFFA06B1A),
      Color(0xFFF2DCB4), Color(0xFFE3BF80)),
  _Category('Electronics', Icons.devices_other_outlined, Color(0xFF4A5A72),
      Color(0xFFCDD6E2), Color(0xFFA5B2C4)),
  _Category('Express', Icons.delivery_dining_outlined, kMagenta,
      Color(0xFFFBD9E6), Color(0xFFF4B3CD)),
  _Category('Meat', Icons.kebab_dining_outlined, Color(0xFFB0463F),
      Color(0xFFF0C0BD), Color(0xFFDD8E88)),
];

class _Banner {
  final String title;
  final String subtitle;
  final Color a;
  final Color b;
  const _Banner(this.title, this.subtitle, this.a, this.b);
}

const _banners = <_Banner>[
  _Banner('Fresh Farm Produce', 'Delivered straight to you.', Color(0xFF7A4A2C),
      Color(0xFFD68A3C)),
  _Banner('20% Off Greens', 'This weekend only.', Color(0xFF5A7A3C),
      Color(0xFF9BBF5C)),
  _Banner('Earn 10% Cash Back', 'On every single order.', Color(0xFF8A3A4C),
      Color(0xFFC5607A)),
];

// ---------------------------------------------------------------------------
// Home tab body
// ---------------------------------------------------------------------------

class _HomeTab extends ConsumerStatefulWidget {
  const _HomeTab();

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<_HomeTab> {
  final _pageController = PageController();
  int _bannerPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _addDeal(_Deal d) {
    ref.read(cartProvider.notifier).addItem(
          productId: d.key,
          price: d.price,
          name: d.name,
        );
    showToast(context, '${d.name} added to cart');
  }

  void _openProduct(_Deal d) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ProductDetailsScreen(
        productKey: d.key,
        name: d.name,
        unit: d.unit,
        price: d.price,
        rating: d.rating,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchPill(onTap: () => showToast(context, 'Search')),
          const SizedBox(height: 22),
          _BannerCarousel(
            controller: _pageController,
            page: _bannerPage,
            onPageChanged: (p) => setState(() => _bannerPage = p),
            onDot: (i) => _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
            ),
            onShop: () => showToast(context, 'Browse today’s deals below'),
          ),
          const SizedBox(height: 26),
          const _SectionTitle('Shop by Category'),
          const SizedBox(height: 16),
          _CategoryRow(onTap: (c) => showToast(context, '${c.name} category')),
          const SizedBox(height: 30),
          const _SectionTitle("Today's Deals"),
          const SizedBox(height: 16),
          _DealsGrid(onAdd: _addDeal, onOpen: _openProduct),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search pill
// ---------------------------------------------------------------------------

class _SearchPill extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: kBorder, width: 1.5),
          boxShadow: cardShadow(opacity: 0.10),
        ),
        child: Row(
          children: const [
            Icon(Icons.search_rounded, color: Color(0xFF9B97A1), size: 22),
            SizedBox(width: 11),
            Text('Search for.......',
                style: TextStyle(color: kPlaceholder, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section title
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: kInk,
        letterSpacing: -0.3,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Banner carousel
// ---------------------------------------------------------------------------

class _BannerCarousel extends StatelessWidget {
  final PageController controller;
  final int page;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onDot;
  final VoidCallback onShop;

  const _BannerCarousel({
    required this.controller,
    required this.page,
    required this.onPageChanged,
    required this.onDot,
    required this.onShop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 160,
            child: PageView.builder(
              controller: controller,
              onPageChanged: onPageChanged,
              itemCount: _banners.length,
              itemBuilder: (_, i) =>
                  _BannerSlide(banner: _banners[i], onShop: onShop),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final active = i == page;
            return GestureDetector(
              onTap: () => onDot(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                height: 6,
                width: active ? 20 : 6,
                decoration: BoxDecoration(
                  color: active ? kMagenta : const Color(0xFFD7D3DC),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerSlide extends StatelessWidget {
  final _Banner banner;
  final VoidCallback onShop;
  const _BannerSlide({required this.banner, required this.onShop});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
            decoration: BoxDecoration(gradient: swatch(banner.a, banner.b))),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFF32190A).withValues(alpha: 0.6),
                const Color(0xFF32190A).withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.68],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 200,
                child: Text(
                  banner.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    shadows: [
                      Shadow(
                          color: Color(0x4D000000),
                          blurRadius: 8,
                          offset: Offset(0, 2)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                banner.subtitle,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92), fontSize: 14),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onShop,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                  decoration: BoxDecoration(
                      color: kMagenta, borderRadius: BorderRadius.circular(22)),
                  child: const Text(
                    'Shop Now',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Category row
// ---------------------------------------------------------------------------

class _CategoryRow extends StatelessWidget {
  final ValueChanged<_Category> onTap;
  const _CategoryRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final c = _categories[i];
          return GestureDetector(
            onTap: () => onTap(c),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 66,
              child: Column(
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      gradient: swatch(c.a, c.b),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 1.5),
                    ),
                    child: Icon(c.icon, color: c.iconColor, size: 30),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kInk2),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Deals grid
// ---------------------------------------------------------------------------

class _DealsGrid extends StatelessWidget {
  final ValueChanged<_Deal> onAdd;
  final ValueChanged<_Deal> onOpen;
  const _DealsGrid({required this.onAdd, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.74,
      ),
      itemCount: _deals.length,
      itemBuilder: (_, i) => _DealCard(
        deal: _deals[i],
        onAdd: () => onAdd(_deals[i]),
        onOpen: () => onOpen(_deals[i]),
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  final _Deal deal;
  final VoidCallback onAdd;
  final VoidCallback onOpen;
  const _DealCard(
      {required this.deal, required this.onAdd, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: cardShadow(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                        decoration:
                            BoxDecoration(gradient: gradientFor(deal.key))),
                    const Align(
                        alignment: Alignment.topLeft, child: CashBackBadge()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 11),
            Text(
              deal.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kInk,
                  height: 1.2),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rs. ${money(deal.price)}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kMagenta),
                ),
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 31,
                    height: 31,
                    decoration: BoxDecoration(
                      color: kMagenta,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: kMagenta.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: -4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
