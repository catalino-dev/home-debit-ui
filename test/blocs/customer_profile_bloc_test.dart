import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:home_debit_ui/blocs/customer_profile/customer_profile_bloc.dart';
import 'package:home_debit_ui/models/customer.dart';
import 'package:home_debit_ui/services/customer_profile_service.dart';
import 'package:home_debit_ui/services/customer_service.dart';

/// Answers each load with the next scripted result (a Customer or an error).
class _ScriptedProfileService implements CustomerProfileService {
  _ScriptedProfileService(this._results);

  final List<Object> _results;
  final requestedIds = <int>[];

  @override
  Future<Customer> loadProfile(int customerId) async {
    requestedIds.add(customerId);
    final result = _results.removeAt(0);
    if (result is Customer) return result;
    throw result;
  }
}

/// US-10: CustomerProfileBloc events -> states.
void main() {
  const juan = Customer(
    id: 7,
    fullName: 'Juan Dela Cruz',
    email: 'juan@example.com',
    mobileNumber: '09201234567',
  );
  const failure = CustomerServiceException('Profile service unavailable.');

  test('initial state is loading', () {
    final bloc = CustomerProfileBloc(
      profileService: _ScriptedProfileService([]),
      customerId: 7,
    );
    expect(bloc.state, const CustomerProfileLoading());
    bloc.close();
  });

  late _ScriptedProfileService service;

  blocTest<CustomerProfileBloc, CustomerProfileState>(
    'Requested loads the customer by id',
    setUp: () => service = _ScriptedProfileService([juan]),
    build: () => CustomerProfileBloc(profileService: service, customerId: 7),
    act: (bloc) => bloc.add(const CustomerProfileRequested()),
    expect: () => [const CustomerProfileLoaded(juan)],
    verify: (_) => expect(service.requestedIds, [7]),
  );

  blocTest<CustomerProfileBloc, CustomerProfileState>(
    'a service exception becomes a failure with its message',
    build: () => CustomerProfileBloc(
      profileService: _ScriptedProfileService([failure]),
      customerId: 7,
    ),
    act: (bloc) => bloc.add(const CustomerProfileRequested()),
    expect: () => [
      const CustomerProfileLoadFailure('Profile service unavailable.'),
    ],
  );

  blocTest<CustomerProfileBloc, CustomerProfileState>(
    'an unexpected error becomes a generic failure',
    build: () => CustomerProfileBloc(
      profileService: _ScriptedProfileService([StateError('boom')]),
      customerId: 7,
    ),
    act: (bloc) => bloc.add(const CustomerProfileRequested()),
    expect: () => [
      const CustomerProfileLoadFailure(
        CustomerProfileBloc.unexpectedErrorMessage,
      ),
    ],
  );

  blocTest<CustomerProfileBloc, CustomerProfileState>(
    'Retry after a failure goes loading -> loaded',
    setUp: () => service = _ScriptedProfileService([juan]),
    build: () => CustomerProfileBloc(profileService: service, customerId: 7),
    seed: () =>
        const CustomerProfileLoadFailure('Profile service unavailable.'),
    act: (bloc) => bloc.add(const CustomerProfileRetryRequested()),
    expect: () => [
      const CustomerProfileLoading(),
      const CustomerProfileLoaded(juan),
    ],
  );

  blocTest<CustomerProfileBloc, CustomerProfileState>(
    'Retry is ignored unless the last load failed',
    setUp: () => service = _ScriptedProfileService([juan]),
    build: () => CustomerProfileBloc(profileService: service, customerId: 7),
    seed: () => const CustomerProfileLoaded(juan),
    act: (bloc) => bloc.add(const CustomerProfileRetryRequested()),
    expect: () => <CustomerProfileState>[],
    verify: (_) => expect(service.requestedIds, isEmpty),
  );

  blocTest<CustomerProfileBloc, CustomerProfileState>(
    'Updated replaces the displayed customer without reloading',
    setUp: () => service = _ScriptedProfileService([]),
    build: () => CustomerProfileBloc(profileService: service, customerId: 7),
    seed: () => const CustomerProfileLoaded(juan),
    act: (bloc) => bloc.add(
      const CustomerProfileUpdated(
        Customer(
          id: 7,
          fullName: 'Juan Dela Cruz',
          email: 'juan@example.com',
          mobileNumber: '09201234567',
          nickname: 'Juanito',
        ),
      ),
    ),
    expect: () => [
      isA<CustomerProfileLoaded>().having(
        (state) => state.customer.nickname,
        'nickname',
        'Juanito',
      ),
    ],
    verify: (_) => expect(service.requestedIds, isEmpty),
  );
}
