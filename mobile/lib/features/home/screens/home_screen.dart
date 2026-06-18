/// SRIBEESonline - Home Screen
///
/// Implements "The Radiant Editorial" design system (DESIGN.md):
///   Primary #D81B60 · Surface #fbf9fb · Plus Jakarta Sans headlines
///
/// Layout:
///   AppBar   → pink, rounded-b-3xl, logo image + cart count badge
///   Search   → sticky below AppBar, frosted pill input
///   Body     → hero banner carousel · shop-by-category row · today's deals grid
///   NavBar   → frosted glass, white bg · HOME|SAVED|[FAB]|ORDERS|PROFILE
///   FAB      → pink gradient, elevated, white border
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/cart_provider.dart';
import '../../cart/screens/cart_screen.dart';
import '../../orders/screens/orders_screen.dart';
import '../../saved/screens/saved_screen.dart';

// ---------------------------------------------------------------------------
// Design tokens
// ---------------------------------------------------------------------------
const _primary = Color(0xFFD81B60);
const _surface = Color(0xFFFBF9FB);
const _surfaceLow = Color(0xFFF5F3F5);
const _surfaceLowest = Color(0xFFFFFFFF);
const _onSurface = Color(0xFF1B1C1D);
const _onSurfaceVariant = Color(0xFF564149);

// ---------------------------------------------------------------------------
// Image CDN base paths (from design HTML)
// ---------------------------------------------------------------------------
const _aidaBase = 'https://lh3.googleusercontent.com/aida/';
const _aidaPubBase = 'https://lh3.googleusercontent.com/aida-public/';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------
class _Category {
  final String name;
  final String imageUrl;
  const _Category(this.name, this.imageUrl);
}

class _Deal {
  final String name;
  final double price;
  final String imageUrl;
  const _Deal(this.name, this.price, this.imageUrl);
}

class _Banner {
  final String imageUrl;
  final String title;
  final String subtitle;
  const _Banner(this.imageUrl, this.title, this.subtitle);
}

// ---------------------------------------------------------------------------
// Static data (mirrors the design HTML exactly)
// ---------------------------------------------------------------------------
final _categories = [
  const _Category('Agro',
      '${_aidaBase}AP1WRLsHmAQY-S7bClho9R9Rz5AJJc_benkcWCIYNnnodEyb4MF56ao3uE2xOnkljUM0yGFVTuywee8ZhasxLxFWQS6MFnwArlFVOqNOyL7e74ggZymQ4gihRKWpIQFPGvtXDyG7RPYzLMC8SkkOzCz9XYTniNF-zYalvOaxvIWSYIan9A2ZCc5SfNRrTleIzTTGjKh5OPlIP0mqZQnTTCJ9mSAhUgdcM_eGr2dQHUXp-Tc9_uiJAPeplygZpWs'),
  const _Category('Groceries',
      '${_aidaBase}AP1WRLvSYbvYNVClPhfCGv3mdwxMCBNqyVXnX-w24DwGpTQKmxPUcv365YXCqPctqzGGYWYuTIOJykOW5xAJGLA48AnV_LXrtTvIW_TZHzpoIGnE1rvXSzXb6wukuo8hp3OzTTxasj7cr_EO4kmdvWpz6EeVmjegWrm0_k3QuLaDT6-QQHCBDQD49_f-clKepa_OWFSbofz1lzYn_TilsYtiSreI9jNfV1emyIEdaBzjorV8BzRkeULLUKVbkg'),
  const _Category('Electronics',
      '${_aidaBase}AP1WRLt_t4qtnpTN4CctzJ2EHLxsvl7O3NJ2jhUadE2Vzk979zwmluz5iQwKnWN6ABPpTAlRgiD_WmHT8s_cG5m4tCPAz7aDxFWWG4vgVFNtt7vkq0jy6FZQys6mpwhxW2iQKhh6V7JEm2aHSuGDx1OIgku3pQwFNtbXPDiS4-kHq9HZEMv1RZ2-C98pxPuDbClw7iEFP35sAi4IWE2kUP21Kx8HYqLjvoBd-pja-ByLuoSacuRiuzGDQz4a_ew'),
  const _Category('Express',
      '${_aidaBase}AP1WRLs12JuZ8yGhsJgJOyrYFDYEzOb41xyERq5R2Xsrb92ztPhipZHVtWsxPEGgx1Cfiks-E2dG-_UW2cTv_hTWvfT6l7ghv9U-gdwoW6_SwPcXj9ToovqtOzJihTnAE67VGb0bOeBesib-B58ChcGBv2j_k6Uccin8OgJQYzYyi3VMLv7QE3fOXCtqvb7flPHwOpUQKdPSciR1MZ8--5f9G0Fdy0gq-AxlTi7T701Qs6gclpLlkBVpu0GszKA'),
  const _Category('Meat',
      '${_aidaBase}AP1WRLvimFWdDn6SiML37wzcyXqk0TGgLRcYN_HG1_2o-lEXxSaGXWGK00_fakQXxD3TAWSfoOFq90Im1X2FHEwo1f40SAnIeWcf106sLrh1UAaN_b9mb4h_LULDtmlggvwiJspbhw1sUpd7MvnXab3l5Kti4-yBoy6Cpwrm90EZkT8wWtu3Tvabf_rhGygbjGXUDefgxe-QISZFwaATaH2OhAR0VTSh9w7dh696Ab_pYhI6OBQLpajcBaqv3Pg'),
  const _Category('Seafood',
      '${_aidaBase}AP1WRLv27SVyh5TfYFNBvIV9dzroSzBdht5WhU4A1kQjqLZ60JEIqdXChLqA1mq3W0ThtKZ2d68FkDC4y_jRUys2egFs34mZkmX2YwnEYUUVdjMGtOrNW87vFToFBU6eNBMr8IRLt-IJfx83_dlwmBqjUnyCmpCJ1MglEqknG4_8jzmjbRl5ywezPu7Bj_ksVubg5AOHNsj4p-kHnRAkX-ghAiDmX-eJ81w5U8rq2oUjd7zoU4GbJQSLxchQfhk'),
  const _Category('Bakery',
      '${_aidaBase}AP1WRLuSG8eM58FOoC4KSg2GJjsvTYhQnckIRbu_Z03JLOLcJDlLZXei2n-1woUdeeOo-85weIiX5698k8t8zcEp1yt-aVxDTNRufbeNV691YbR3V76sB_xvw6bbx2X5kgOwHIy7VH327zaBYoDU7kNKOGm4WIglncBRazEsjshmQYd8h4CtxAmdWKJR_IO9hkYpYUHiyQp-WN_k_uX8HdXxx9Z6z-oKe2TN8QgWIJ3leB7JzVxqnTfkgW1oZks'),
  const _Category('Household',
      '${_aidaBase}AP1WRLs1mhJVCjzOjw68tNSMiahXuhl56d3ScL0PcakS-U6jUva4rd1bm-7rPqsY10rMwH_bm-h_pxI8afDvn9ze5axw8A8gDcJaXS8OPBe6Wkbrv5M_n3z0xjGqgyr3L6eClvu0fZTph07DJeWOEHgGxqtyFMh2Wr-ymBphCg4ggIZOzAa31miG3zHjlkg-wRn2O1V83OhKcnHQdFgOevaRuOU9n2Db3kSVY6dDRULjL4Szxu6hmtLeY4iua-Q'),
  const _Category('Beverages',
      '${_aidaBase}AP1WRLukujTkZ0sYITBQBhIGSM13LJYwAuNLlLw1N8zaSrjeN-fZfsQDNsqDiJnSTlJdC-d43oKXWB0xV7K4DbmRcgFRQ3zHHiqckvpuBSRxHlNwndObhc1plfUsk6M3pMKBCXluQEFJSJUTyS1GSc8a0ySVTXIZ8FGJ0dczSvEbcTK063G174REVJHhP4gzHSrReSMp3FRpOqlMa2dz-hf4TcqDv3OGgPkLVH-w1uGC-xKNK5HcoRvp7O2Szw'),
];

final _deals = [
  const _Deal('Organic Bananas', 900,
      '${_aidaPubBase}AB6AXuAhB77Bhd9QvJSKQMsizV9Jd_0UdoH0uoHkBNQgH_t6fhqH74U3o_beMGkftcyjiuLJiDWMADg1LrE_tgrgisNrurzIMeUXI09GIp-AgNrZQmdLUxKiqiaeyjH9Hp0jn6h0wZ5GSzoFeTRaZ5x1nvf06XV6BfNUVnq9w4LBwNnzisAisogWoElHhkbp_jZHQor42e7xA8GYltRNDlVIZXvBvXY71URYvWtqGqLkeL9bcwrQwLyJJadLwWkv24WrgZlO-MyKvw3PTC0'),
  const _Deal('Fuji Apples', 1350,
      '${_aidaPubBase}AB6AXuCqjBvYlqyHAC3JV8mIC63XRVFr5xUW6BslO4IMWIiJiCBN_rnuJwUyyJz7r4xAClpOMKuf51Zo932f1SIeLg6pvl0CHgqHuxCFEr8-WTX4KmZ-OD9-fAZzeR4SXiVMCdYJdpnc7cLQPwBMIU1A0z6u5kghO27HLKkKdhV-0BXky2bOGKnatrxy0grkXcsALqiBG19VGH2AURONXJKYwO5ZjT_FHUrRY3dLGCWHTpqr_fOzCfRHO5IAcAda4BLpcIBSI2JCxOZ1jzg'),
  const _Deal('Fresh Broccoli', 600,
      '${_aidaPubBase}AB6AXuD6ZdB8OUk8DSLJtHXLw7SJU9T4P_9AiNujHubinVi4yXwDRJbDyL8AYuBX1fGE-EQ_4YbEARA2QSe5WIfDa1bOotcH-TLTxfVgZukBZp9OZVYIbK13UHRK6YxsI-iq4t--0dhElF7BdULtgbfrMIuwcQfxD6gIBwikBG5eIb-bztt73DMASc_pl5nU1hK1VmvmhJNBk_PXjo4KkIYbhwbMBQy9wer5rI9eyC-k7ciJrgibgorYW_ofbfpQ1wS5VS0kpkEEf2iTL9Y'),
  const _Deal('Fresh Spinach', 450,
      '${_aidaPubBase}AB6AXuCP1kXVhZUAuylApGNgWcjcvdiCu794KVOdSr6NV8s9zuHkmxqZlGle4Ma2MoobL7TrsfOKIiug597qrTOhD5x_kC_QzhKhMrUii8GfjRBG4W5ys39Y5kEQWWeFEFMENySoBpR8W9rVhPCkwILDnqxQfGQZqIbhC22_scdAZsMmt1Upcbsv1lAJ-o9OKTfzfI23G6tvwDqYGSC6wNsiscwGnHOUtA09SJTV7pcHerXtzyTA6pRo2xKeBfnb1l7CF02rFuL0RH2XFbQ'),
];

final _banners = [
  const _Banner(
    '${_aidaPubBase}AB6AXuCP1kXVhZUAuylApGNgWcjcvdiCu794KVOdSr6NV8s9zuHkmxqZlGle4Ma2MoobL7TrsfOKIiug597qrTOhD5x_kC_QzhKhMrUii8GfjRBG4W5ys39Y5kEQWWeFEFMENySoBpR8W9rVhPCkwILDnqxQfGQZqIbhC22_scdAZsMmt1Upcbsv1lAJ-o9OKTfzfI23G6tvwDqYGSC6wNsiscwGnHOUtA09SJTV7pcHerXtzyTA6pRo2xKeBfnb1l7CF02rFuL0RH2XFbQ',
    'Fresh Farm Produce',
    'Delivered straight to you.',
  ),
  const _Banner(
    '${_aidaPubBase}AB6AXuAhB77Bhd9QvJSKQMsizV9Jd_0UdoH0uoHkBNQgH_t6fhqH74U3o_beMGkftcyjiuLJiDWMADg1LrE_tgrgisNrurzIMeUXI09GIp-AgNrZQmdLUxKiqiaeyjH9Hp0jn6h0wZ5GSzoFeTRaZ5x1nvf06XV6BfNUVnq9w4LBwNnzisAisogWoElHhkbp_jZHQor42e7xA8GYltRNDlVIZXvBvXY71URYvWtqGqLkeL9bcwrQwLyJJadLwWkv24WrgZlO-MyKvw3PTC0',
    'Best Deals Today',
    'Up to 20% off on fresh produce.',
  ),
  const _Banner(
    '${_aidaPubBase}AB6AXuD6ZdB8OUk8DSLJtHXLw7SJU9T4P_9AiNujHubinVi4yXwDRJbDyL8AYuBX1fGE-EQ_4YbEARA2QSe5WIfDa1bOotcH-TLTxfVgZukBZp9OZVYIbK13UHRK6YxsI-iq4t--0dhElF7BdULtgbfrMIuwcQfxD6gIBwikBG5eIb-bztt73DMASc_pl5nU1hK1VmvmhJNBk_PXjo4KkIYbhwbMBQy9wer5rI9eyC-k7ciJrgibgorYW_ofbfpQ1wS5VS0kpkEEf2iTL9Y',
    'Fast Delivery',
    'Get groceries in 60 minutes.',
  ),
];

// Logo URL from design HTML
const _logoUrl =
    '${_aidaPubBase}AB6AXuD_hqjBjp2VTTu7W9TgtEivFRjmvJkPOgmm1C_1THofMvtOww25PmbILUR07D3CNniMda_AKbhf_S0Zt6D0RJrK7HyoEPgXzaIbkTWWGOYxmztAy95Ztdgdb8K5kgEd0PmxSuPYSu2SapOr8E8BghjO0NT5VxYIFEZCoPiXwLN9W0l1Quqj9nc3V7fW0IWoJ-MOSMOP2FRwA1ODgXW-wcqsdnbprXaqZP0Ne1njvaXbdtmmGlqdj7zntVr_e0GqeAHOOtchbPZ9r7c';

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
  int _bannerPage = 0;
  int _selectedNav = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartCount = cart.itemCount;
    final cartTotal = cart.items.fold<double>(0, (s, i) => s + i.price * i.quantity);

    return Scaffold(
      backgroundColor: _surface,
      // ── AppBar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _primary,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.black26,
        toolbarHeight: 60,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            // Hamburger
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
              onPressed: () {},
              padding: const EdgeInsets.only(left: 8),
            ),
            const SizedBox(width: 4),
            // Logo
            Expanded(
              child: Center(
                child: Image.network(
                  _logoUrl,
                  height: 26,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('SRIBEES',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5)),
                      SizedBox(width: 4),
                      Text('Online',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Cart badge + price
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cart icon with count badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_cart_rounded,
                          color: Colors.white, size: 20),
                      if (cartCount > 0)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$cartCount',
                                style: const TextStyle(
                                  color: _primary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Rs${cartTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Body ────────────────────────────────────────────────────────────
      body: Column(
        children: [
          // Sticky search bar
          _SearchBar(controller: _searchController),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Hero banner carousel
                  _HeroBanner(
                    banners: _banners,
                    controller: _pageController,
                    currentPage: _bannerPage,
                    onPageChanged: (p) => setState(() => _bannerPage = p),
                  ),
                  const SizedBox(height: 28),

                  // Shop by Category
                  _SectionTitle('Shop by Category'),
                  const SizedBox(height: 16),
                  _CategoryRow(categories: _categories),
                  const SizedBox(height: 28),

                  // Today's Deals
                  _SectionTitle("Today's Deals"),
                  const SizedBox(height: 16),
                  _DealsGrid(
                    deals: _deals,
                    onAdd: (deal) {
                      ref.read(cartProvider.notifier).addItem(
                            productId: deal.name.hashCode.toString(),
                            price: deal.price,
                            name: deal.name,
                            imageUrl: deal.imageUrl,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${deal.name} added to cart'),
                        backgroundColor: _primary,
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ));
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Glass Bottom Nav ─────────────────────────────────────────────────
      bottomNavigationBar: _GlassBottomNav(
        selected: _selectedNav,
        onTap: (i) {
          setState(() => _selectedNav = i);
          if (i == 1) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SavedScreen()))
                .then((_) => setState(() => _selectedNav = 0));
          } else if (i == 2) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const OrdersScreen()))
                .then((_) => setState(() => _selectedNav = 0));
          }
        },
      ),

      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButton: _PinkFab(onTap: () {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// ---------------------------------------------------------------------------
// Search Bar (sticky below AppBar)
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: _surface.withValues(alpha: 0.85),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Search for.......',
              hintStyle: const TextStyle(color: _onSurfaceVariant, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: _onSurfaceVariant, size: 22),
              filled: true,
              fillColor: _surfaceLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: _primary, width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              isDense: false,
            ),
            style: const TextStyle(fontSize: 14, color: _onSurface),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Title
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: _onSurface,
        letterSpacing: -0.3,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero Banner Carousel
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 180,
        child: Stack(
          children: [
            // Slides
            PageView.builder(
              controller: controller,
              onPageChanged: onPageChanged,
              itemCount: banners.length,
              itemBuilder: (_, i) => _BannerSlide(banner: banners[i]),
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
                    width: active ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerSlide extends StatelessWidget {
  final _Banner banner;
  const _BannerSlide({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.network(
          banner.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
              ),
            ),
          ),
        ),
        // Gradient overlay (left to right, dark to transparent — matches HTML)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFF1B1C1D).withValues(alpha: 0.80),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Text + CTA
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                banner.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
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
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                child: const Text('Shop Now'),
              ),
            ],
          ),
        ),
      ],
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
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
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
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _surfaceLow,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B1C1D).withValues(alpha: 0.06),
                    blurRadius: 20,
                    spreadRadius: -10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.network(
                category.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.category_rounded,
                    color: _onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _onSurface,
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
  final ValueChanged<_Deal> onAdd;
  const _DealsGrid({required this.deals, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: deals.length,
      itemBuilder: (_, i) => _DealCard(deal: deals[i], onAdd: () => onAdd(deals[i])),
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
        color: _surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B1C1D).withValues(alpha: 0.06),
            blurRadius: 20,
            spreadRadius: -10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + badge
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  deal.imageUrl,
                  height: 128,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 128,
                    color: _surfaceLow,
                    child: const Icon(Icons.image_outlined,
                        color: _onSurfaceVariant, size: 36),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '10% Cash Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    deal.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rs. ${deal.price % 1 == 0 ? deal.price.toInt() : deal.price.toStringAsFixed(2)}.00',
                        style: const TextStyle(
                          color: _primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GestureDetector(
                        onTap: onAdd,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: _primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 16),
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
// Glass Bottom Nav
// ---------------------------------------------------------------------------

class _GlassBottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  const _GlassBottomNav({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: _surface.withValues(alpha: 0.85),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B1C1D).withValues(alpha: 0.04),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 62,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'HOME',
                    index: 0,
                    selected: selected,
                    onTap: onTap,
                  ),
                  _NavItem(
                    icon: Icons.favorite_border_rounded,
                    label: 'SAVED',
                    index: 1,
                    selected: selected,
                    onTap: onTap,
                  ),
                  const SizedBox(width: 56), // FAB space
                  _NavItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'ORDERS',
                    index: 2,
                    selected: selected,
                    onTap: onTap,
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    label: 'PROFILE',
                    index: 3,
                    selected: selected,
                    onTap: onTap,
                  ),
                ],
              ),
            ),
          ),
        ),
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
    final color = active ? _primary : _onSurface.withValues(alpha: 0.45);

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pink FAB (elevated, white border)
// ---------------------------------------------------------------------------

class _PinkFab extends StatelessWidget {
  final VoidCallback onTap;
  const _PinkFab({required this.onTap});

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
            colors: [_primary, _primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: _surface, width: 4),
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.auto_awesome_rounded,
            color: Colors.white, size: 26),
      ),
    );
  }
}
