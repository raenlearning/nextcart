# NextCart

**NextCart** is a modern Flutter e-commerce application built with Supabase as the backend. It features a clean architecture, reusable widgets, and an Apple Store-inspired design system.

## 📱 Project Overview

NextCart is a full-featured mobile e-commerce app that allows users to browse products, manage carts and wishlists, track orders, and authenticate via email/password or OAuth. The app implements a complete redesign with custom SVG illustrations, subtle micro-interactions, and a consistent design language across all screens.

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter 3.x |
| **State Management** | Bloc (Business Logic Components) |
| **Backend** | Supabase (PostgREST + Realtime + Storage) |
| **Authentication** | Supabase Auth (Email + OAuth) |
| **Database** | PostgreSQL via PostgREST |
| **Images** | SVG illustrations, network images with caching |
| **Animations** | Lottie (delight moments), custom SVG, implicit animations |
| **Testing** | Flutter analyze, manual curl verification against Supabase |

## 📂 Project Structure

```
lib/
├── core/                  # Shared constants, widgets, helpers
│   ├── assets/            # SVG illustrations, images
│   ├── constants/         # AppColors, AppSpacing, OrderStatus, pricing
│   ├── helper/            # Date formatter, order status UI, cart alert
│   ├── theme/             - app_theme.dart
│   └── widgets/           - PressableScale, ShimmerBox, empty states
├── features/              # Feature modules
│   ├── auth/              # Login/Register pages
│   ├── home/              # Product grid, search, categories
│   ├── product/           # Product detail, view-all
│   ├── cart/              # Cart management
│   ├── wishlist/          # Wishlist feature
│   ├── order/             # Order history & tracking
│   ├── profile/           # User profile & settings
│   ├── admin/             # Admin dashboard
│   └── review/            # Product reviews
└── main.dart              # App entry point
```

## ✨ Key Features

- **Splash Screen**: Static SVG illustration + `DM Serif Display` font, fade-in animation
- **Product Browsing**: Grid view with cards, category chips, promo banners, sorting/filtering
- **Search**: Global search across products with debounced queries
- **Cart & Wishlist**: Add/remove items, persistent storage, price sorting
- **Order Tracking**: 3 status tabs (Aktif/Selesai/Dibatalkan), infinite scroll pagination (5 items/page)
- **Authentication**: Email/password + Google/GitHub OAuth, session persistence
- **Profile**: Summary cards with wishlist count (fetched directly from DB), change password
- **Admin Dashboard**: Analytics charts, product management, user management
- **Custom SVG Empty States**: `empty_cart.svg`, `empty_wishlist.svg`, `empty_orders.svg`, `empty_search.svg`
- **Micro-interactions**: `PressableScale` widget for subtle button feedback
- **Infinite Scroll**: Load more on list scroll threshold

## 🎨 Design Decisions

- **Apple Store Reference**: Home and Auth pages designed with Apple's minimalist aesthetic
- **Color Palette**:
  - Deep Navy: `#0F172A` (backgrounds)
  - Cream: `#F5F0E1` (surfaces)
  - Cyan Accent: `#22D3EE` (underlines, highlights)
  - Primary: `#0A84FF` (action buttons)
- **Typography**: `DM Serif Display` for headers, system fonts for body
- **Radius Standards**: 16-20px for cards, 28px for buttons
- **No Lottie Overhead**: Custom SVG illustrations replace Lottie animations where possible

## 🔧 Recent Improvements

| Feature | Description |
|---------|-------------|
| **Order Search & Pagination** | Global debounced search + 3 server-side queries per tab, 5 items per page, infinite scroll |
| **Wishlist Price Sort** | Fixed PostgREST `order=products(price)` syntax (was `products.price`, now `products(price)`) |
| **Profile Wishlist Count** | Query `wishlist_items` table directly instead of reading Bloc state |
| **Empty State SVGs** | 4 custom SVG illustrations replacing Lottie animations |
| **Onboarding Fix** | `BoxFit.cover` for edge-to-edge images |

## 📦 Setup & Run

```bash
# 1. Clone the repository
git clone https://github.com/raenlearning/nextcart.git
cd nextcart

# 2. Install dependencies
flutter pub get

# 3. Configure Supabase
# - Add google-services.json (Android) / GoogleService-Info.plist (iOS)
# - Set SUPABASE_URL and SUPABASE_ANON_KEY in appropriate config

# 4. Run the app
flutter run
```

## 🛠 Development

```bash
# Code analysis (3 pre-existing infos, all other code clean)
flutter analyze

# Format code
flutter format .

# Run tests (if any)
flutter test
```

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## 🙏 Acknowledgments

- Design reference: Apple Store UI patterns
- Backend: Supabase (free tier)
- Font: `DM Serif Display` (Google Fonts)
- SVG illustrations: Hand-crafted for this project