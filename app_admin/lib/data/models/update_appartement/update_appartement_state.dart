
class UpdateAppartementState {
  final bool isLoading;
  final bool isSaving;
  final bool dataLoaded;
  final String? errorMessage;
  final Map<String, dynamic>? initialData; // optionnel

  UpdateAppartementState({
    this.isLoading = false,
    this.isSaving = false,
    this.dataLoaded = false,
    this.errorMessage,
    this.initialData,
  });

  UpdateAppartementState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? dataLoaded,
    String? errorMessage,
    Map<String, dynamic>? initialData,
  }) {
    return UpdateAppartementState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      dataLoaded: dataLoaded ?? this.dataLoaded,
      errorMessage: errorMessage,
      initialData: initialData ?? this.initialData,
    );
  }
}