part of 'initial_personalization_bloc.dart';

enum InitialPersonalizationStatus { initial, loading, success, failure, saving }

class InitialPersonalizationState extends Equatable {
  const InitialPersonalizationState({
    this.status = InitialPersonalizationStatus.initial,
    this.selectedTopics = const {},
    this.selectedSources = const {},
    this.selectedCountries = const {},
    this.selectedPersons = const {},
    this.maxSelectionsPerCategory,
    this.error,
  });

  final InitialPersonalizationStatus status;
  final Set<Topic> selectedTopics;
  final Set<Source> selectedSources;
  final Set<Country> selectedCountries;
  final Set<Person> selectedPersons;
  final int? maxSelectionsPerCategory;
  final HttpException? error;

  int get totalSelectedCount =>
      selectedTopics.length +
      selectedSources.length +
      selectedCountries.length +
      selectedPersons.length;

  InitialPersonalizationState copyWith({
    InitialPersonalizationStatus? status,
    Set<Topic>? selectedTopics,
    Set<Source>? selectedSources,
    Set<Country>? selectedCountries,
    Set<Person>? selectedPersons,
    int? maxSelectionsPerCategory,
    HttpException? error,
  }) {
    return InitialPersonalizationState(
      status: status ?? this.status,
      selectedTopics: selectedTopics ?? this.selectedTopics,
      selectedSources: selectedSources ?? this.selectedSources,
      selectedCountries: selectedCountries ?? this.selectedCountries,
      selectedPersons: selectedPersons ?? this.selectedPersons,
      maxSelectionsPerCategory:
          maxSelectionsPerCategory ?? this.maxSelectionsPerCategory,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedTopics,
    selectedSources,
    selectedCountries,
    selectedPersons,
    maxSelectionsPerCategory,
    error,
  ];
}
