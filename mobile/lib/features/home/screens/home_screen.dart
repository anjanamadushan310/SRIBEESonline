/// SRIBEESonline - Home Screen
///
/// Layout matches the SRIBEESonline app design:
///   AppBar   → maroon header + search bar
///   Body     → hero banner · shop by category · today's deals grid
///   NavBar   → HOME | SAVED | AI-Cart FAB | ORDERS | PROFILE
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/language_provider.dart';
import '../../cart/screens/cart_screen.dart';

const _pink = Color(0xFFB5175A);
const _pinkLight = Color(0xFFE91E8C);
const _bg = Color(0xFFF2F2F2);

// ---------------------------------------------------------------------------
// Mock data (replace with real providers once backend is wired)
// ---------------------------------------------------------------------------
final _categories = [
  _Category('Agro', Icons.eco_rounded, const Color(0xFFE8F5E9)),
  _Category('Groceries', Icons.local_grocery_store_rounded, const Color(0xFFFFF8E1)),
  _Category('Electronics', Icons.headphones_rounded, const Color(0xFFE3F2FD)),
  _Category('Express', Icons.delivery_dining_rounded, const Color(0xFFFFEBEE)),
];

final _deals = [
  _Deal('Organic Bananas', 900, 10, 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=400'),
  _Deal('Fuji Apples', 1350, 10, 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400'),
  _Deal('Fresh Broccoli', 600, 10, 'https://images.unsplash.com/photo-1584270354949-c26b0d5b4a0c?w=400'),
  _Deal('Fresh Spinach', 450, 10, 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400'),
];

final _banners = [
  _Banner('Fresh Farm Produce', 'Delivered straight to you.',
      'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=800'),
  _Banner('Today\'s Best Deals', 'Up to 20% off on fresh vegetables.',
      'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800'),
  _Banner('Fast Delivery', 'Get groceries in under 60 minutes.',
      'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800'),
];

// ---------------------------------------------------------------------------
// Home Screen
// ---------------------------------------------------------------------------

class HomeScreen extends ConsumerStatefulWidget {
  final String? branchName;
  const HomeScreen({super.key, this.branchName});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _pageController = PageController();
  int _selectedNav = 0;
  int _bannerPage = 0;

  // Mock cart total
  double _cartTotal = 1100.99;

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = ref.watch(languageProvider)?.languageCode ?? 'en';

    return Scaffold(
      backgroundColor: _bg,
      // ── AppBar ────────────────────────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(116 + MediaQuery.of(context).padding.top),
        child: _AppBar(
          cartTotal: _cartTotal,
          searchController: _searchController,
          langCode: langCode,
        ),
      ),
      // ── Body ──────────────────────────────────────────────────────────────
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner
            _HeroBanner(
              banners: _banners,
              controller: _pageController,
              currentPage: _bannerPage,
              onPageChanged: (p) => setState(() => _bannerPage = p),
            ),

            const SizedBox(height: 20),

            // Shop by Category
            _SectionHeader(title: 'Shop by Category'),
            const SizedBox(height: 12),
            _CategoryRow(categories: _categories),

            const SizedBox(height: 20),

            // Today's Deals
            _SectionHeader(title: 'Today\'s Deals'),
            const SizedBox(height: 12),
            _DealsGrid(
              deals: _deals,
              onAddToCart: (deal) {
                setState(() => _cartTotal += deal.price);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${deal.name} added to cart'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: _pink,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            const SizedBox(height: 80), // space above nav bar
          ],
        ),
      ),
      // ── Bottom Nav ────────────────────────────────────────────────────────
      bottomNavigationBar: _BottomNav(
        selected: _selectedNav,
        onTap: (i) => setState(() => _selectedNav = i),
      ),
      floatingActionButton: _AICartFab(onTap: () {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// ---------------------------------------------------------------------------
// AppBar
// ---------------------------------------------------------------------------

class _AppBar extends StatelessWidget {
  final double cartTotal;
  final TextEditingController searchController;
  final String langCode;

  const _AppBar({
    required this.cartTotal,
    required this.searchController,
    required this.langCode,
  });

  String get _searchHint => langCode == 'si'
      ? 'සොයන්න......'
      : langCode == 'ta'
          ? 'தேடு......'
          : 'Search for......';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _pink,
      padding: const EdgeInsets.fromLTRB(4, 0, 8, 12),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Hamburger
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                ),

                // Logo
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SRIBEES',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Online',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Cart with total price badge
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_cart_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 4),
                        Text(
                          'Rs${cartTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Search bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: _searchHint,
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[500], size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero Banner
// ---------------------------------------------------------------------------

class _HeroBanner extends StatelessWidget {
  final List<_Banner> banners;
  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const _HeroBanner({
    required this.banners,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: banners.length,
            itemBuilder: (_, i) => _BannerCard(banner: banners[i]),
          ),
        ),

        // Dots
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (i) {
              final active = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final _Banner banner;
  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(
              banner.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                  ),
                ),
              ),
            ),
            // Dark gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            // Text + button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    banner.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    banner.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Shop Now'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category Row
// ---------------------------------------------------------------------------

class _CategoryRow extends StatelessWidget {
  final List<_Category> categories;
  const _CategoryRow({required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _CategoryTile(category: categories[i]),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final _Category category;
  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: category.bgColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(category.icon, size: 30, color: _pink),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Deals Grid
// ---------------------------------------------------------------------------

class _DealsGrid extends StatelessWidget {
  final List<_Deal> deals;
  final ValueChanged<_Deal> onAddToCart;

  const _DealsGrid({required this.deals, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: deals.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (_, i) => _DealCard(
          deal: deals[i],
          onAdd: () => onAddToCart(deals[i]),
        ),
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  final _Deal deal;
  final VoidCallback onAdd;

  const _DealCard({required this.deal, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + cash back badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Image.network(
                  deal.imageUrl,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 130,
                    color: const Color(0xFFF0F0F0),
                    child: Icon(Icons.image_outlined,
                        color: Colors.grey[400], size: 40),
                  ),
                ),
              ),
              // Cash Back badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _pinkLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${deal.cashBackPct}% Cash Back',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Name + price + add button
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    deal.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rs. ${deal.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: _pink,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: onAdd,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: _pink,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom Navigation
// ---------------------------------------------------------------------------

class _BottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 62,
      padding: EdgeInsets.zero,
      notchMargin: 6,
      shape: const CircularNotchedRectangle(),
      color: _pink,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_rounded, label: 'HOME', index: 0, selected: selected, onTap: onTap),
          _NavItem(icon: Icons.favorite_border_rounded, label: 'SAVED', index: 1, selected: selected, onTap: onTap),
          const SizedBox(width: 56),
          _NavItem(icon: Icons.receipt_long_outlined, label: 'ORDERS', index: 2, selected: selected, onTap: onTap),
          _NavItem(icon: Icons.person_outline_rounded, label: 'PROFILE', index: 3, selected: selected, onTap: onTap),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selected;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == selected;
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 24,
                color: active ? Colors.white : Colors.white.withValues(alpha: 0.65)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? Colors.white : Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AI Cart FAB
// ---------------------------------------------------------------------------

class _AICartFab extends StatelessWidget {
  final VoidCallback onTap;
  const _AICartFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

class _Category {
  final String name;
  final IconData icon;
  final Color bgColor;
  const _Category(this.name, this.icon, this.bgColor);
}

class _Deal {
  final String name;
  final double price;
  final int cashBackPct;
  final String imageUrl;
  const _Deal(this.name, this.price, this.cashBackPct, this.imageUrl);
}

class _Banner {
  final String title;
  final String subtitle;
  final String imageUrl;
  const _Banner(this.title, this.subtitle, this.imageUrl);
}
