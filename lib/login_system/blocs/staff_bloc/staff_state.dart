part of 'staff_bloc.dart';

abstract class StaffState extends Equatable {
  const StaffState();
}

// loading state for ui change
class LoadingStaffState extends StaffState {
  @override
  List<Object> get props => [];
}

// state that shows staff list
class ShowStaffState extends StaffState {
  final List<Map> staffList;

  ShowStaffState({this.staffList}): assert(staffList != null);

  @override
  List<Object> get props => [this.staffList];
}

// state that firebase has no staff or error occurred
class NoStaffState extends StaffState {
  @override
  List<Object> get props => [];
}
