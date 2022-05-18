import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'staff_event.dart';

part 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  StaffBloc() : super(NoStaffState());

  @override
  Stream<StaffState> mapEventToState(
    StaffEvent event,
  ) async* {
    if (event is LoadingStaffEvent) {
      yield* _mapLoadingStaffEventToState();
    }
  }

  Stream<StaffState> _mapLoadingStaffEventToState() async* {
    yield LoadingStaffState();
  }
}
