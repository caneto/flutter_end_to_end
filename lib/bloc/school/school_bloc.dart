import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:sample_latest/analytics_exception_handler/exception_handler.dart';
import 'package:sample_latest/services/db/offline_handler.dart';
import 'package:sample_latest/models/school/school_details_model.dart';
import 'package:sample_latest/models/school/school_model.dart';
import 'package:sample_latest/models/school/student_model.dart';
import 'package:sample_latest/services/utils/service_enums_typedef.dart';
import 'package:sample_latest/global_variables.dart';
import 'package:sample_latest/mixins/notifiers.dart';

import '../../services/repository/school_repository.dart';
import 'package:loader_overlay/loader_overlay.dart';

part 'school_event.dart';
part 'school_state.dart';

class SchoolBloc extends Bloc<SchoolEvent, SchoolState> {

  final SchoolRepository repository;
  bool viewAllStudents = true;
  var schools = <SchoolModel>[];
  var students = <StudentModel>[];

  bool isWelcomeMessageShowed = false;

  SchoolBloc(this.repository)
      : super(const SchoolInfoInitial(SchoolDataLoadedType.schools)) {

    on<SchoolsDataEvent>(loadSchools);

    on<SchoolDataEvent>(loadSchoolDetails);

    on<StudentsDataEvent>(loadStudents);

    on<StudentDataEvent>(loadStudent);

    on<CreateOrUpdateSchoolEvent>(createOrUpdateSchool);

    on<CreateOrEditSchoolDetailsEvent>(createOrEditSchoolDetails);

    on<CreateOrEditStudentEvent>(createOrEditStudent);

    on<DeleteSchoolEvent>(deleteSchool);

    on<DeleteStudentEvent>(deleteStudent);

    on<SyncAndDumpTheData>(syncAndDumpTheData);
  }

  Future<void> loadSchools(SchoolsDataEvent event, Emitter<SchoolState> emit) async {

    const schoolState = SchoolDataLoadedType.schools;

    emit(SchoolInfoLoading(schoolState, showedWelcomeMessage: isWelcomeMessageShowed));

    try {
      schools.clear();
      schools = await repository.fetchSchools();
      emit(SchoolsInfoLoaded(schoolState, schools));
    } catch (e, s) {
      emit(SchoolDataError(
          schoolState, ExceptionHandler().handleException(e, s)));
    }
  }

  Future<void> loadSchoolDetails(SchoolDataEvent event, Emitter<SchoolState> emit) async {

    const schoolState = SchoolDataLoadedType.school;

    students.clear();
    emit(const SchoolInfoLoading(schoolState));

    try {
      var school = await repository.fetchSchoolDetails(event.id);
      if (school != null) {
        emit(SchoolInfoLoaded(schoolState, school));
      } else {
        emit(const SchoolDataNotFound(schoolState));
        add(StudentsDataEvent(event.id));
      }
    } catch (e, s) {
      emit(SchoolDataError(
          schoolState, ExceptionHandler().handleException(e, s)));
    }
  }

  Future<void> loadStudents(StudentsDataEvent event, Emitter<SchoolState> emit) async {

    const schoolState = SchoolDataLoadedType.students;

    emit(const SchoolInfoLoading(schoolState));

    try {
      students = await repository.fetchStudents(event.schoolId);
      viewAllStudents = false;
      emit(StudentsInfoLoaded(schoolState, students, event.schoolId));
    } catch (e, s) {
      emit(SchoolDataError(
          schoolState, ExceptionHandler().handleException(e, s)));
    }
  }

  Future<void> loadStudent(StudentDataEvent event, Emitter<SchoolState> emit) async {
    const schoolState = SchoolDataLoadedType.student;

    emit(const SchoolInfoLoading(schoolState));

    try {
      var student =
          await repository.fetchStudent(event.studentId, event.schoolId);

      if(student != null){
        emit(StudentInfoLoaded(schoolState, student, event.schoolId));
      }else{
        navigatorKey.currentState?.pop();
        Notifiers.toastNotifier('Invalid student details');
      }
    } catch (e, s) {
      emit(SchoolDataError(
          schoolState, ExceptionHandler().handleException(e, s)));
    }
  }

  Future<void> createOrUpdateSchool(
      CreateOrUpdateSchoolEvent event, Emitter<SchoolState> emit) async {

    const schoolState = SchoolDataLoadedType.schools;

    try {
      navigatorKey.currentContext?.loaderOverlay.show();

      var createdOrUpdatedSchool = await repository.createOrEditSchool(event.school);

      /// cloning object
      schools = List.from(schools);

      if (!event.isCreateSchool) {
        var index =
        schools.indexWhere((school) => school.id == event.school.id);
        if (index != -1) {
          schools[index] = createdOrUpdatedSchool;
        }
      } else {
        schools.add(createdOrUpdatedSchool);
      }

      emit(SchoolsInfoLoaded(schoolState, schools));
    } catch (e, s) {
      ExceptionHandler().handleExceptionWithToastNotifier(e,
          stackTrace: s, toastMessage: event.isCreateSchool ? 'Unable to create the School' : 'Unable to update the school');
    } finally {
      navigatorKey.currentContext?.loaderOverlay.hide();
    }
  }

  Future<void> createOrEditSchoolDetails(CreateOrEditSchoolDetailsEvent event, Emitter<SchoolState> emit) async {

    const schoolState = SchoolDataLoadedType.school;

    try {
      navigatorKey.currentContext?.loaderOverlay.show();

      var createdOrEditSchoolDetails =
          await repository.addOrEditSchoolDetails(event.schoolDetails);

      emit(SchoolInfoLoaded(schoolState, createdOrEditSchoolDetails));

    } catch (e, s) {
      ExceptionHandler().handleExceptionWithToastNotifier(e,
          stackTrace: s, toastMessage: 'Unable to create the School Details');
    } finally {
      navigatorKey.currentContext?.loaderOverlay.hide();
    }
  }

  Future<void> createOrEditStudent(CreateOrEditStudentEvent event, Emitter<SchoolState> emit) async {
    const schoolState = SchoolDataLoadedType.students;

    try {

      navigatorKey.currentContext?.loaderOverlay.show();

      var createdStudent = await repository.createOrEditStudent(event.schoolId, event.student);

      viewAllStudents = true;

      students = List.from(students);
      if (!event.isCreateStudent) {
        var index =
        students.indexWhere((student) => student.id == event.student.id);
        if (index != -1) {
          students[index] = createdStudent;
        }
      } else {
        students.add(createdStudent);
      }

      emit(StudentsInfoLoaded(schoolState, students, event.schoolId));

    } catch (e, s) {
      ExceptionHandler().handleExceptionWithToastNotifier(e,
          stackTrace: s,
          toastMessage: event.isCreateStudent
              ? 'Unable to create the student'
              : 'Failed to update the Student');
    } finally {
      navigatorKey.currentContext?.loaderOverlay.hide();
    }
  }

  Future<void> deleteSchool(DeleteSchoolEvent event, Emitter<SchoolState> emit) async {

    const schoolState = SchoolDataLoadedType.schools;

    try {
      navigatorKey.currentContext?.loaderOverlay.show();

      //var status = await repository.deleteSchool(event.schoolId);

      schools = List.from(schools);
      schools.removeWhere((school) => school.id == event.schoolId);

      emit(SchoolsInfoLoaded(schoolState, schools));
    } catch (e, s) {
      ExceptionHandler().handleExceptionWithToastNotifier(e,
          stackTrace: s, toastMessage: 'Failed to Delete the School');
    } finally {
      navigatorKey.currentContext?.loaderOverlay.hide();
    }
  }

  Future<void> deleteStudent(DeleteStudentEvent event, Emitter<SchoolState> emit) async {

    const schoolState = SchoolDataLoadedType.students;

    emit(const SchoolInfoLoading(schoolState));

    try {

      navigatorKey.currentContext?.loaderOverlay.show();

      var status =
          await repository.deleteStudent(event.studentId, event.schoolId);

      if (status) {
        students = List.from(students);
        students.removeWhere((student) => student.id == event.studentId);

        emit(StudentsInfoLoaded(schoolState, students, event.schoolId));
      }
    } catch (e, s) {
      ExceptionHandler().handleExceptionWithToastNotifier(e,
          stackTrace: s, toastMessage: 'Failed to Delete the student');
    } finally {
      navigatorKey.currentContext?.loaderOverlay.hide();
    }
  }

  Future<void> syncAndDumpTheData(SyncAndDumpTheData event, Emitter<SchoolState> emit) async {
    const schoolState = SchoolDataLoadedType.schools;

    try {
      if (event.isSyncData) {
        await OfflineHandler().syncData();
      } else {
        await OfflineHandler().dumpOfflineData();
      }

      emit(SchoolsInfoLoaded(schoolState, [...schools]));
    } catch (e, s) {
      ExceptionHandler().handleExceptionWithToastNotifier(e,
          stackTrace: s, toastMessage: 'Failed to Delete the student');
    }
  }
}
