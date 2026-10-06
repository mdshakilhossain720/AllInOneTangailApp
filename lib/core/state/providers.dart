import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/demo/shop_data.dart';
import '../../data/models.dart';

/// Simple settable value — avoids one class per primitive setting.
class Setter<T> extends Notifier<T> {
  Setter(this._initial);
  final T _initial;
  @override
  T build() => _initial;
  void set(T value) => state = value;
}

NotifierProvider<Setter<T>, T> settable<T>(T initial) => NotifierProvider<Setter<T>, T>(() => Setter<T>(initial));

// ---------------------------------------------------------------- Settings

final themeModeProvider = settable<ThemeMode>(ThemeMode.system);
final localeProvider = settable<Locale>(const Locale('en'));
final offlineProvider = settable<bool>(false);
final upazilaProvider = settable<String>('sadar');
final userNameProvider = settable<String>('Rahim Uddin');
final notifPrefsProvider = settable<Map<String, bool>>(const {
  'push': true,
  'orders': true,
  'offers': true,
  'emergency': true,
  'blood': false,
});
final donorVisibleProvider = settable<bool>(true);
final isSellerProvider = settable<bool>(false);

// ---------------------------------------------------------------- Toggle sets

/// A set of ids that can be toggled (wishlist, follows, interested events…).
class IdSet extends Notifier<Set<String>> {
  IdSet(this._initial);
  final Set<String> _initial;
  @override
  Set<String> build() => _initial;

  /// Returns true when the id is now in the set.
  bool toggle(String id) {
    final added = !state.contains(id);
    state = added ? {...state, id} : ({...state}..remove(id));
    return added;
  }
}

NotifierProvider<IdSet, Set<String>> idSet([Set<String> initial = const {}]) =>
    NotifierProvider<IdSet, Set<String>>(() => IdSet(initial));

final wishlistProvider = idSet({'p3', 'p9'});
final followedStoresProvider = idSet({'s2'});
final interestedEventsProvider = idSet();
final collectedVouchersProvider = idSet({'v1'});

enum SavedKind { products, doctors, lawyers, businesses, places }

class SavedNotifier extends Notifier<Map<SavedKind, Set<String>>> {
  @override
  Map<SavedKind, Set<String>> build() => {
    SavedKind.doctors: {'d2'},
    SavedKind.lawyers: <String>{},
    SavedKind.businesses: {'bz9'},
    SavedKind.places: {'mohera'},
  };

  bool toggle(SavedKind kind, String id) {
    final current = {...?state[kind]};
    final added = !current.contains(id);
    added ? current.add(id) : current.remove(id);
    state = {...state, kind: current};
    return added;
  }
}

final savedProvider = NotifierProvider<SavedNotifier, Map<SavedKind, Set<String>>>(SavedNotifier.new);

// ---------------------------------------------------------------- Lists

class ListNotifier<T> extends Notifier<List<T>> {
  ListNotifier(this._initial);
  final List<T> _initial;
  @override
  List<T> build() => _initial;
  void set(List<T> v) => state = v;
}

class RecentNotifier extends ListNotifier<String> {
  RecentNotifier(super.initial);

  /// Moves [value] to the front, keeping at most [max] entries.
  void push(String value, {int max = 8}) {
    final v = value.trim();
    if (v.isEmpty) return;
    state = [v, ...state.where((e) => e != v)].take(max).toList();
  }

  void remove(String value) => state = state.where((e) => e != value).toList();
  void clear() => state = const [];
}

final recentSearchesProvider = NotifierProvider<RecentNotifier, List<String>>(
  () => RecentNotifier(const ['Chomchom', 'Dr. Ayesha', 'Bus to Dhaka', 'টাঙ্গাইল শাড়ি']),
);
final recentlyViewedProvider = NotifierProvider<RecentNotifier, List<String>>(
  () => RecentNotifier(const ['p8', 'p13', 'p6']),
);

final addressesProvider = NotifierProvider<ListNotifier<Address>, List<Address>>(() => ListNotifier(addressesSeed));
final defaultAddressProvider = settable<String>('ad1');

final readNotificationsProvider = idSet({'nt5', 'nt6', 'nt7'});

final coinsProvider = settable<int>(1250);
final checkedInTodayProvider = settable<bool>(false);

// ---------------------------------------------------------------- Cart

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [
    CartItem(productId: 'p3', qty: 1, size: '1 kg'),
    CartItem(productId: 'p7', qty: 2),
    CartItem(productId: 'p10', qty: 1),
  ];

  void add(String productId, {int qty = 1, String? size, Color? color}) {
    final item = CartItem(productId: productId, qty: qty, size: size, color: color);
    final i = state.indexWhere((e) => e.key == item.key);
    if (i == -1) {
      state = [...state, item];
    } else {
      setQty(state[i].key, state[i].qty + qty);
    }
  }

  void setQty(String key, int qty) => state = [
    for (final e in state)
      if (e.key == key) e.copyWith(qty: qty.clamp(1, 99)) else e,
  ];

  void toggle(String key) => state = [
    for (final e in state)
      if (e.key == key) e.copyWith(selected: !e.selected) else e,
  ];

  void selectAll(bool v) => state = [for (final e in state) e.copyWith(selected: v)];

  /// Selects/deselects every item from one store.
  void selectStore(String storeId, bool v) => state = [
    for (final e in state)
      if (productById(e.productId).storeId == storeId) e.copyWith(selected: v) else e,
  ];

  CartItem? remove(String key) {
    final removed = state.where((e) => e.key == key).firstOrNull;
    state = state.where((e) => e.key != key).toList();
    return removed;
  }

  void restore(CartItem item, int index) {
    final next = [...state];
    next.insert(index.clamp(0, next.length), item);
    state = next;
  }

  void removeSelected() => state = state.where((e) => !e.selected).toList();
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

final cartCountProvider = Provider<int>((ref) => ref.watch(cartProvider).fold(0, (s, e) => s + e.qty));

/// Subtotal and old-price savings for selected items.
final cartTotalsProvider = Provider<({int subtotal, int savings, int count})>((ref) {
  var subtotal = 0, savings = 0, count = 0;
  for (final e in ref.watch(cartProvider).where((e) => e.selected)) {
    final p = productById(e.productId);
    subtotal += p.price * e.qty;
    savings += ((p.oldPrice ?? p.price) - p.price) * e.qty;
    count += e.qty;
  }
  return (subtotal: subtotal, savings: savings, count: count);
});

final appliedVoucherProvider = settable<int>(0);

// ---------------------------------------------------------------- Orders

class OrdersNotifier extends ListNotifier<Order> {
  OrdersNotifier(super.initial);

  void add(Order o) => state = [o, ...state];

  void setStatus(String id, OrderStatus s) => state = [
    for (final o in state)
      if (o.id == id) o.withStatus(s) else o,
  ];
}

final ordersProvider = NotifierProvider<OrdersNotifier, List<Order>>(() => OrdersNotifier(demoOrders));
final sellerOrdersProvider = NotifierProvider<OrdersNotifier, List<Order>>(() => OrdersNotifier(sellerOrders));

// ---------------------------------------------------------------- Seller products

class SellerProductsNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() => products.where((p) => p.storeId == 's1').toList();

  void upsert(Product p) {
    final i = state.indexWhere((e) => e.id == p.id);
    state = i == -1 ? [p, ...state] : [for (final e in state) e.id == p.id ? p : e];
  }

  void remove(String id) => state = state.where((e) => e.id != id).toList();
}

final sellerProductsProvider = NotifierProvider<SellerProductsNotifier, List<Product>>(SellerProductsNotifier.new);
final unpublishedProductsProvider = idSet({'p24'});

/// Products created by the seller (not in the static catalogue) resolve here.
Product resolveProduct(WidgetRef ref, String id) =>
    ref.read(sellerProductsProvider).where((p) => p.id == id).firstOrNull ?? productById(id);
