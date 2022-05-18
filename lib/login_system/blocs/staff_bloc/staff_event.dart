part of 'staff_bloc.dart';

abstract class StaffEvent extends Equatable {
  const StaffEvent();
}

// loading event that yields state for ui change
class LoadingStaffEvent extends StaffEvent {
  @override
  List<Object> get props => [];
}

// event that add a particular staff
class AddStaffEvent extends StaffEvent {
  final String email, password, displayName;

  const AddStaffEvent({
    this.email,
    this.password,
    this.displayName,
  })  : assert(email != null),
        assert(password != null),
        assert(displayName != null);

  @override
  List<Object> get props => [
        this.email,
        this.password,
        this.displayName,
      ];
}

// event get all staff
class GetStaffEvent extends StaffEvent {
  @override
  List<Object> get props => [];
}

// event modifies particular staff data (deprecated)
class ModifyStaffEvent extends StaffEvent {
  @override
  List<Object> get props => [];
}

// event delete particular staff
class DeleteStaffEvent extends StaffEvent {
  final String deleteUid;

  DeleteStaffEvent({@required this.deleteUid}) : assert(deleteUid != null);

  @override
  List<Object> get props => [this.deleteUid];
}
