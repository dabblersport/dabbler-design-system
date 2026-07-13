import '../doc_model.dart';

// Patterns are composed from the components; these are stubs until the
// component set they build on is complete.

const gameCardPage = DocPage(
  id: 'game-card',
  group: DocGroup.patterns,
  title: 'Game Card',
  definition:
      'The summary card for a single game — teams, time, venue, and a join CTA.',
  placeholder: true,
  keywords: ['pattern', 'game', 'match', 'card'],
);

const organiserCardPage = DocPage(
  id: 'organiser-card',
  group: DocGroup.patterns,
  title: 'Organiser Card',
  definition: 'The card that presents an organiser and their upcoming games.',
  placeholder: true,
  keywords: ['pattern', 'organiser', 'host', 'card'],
);

const venueCardPage = DocPage(
  id: 'venue-card',
  group: DocGroup.patterns,
  title: 'Venue Card',
  definition: 'The card that presents a venue — location, facilities, slots.',
  placeholder: true,
  keywords: ['pattern', 'venue', 'pitch', 'card'],
);
