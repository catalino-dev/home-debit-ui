import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/customer.dart';
import '../../services/customer_profile_service.dart';
import '../../services/customer_service.dart';

part 'customer_profile_event.dart';
part 'customer_profile_state.dart';

/// US-10: owns loading the dashboard's customer, so the screen only maps
/// [CustomerProfileState] to widgets and turns taps into events.
class CustomerProfileBloc
    extends Bloc<CustomerProfileEvent, CustomerProfileState> {
  static const unexpectedErrorMessage =
      'Something went wrong while loading your profile. Please try again.';

  CustomerProfileBloc({
    required this._profileService,
    required this._customerId,
  }) : super(const CustomerProfileLoading()) {
    on<CustomerProfileRequested>(_onLoad);
    on<CustomerProfileRetryRequested>(_onRetry);
    on<CustomerProfileUpdated>(
      (event, emit) => emit(CustomerProfileLoaded(event.customer)),
    );
  }

  final CustomerProfileService _profileService;
  final int _customerId;

  Future<void> _onRetry(
    CustomerProfileRetryRequested event,
    Emitter<CustomerProfileState> emit,
  ) async {
    // Retry only makes sense after a failure; ignore duplicate taps.
    if (state is! CustomerProfileLoadFailure) return;
    await _onLoad(event, emit);
  }

  Future<void> _onLoad(
    CustomerProfileEvent event,
    Emitter<CustomerProfileState> emit,
  ) async {
    // The bloc starts in Loading, so only Retry needs to emit it again.
    if (state is! CustomerProfileLoading) emit(const CustomerProfileLoading());
    try {
      final customer = await _profileService.loadProfile(_customerId);
      emit(CustomerProfileLoaded(customer));
    } on CustomerServiceException catch (exception) {
      emit(CustomerProfileLoadFailure(exception.message));
    } catch (_) {
      emit(const CustomerProfileLoadFailure(unexpectedErrorMessage));
    }
  }
}
