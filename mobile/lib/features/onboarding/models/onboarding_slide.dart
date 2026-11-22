/// Model representing a single slide in the Smart Grievance onboarding carousel.
/// All wording and assets are centralised here so they can easily be edited or translated.
class OnboardingSlide {
  const OnboardingSlide({
    required this.heading,
    required this.description,
    required this.imageAsset,
    required this.semanticsLabel,
  });

  /// The main heading text (e.g. "Your Voice\nMatters")
  final String heading;

  /// Explanatory civic body text
  final String description;

  /// Project image asset path
  final String imageAsset;

  /// Screen reader semantic description of the illustration
  final String semanticsLabel;
}

/// The three approved onboarding slides for Smart Grievance.
abstract final class OnboardingContent {
  static const List<OnboardingSlide> slides = [
    // Slide 1 — Your Voice Matters
    OnboardingSlide(
      heading: 'Your Voice\nMatters',
      description:
          'Report civic issues in your community and get them resolved.',
      imageAsset: 'assets/images/onboarding_your_voice.png',
      semanticsLabel:
          'Citizen holding a smartphone with a green verification bubble',
    ),

    // Slide 2 — Easy Complaint Reporting
    OnboardingSlide(
      heading: 'Easy Complaint\nReporting',
      description:
          'Submit civic issues easily with details and supporting information.',
      imageAsset: 'assets/images/onboarding_easy_reporting.png',
      semanticsLabel: 'Woman pointing at a complaint checklist with a calendar',
    ),

    // Slide 3 — Track Your Resolution
    OnboardingSlide(
      heading: 'Track Your\nResolution',
      description:
          'Follow your grievance progress and stay informed until resolution.',
      imageAsset: 'assets/images/onboarding_city_resolved.png',
      semanticsLabel: 'Cityscape with a green location pin and white checkmark',
    ),
  ];
}
