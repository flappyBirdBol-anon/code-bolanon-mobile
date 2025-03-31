import 'package:code_bolanon/app/app.locator.dart';
import 'package:code_bolanon/services/analytics_service.dart';
import 'package:code_bolanon/services/api_service.dart';
import 'package:code_bolanon/services/appointment_service.dart';
import 'package:code_bolanon/services/auth_service.dart';
import 'package:code_bolanon/services/course_service.dart';
import 'package:code_bolanon/services/file_service.dart';
import 'package:code_bolanon/services/forgot_password_service.dart';
import 'package:code_bolanon/services/image_service.dart';
import 'package:code_bolanon/services/lesson_service.dart';
import 'package:code_bolanon/services/payment_service.dart';
import 'package:code_bolanon/services/registration_service.dart';
import 'package:code_bolanon/services/stripe_service.dart';
import 'package:code_bolanon/services/tech_stack_service.dart';
import 'package:code_bolanon/services/theme_service.dart';
import 'package:code_bolanon/services/user_service.dart';
import 'package:code_bolanon/services/wishlist_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';

import 'test_helpers.mocks.dart';
import 'package:code_bolanon/services/selected_stack_service.dart';
import 'package:code_bolanon/services/transactions_service.dart';
// @stacked-import

@GenerateMocks(
  [],
  customMocks: [
    MockSpec<NavigationService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<BottomSheetService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<DialogService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<AuthService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<ThemeService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<ApiService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<CourseService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<ImageService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<UserService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<LessonsService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<FileService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<PaymentService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<StripeService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<ForgotPasswordService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<TechStackService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<AnalyticsService>(onMissingStub: OnMissingStub.returnDefault),

    MockSpec<WishlistService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<RegistrationService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<AppointmentService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<SelectedStackService>(onMissingStub: OnMissingStub.returnDefault),

    MockSpec<TransactionsService>(onMissingStub: OnMissingStub.returnDefault),
// @stacked-mock-spec
  ],
)
void registerServices() {
  getAndRegisterNavigationService();
  getAndRegisterBottomSheetService();
  getAndRegisterDialogService();
  getAndRegisterAuthService();
  getAndRegisterThemeService();
  getAndRegisterApiService();
  getAndRegisterCourseService();
  getAndRegisterImageService();
  getAndRegisterUserService();
  getAndRegisterLessonService();
  getAndRegisterFileService();
  getAndRegisterPaymentService();
  getAndRegisterStripeService();
  getAndRegisterForgotPasswordService();
  getAndRegisterTechStackService();
  getAndRegisterAppointmentService();
  getAndRegisterSelectedStackService();

  getAndRegisterTransactionsService();
// @stacked-mock-register
}

MockNavigationService getAndRegisterNavigationService() {
  _removeRegistrationIfExists<NavigationService>();
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);
  return service;
}

MockBottomSheetService getAndRegisterBottomSheetService<T>({
  SheetResponse<T>? showCustomSheetResponse,
}) {
  _removeRegistrationIfExists<BottomSheetService>();
  final service = MockBottomSheetService();

  when(
    service.showCustomSheet<T, T>(
      enableDrag: anyNamed('enableDrag'),
      enterBottomSheetDuration: anyNamed('enterBottomSheetDuration'),
      exitBottomSheetDuration: anyNamed('exitBottomSheetDuration'),
      ignoreSafeArea: anyNamed('ignoreSafeArea'),
      isScrollControlled: anyNamed('isScrollControlled'),
      barrierDismissible: anyNamed('barrierDismissible'),
      additionalButtonTitle: anyNamed('additionalButtonTitle'),
      variant: anyNamed('variant'),
      title: anyNamed('title'),
      hasImage: anyNamed('hasImage'),
      imageUrl: anyNamed('imageUrl'),
      showIconInMainButton: anyNamed('showIconInMainButton'),
      mainButtonTitle: anyNamed('mainButtonTitle'),
      showIconInSecondaryButton: anyNamed('showIconInSecondaryButton'),
      secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
      showIconInAdditionalButton: anyNamed('showIconInAdditionalButton'),
      takesInput: anyNamed('takesInput'),
      barrierColor: anyNamed('barrierColor'),
      barrierLabel: anyNamed('barrierLabel'),
      customData: anyNamed('customData'),
      data: anyNamed('data'),
      description: anyNamed('description'),
    ),
  ).thenAnswer(
    (realInvocation) =>
        Future.value(showCustomSheetResponse ?? SheetResponse<T>()),
  );

  locator.registerSingleton<BottomSheetService>(service);
  return service;
}

MockDialogService getAndRegisterDialogService() {
  _removeRegistrationIfExists<DialogService>();
  final service = MockDialogService();
  locator.registerSingleton<DialogService>(service);
  return service;
}

MockAuthService getAndRegisterAuthService() {
  _removeRegistrationIfExists<AuthService>();
  final service = MockAuthService();
  locator.registerSingleton<AuthService>(service);
  return service;
}

MockThemeService getAndRegisterThemeService() {
  _removeRegistrationIfExists<ThemeService>();
  final service = MockThemeService();
  locator.registerSingleton<ThemeService>(service);
  return service;
}

MockApiService getAndRegisterApiService() {
  _removeRegistrationIfExists<ApiService>();
  final service = MockApiService();
  locator.registerSingleton<ApiService>(service);
  return service;
}

MockCourseService getAndRegisterCourseService() {
  _removeRegistrationIfExists<CourseService>();
  final service = MockCourseService();
  locator.registerSingleton<CourseService>(service);
  return service;
}

MockImageService getAndRegisterImageService() {
  _removeRegistrationIfExists<ImageService>();
  final service = MockImageService();
  locator.registerSingleton<ImageService>(service);
  return service;
}

MockUserService getAndRegisterUserService() {
  _removeRegistrationIfExists<UserService>();
  final service = MockUserService();
  locator.registerSingleton<UserService>(service);
  return service;
}

MockLessonsService getAndRegisterLessonService() {
  _removeRegistrationIfExists<LessonsService>();
  final service = MockLessonsService();
  locator.registerSingleton<LessonsService>(service);
  return service;
}

MockFileService getAndRegisterFileService() {
  _removeRegistrationIfExists<FileService>();
  final service = MockFileService();
  locator.registerSingleton<FileService>(service);
  return service;
}

MockPaymentService getAndRegisterPaymentService() {
  _removeRegistrationIfExists<PaymentService>();
  final service = MockPaymentService();
  locator.registerSingleton<PaymentService>(service);
  return service;
}

MockStripeService getAndRegisterStripeService() {
  _removeRegistrationIfExists<StripeService>();
  final service = MockStripeService();
  locator.registerSingleton<StripeService>(service);
  return service;
}

MockForgotPasswordService getAndRegisterForgotPasswordService() {
  _removeRegistrationIfExists<ForgotPasswordService>();
  final service = MockForgotPasswordService();
  locator.registerSingleton<ForgotPasswordService>(service);
  return service;
}

MockTechStackService getAndRegisterTechStackService() {
  _removeRegistrationIfExists<TechStackService>();
  final service = MockTechStackService();
  locator.registerSingleton<TechStackService>(service);
  return service;
}

MockTechStackService getAndRegisterAppointmentService() {
  _removeRegistrationIfExists<TechStackService>();
  final service = MockTechStackService();
  locator.registerSingleton<TechStackService>(service);
  return service;
}

MockSelectedStackService getAndRegisterSelectedStackService() {
  _removeRegistrationIfExists<SelectedStackService>();
  final service = MockSelectedStackService();
  locator.registerSingleton<SelectedStackService>(service);
  return service;
}

MockTransactionsService getAndRegisterTransactionsService() {
  _removeRegistrationIfExists<TransactionsService>();
  final service = MockTransactionsService();
  locator.registerSingleton<TransactionsService>(service);
  return service;
}

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
