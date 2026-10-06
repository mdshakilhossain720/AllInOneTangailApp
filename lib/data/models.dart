import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../core/utils/context_ext.dart';

/// Placeholder image from picsum with a fixed seed (stable across runs).
String pic(String seed, [int w = 600, int h = 400]) => 'https://picsum.photos/seed/$seed/$w/$h';

class Upazila {
  const Upazila(this.id, this.name, this.pos);
  final String id;
  final Tr name;
  final LatLng pos;
}

/// Anything that can be shown as a marker on the demo map.
abstract interface class Mappable {
  String get id;
  String get mapTitle;
  LatLng get pos;
}

// ---------------------------------------------------------------- Health

class Hospital implements Mappable {
  const Hospital({
    required this.id,
    required this.name,
    required this.isGovt,
    required this.upazila,
    required this.address,
    required this.phone,
    required this.beds,
    required this.emergency24,
    required this.rating,
    required this.image,
    required this.departments,
    required this.facilities,
    required this.pos,
  });
  @override
  final String id;
  final String name;
  final bool isGovt;
  final String upazila;
  final String address;
  final String phone;
  final int beds;
  final bool emergency24;
  final double rating;
  final String image;
  final List<String> departments;
  final List<String> facilities;
  @override
  final LatLng pos;
  @override
  String get mapTitle => name;
}

class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.degrees,
    required this.hospitalId,
    required this.chamber,
    required this.upazila,
    required this.fee,
    required this.experience,
    required this.rating,
    required this.image,
    required this.schedule,
    required this.phone,
    required this.about,
  });
  final String id;
  final String name;
  final String specialty;
  final String degrees;
  final String hospitalId;
  final String chamber;
  final String upazila;
  final int fee;
  final int experience;
  final double rating;
  final String image;

  /// Day (Sat..Fri) → time range, or null when off.
  final Map<String, String?> schedule;
  final String phone;
  final String about;
}

class Ambulance {
  const Ambulance({
    required this.id,
    required this.provider,
    required this.types,
    required this.is24h,
    required this.phone,
    required this.upazila,
    required this.rate,
  });
  final String id;
  final String provider;
  final List<String> types; // AC / Non-AC / ICU
  final bool is24h;
  final String phone;
  final String upazila;
  final String rate;
}

class BloodDonor {
  const BloodDonor({
    required this.id,
    required this.name,
    required this.group,
    required this.upazila,
    required this.lastDonated,
    required this.available,
    required this.phone,
    required this.donations,
  });
  final String id;
  final String name;
  final String group;
  final String upazila;
  final DateTime lastDonated;
  final bool available;
  final String phone;
  final int donations;
}

enum ServiceKind { police, fire }

class EmergencyService implements Mappable {
  const EmergencyService({
    required this.id,
    required this.name,
    required this.kind,
    required this.upazila,
    required this.phone,
    required this.address,
    required this.pos,
  });
  @override
  final String id;
  final String name;
  final ServiceKind kind;
  final String upazila;
  final String phone;
  final String address;
  @override
  final LatLng pos;
  @override
  String get mapTitle => name;
}

class GovtOffice {
  const GovtOffice({
    required this.id,
    required this.name,
    required this.upazila,
    required this.phone,
    required this.hours,
    required this.address,
    required this.icon,
  });
  final String id;
  final String name;
  final String upazila;
  final String phone;
  final String hours;
  final String address;
  final IconData icon;
}

// ---------------------------------------------------------------- Legal

class Lawyer {
  const Lawyer({
    required this.id,
    required this.name,
    required this.areas,
    required this.court,
    required this.experience,
    required this.image,
    required this.phone,
    required this.fee,
    required this.education,
    required this.chamberHours,
    required this.chamber,
    required this.bio,
    required this.rating,
    required this.cases,
  });
  final String id;
  final String name;
  final List<String> areas;
  final String court;
  final int experience;
  final String image;
  final String phone;
  final int fee;
  final List<String> education;
  final String chamberHours;
  final String chamber;
  final String bio;
  final double rating;
  final int cases;
}

// ---------------------------------------------------------------- Transport

class BusTrip {
  const BusTrip({
    required this.id,
    required this.operator,
    required this.from,
    required this.to,
    required this.depart,
    required this.arrive,
    required this.counter,
    required this.fare,
    required this.ac,
    required this.seats,
  });
  final String id;
  final String operator;
  final String from;
  final String to;
  final String depart;
  final String arrive;
  final String counter;
  final int fare;
  final bool ac;
  final int seats;
}

class TrainSchedule {
  const TrainSchedule(this.name, this.number, this.from, this.to, this.depart, this.arrive, this.offDay, this.fare);
  final String name;
  final String number;
  final String from;
  final String to;
  final String depart;
  final String arrive;
  final String offDay;
  final int fare;
}

class RentCar {
  const RentCar({
    required this.id,
    required this.name,
    required this.type,
    required this.phone,
    required this.rate,
    required this.upazila,
    required this.rating,
    required this.seats,
  });
  final String id;
  final String name;
  final String type;
  final String phone;
  final String rate;
  final String upazila;
  final double rating;
  final int seats;
}

// ---------------------------------------------------------------- Directory

class Review {
  const Review(this.name, this.rating, this.text, this.daysAgo, [this.images = const []]);
  final String name;
  final double rating;
  final String text;
  final int daysAgo;
  final List<String> images;
}

class Business implements Mappable {
  const Business({
    required this.id,
    required this.name,
    required this.category,
    required this.upazila,
    required this.address,
    required this.phone,
    required this.rating,
    required this.reviewCount,
    required this.hours,
    required this.isOpen,
    required this.images,
    required this.about,
    required this.pos,
    this.verified = false,
  });
  @override
  final String id;
  final String name;
  final String category;
  final String upazila;
  final String address;
  final String phone;
  final double rating;
  final int reviewCount;
  final String hours;
  final bool isOpen;
  final List<String> images;
  final String about;
  @override
  final LatLng pos;
  final bool verified;
  @override
  String get mapTitle => name;
}

enum InstitutionType { school, college, university, coaching }

class Institution {
  const Institution({
    required this.id,
    required this.name,
    required this.type,
    required this.upazila,
    required this.established,
    required this.students,
    required this.image,
    required this.phone,
    required this.rating,
  });
  final String id;
  final String name;
  final InstitutionType type;
  final String upazila;
  final int established;
  final int students;
  final String image;
  final String phone;
  final double rating;
}

class Place implements Mappable {
  const Place({
    required this.id,
    required this.name,
    required this.upazila,
    required this.tag,
    required this.image,
    required this.gallery,
    required this.about,
    required this.howToGo,
    required this.entryFee,
    required this.hours,
    required this.pos,
    required this.tall,
    required this.rating,
  });
  @override
  final String id;
  final String name;
  final String upazila;
  final String tag;
  final String image;
  final List<String> gallery;
  final String about;
  final List<String> howToGo;
  final String entryFee;
  final String hours;
  @override
  final LatLng pos;
  final bool tall;
  final double rating;
  @override
  String get mapTitle => name;
}

class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.body,
    required this.image,
    required this.hoursAgo,
    required this.source,
  });
  final String id;
  final String title;
  final String category;
  final String summary;
  final String body;
  final String image;
  final int hoursAgo;
  final String source;
}

class Job {
  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.upazila,
    required this.salary,
    required this.fullTime,
    required this.deadline,
    required this.description,
    required this.requirements,
    required this.category,
  });
  final String id;
  final String title;
  final String company;
  final String upazila;
  final String salary;
  final bool fullTime;
  final DateTime deadline;
  final String description;
  final List<String> requirements;
  final String category;
}

class BazarItem {
  const BazarItem(this.id, this.name, this.unit, this.price, this.history, this.emoji);
  final String id;
  final Tr name;
  final Tr unit;
  final int price;
  final List<double> history; // last 7 days, oldest first
  final String emoji;

  double get changePct {
    final prev = history[history.length - 2];
    return (history.last - prev) / prev * 100;
  }
}

class Prayer {
  const Prayer(this.key, this.time);
  final String key; // fajr, dhuhr...
  final DateTime time;
}

class Notice {
  const Notice(this.title, this.body, this.issuer, this.daysAgo, {this.important = false});
  final String title;
  final String body;
  final String issuer;
  final int daysAgo;
  final bool important;
}

class LostFound {
  const LostFound({
    required this.id,
    required this.isLost,
    required this.title,
    required this.description,
    required this.location,
    required this.daysAgo,
    required this.image,
    required this.phone,
  });
  final String id;
  final bool isLost;
  final String title;
  final String description;
  final String location;
  final int daysAgo;
  final String image;
  final String phone;
}

class LocalEvent {
  const LocalEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.place,
    required this.image,
    required this.description,
    required this.category,
  });
  final String id;
  final String title;
  final DateTime date;
  final String place;
  final String image;
  final String description;
  final String category;
}

// ---------------------------------------------------------------- Shop

class ShopCategory {
  const ShopCategory(this.id, this.labelKey, this.icon);
  final String id;
  final String labelKey; // l10n key resolved in UI
  final IconData icon;
}

class Store {
  const Store({
    required this.id,
    required this.name,
    required this.logo,
    required this.cover,
    required this.rating,
    required this.followers,
    required this.upazila,
    required this.joined,
    required this.responseRate,
    required this.verified,
    required this.about,
    required this.phone,
  });
  final String id;
  final String name;
  final String logo;
  final String cover;
  final double rating;
  final int followers;
  final String upazila;
  final DateTime joined;
  final int responseRate;
  final bool verified;
  final String about;
  final String phone;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.sold,
    required this.storeId,
    required this.upazila,
    required this.verified,
    required this.images,
    required this.sizes,
    required this.colors,
    required this.stock,
    required this.description,
    required this.specs,
    required this.madeInTangail,
    required this.pickup,
    required this.daysAgo,
  });
  final String id;
  final String name;
  final String categoryId;
  final int price;
  final int? oldPrice;
  final double rating;
  final int sold;
  final String storeId;
  final String upazila;
  final bool verified;
  final List<String> images;
  final List<String> sizes;
  final List<Color> colors;
  final int stock;
  final String description;
  final Map<String, String> specs;
  final bool madeInTangail;
  final bool pickup;
  final int daysAgo; // listing age, for "newest" sort

  int? get discountPct => oldPrice == null ? null : (((oldPrice! - price) / oldPrice!) * 100).round();

  Product copyWith({
    String? name,
    int? price,
    int? oldPrice,
    int? stock,
    String? description,
    String? categoryId,
    List<String>? images,
    bool clearOldPrice = false,
  }) => Product(
    id: id,
    name: name ?? this.name,
    categoryId: categoryId ?? this.categoryId,
    price: price ?? this.price,
    oldPrice: clearOldPrice ? null : (oldPrice ?? this.oldPrice),
    rating: rating,
    sold: sold,
    storeId: storeId,
    upazila: upazila,
    verified: verified,
    images: images ?? this.images,
    sizes: sizes,
    colors: colors,
    stock: stock ?? this.stock,
    description: description ?? this.description,
    specs: specs,
    madeInTangail: madeInTangail,
    pickup: pickup,
    daysAgo: daysAgo,
  );
}

class CartItem {
  const CartItem({required this.productId, required this.qty, this.size, this.color, this.selected = true});
  final String productId;
  final int qty;
  final String? size;
  final Color? color;
  final bool selected;

  String get key => '$productId|$size|${color?.toARGB32()}';

  CartItem copyWith({int? qty, bool? selected}) => CartItem(
    productId: productId,
    qty: qty ?? this.qty,
    size: size,
    color: color,
    selected: selected ?? this.selected,
  );
}

enum OrderStatus { toPay, toShip, toReceive, completed, returned, cancelled }

class OrderLine {
  const OrderLine(this.productId, this.qty, this.price);
  final String productId;
  final int qty;
  final int price;
}

class Order {
  const Order({
    required this.id,
    required this.lines,
    required this.status,
    required this.placedAt,
    required this.payment,
    required this.deliveryFee,
    required this.address,
    this.buyer = 'Rahim Uddin',
  });
  final String id;
  final List<OrderLine> lines;
  final OrderStatus status;
  final DateTime placedAt;
  final String payment;
  final int deliveryFee;
  final String address;
  final String buyer;

  int get subtotal => lines.fold(0, (s, l) => s + l.price * l.qty);
  int get total => subtotal + deliveryFee;

  Order withStatus(OrderStatus s) => Order(
    id: id,
    lines: lines,
    status: s,
    placedAt: placedAt,
    payment: payment,
    deliveryFee: deliveryFee,
    address: address,
    buyer: buyer,
  );
}

class Voucher {
  const Voucher(this.id, this.title, this.amount, this.minSpend, this.validTill, this.storeName);
  final String id;
  final String title;
  final int amount;
  final int minSpend;
  final DateTime validTill;
  final String? storeName;
}

enum NotifType { order, offer, emergency, community }

class AppNotification {
  const AppNotification(this.id, this.type, this.title, this.body, this.minutesAgo);
  final String id;
  final NotifType type;
  final String title;
  final String body;
  final int minutesAgo;
}

class Address {
  const Address({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.line,
    required this.upazila,
  });
  final String id;
  final String label;
  final String name;
  final String phone;
  final String line;
  final String upazila;
}

class HomeBanner {
  const HomeBanner(this.title, this.subtitle, this.image, this.route, this.cta);
  final Tr title;
  final Tr subtitle;
  final String image;
  final String route;
  final Tr cta;
}
