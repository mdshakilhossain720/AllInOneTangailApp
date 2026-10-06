import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

enum ModuleSection { health, services, travel, daily, community }

class ExploreModule {
  const ExploreModule(this.id, this.label, this.icon, this.route, this.section);

  final String id;
  final String Function(AppLocalizations) label;
  final IconData icon;
  final String route;
  final ModuleSection section;
}

final exploreModules = <ExploreModule>[
  ExploreModule(
    'hospitals',
    (l) => l.hospitals,
    Icons.local_hospital_rounded,
    '/explore/hospitals',
    ModuleSection.health,
  ),
  ExploreModule('doctors', (l) => l.doctors, Icons.medical_services_rounded, '/explore/doctors', ModuleSection.health),
  ExploreModule('ambulance', (l) => l.ambulance, Icons.emergency_rounded, '/explore/ambulance', ModuleSection.health),
  ExploreModule('blood', (l) => l.bloodDonors, Icons.bloodtype_rounded, '/explore/blood', ModuleSection.health),
  ExploreModule('police', (l) => l.police, Icons.local_police_rounded, '/explore/police', ModuleSection.health),
  ExploreModule(
    'fire',
    (l) => l.fireService,
    Icons.local_fire_department_rounded,
    '/explore/fire',
    ModuleSection.health,
  ),
  ExploreModule('lawyers', (l) => l.lawyers, Icons.gavel_rounded, '/explore/lawyers', ModuleSection.services),
  ExploreModule('govt', (l) => l.govtOffices, Icons.account_balance_rounded, '/explore/govt', ModuleSection.services),
  ExploreModule('business', (l) => l.business, Icons.storefront_rounded, '/explore/business', ModuleSection.services),
  ExploreModule(
    'transport',
    (l) => l.transport,
    Icons.directions_bus_rounded,
    '/explore/transport',
    ModuleSection.travel,
  ),
  ExploreModule('tourism', (l) => l.tourism, Icons.landscape_rounded, '/explore/tourism', ModuleSection.travel),
  ExploreModule('education', (l) => l.education, Icons.school_rounded, '/explore/education', ModuleSection.daily),
  ExploreModule('news', (l) => l.news, Icons.newspaper_rounded, '/explore/news', ModuleSection.daily),
  ExploreModule('jobs', (l) => l.jobs, Icons.work_rounded, '/explore/jobs', ModuleSection.daily),
  ExploreModule('bazar', (l) => l.bazarPrice, Icons.shopping_basket_rounded, '/explore/bazar', ModuleSection.daily),
  ExploreModule('prayer', (l) => l.prayerTimes, Icons.mosque_rounded, '/explore/prayer', ModuleSection.daily),
  ExploreModule('community', (l) => l.community, Icons.groups_rounded, '/explore/community', ModuleSection.community),
  ExploreModule('events', (l) => l.events, Icons.event_rounded, '/explore/community?tab=2', ModuleSection.community),
];

String sectionLabel(AppLocalizations l, ModuleSection s) => switch (s) {
  ModuleSection.health => l.secHealth,
  ModuleSection.services => l.secServices,
  ModuleSection.travel => l.secTravel,
  ModuleSection.daily => l.secDaily,
  ModuleSection.community => l.secCommunity,
};
