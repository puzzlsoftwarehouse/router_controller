import 'package:flutter_test/flutter_test.dart';
import 'package:router_controller/src/route_utils.dart';

void main() {
  List<String> routes = [
    '/login',
    '/home',
    '/courses',
    '/courses/:courseId/modules',
    '/courses/:courseId/modules/:moduleId/editLesson/:lessonId',
    '/courses/:courseId/modules/:moduleId/newLesson',
  ];

  test("should return correctly the currentRoute", () {
    String? route =
        RouteUtils.getCurrentRoute('/courses/1/modules/2/editLesson/3', routes);
    expect(route, '/courses/:courseId/modules/:moduleId/editLesson/:lessonId');

    route =
        RouteUtils.getCurrentRoute('/courses/1/modules/2/newLesson', routes);
    expect(route, '/courses/:courseId/modules/:moduleId/newLesson');

    route = RouteUtils.getCurrentRoute('/courses/1/modules', routes);
    expect(route, '/courses/:courseId/modules');

    route = RouteUtils.getCurrentRoute('/courses', routes);
    expect(route, '/courses');

    route = RouteUtils.getCurrentRoute('/login', routes);
    expect(route, '/login');
  });
  test(
      "should return the beforeRoute of currentRoute to navigate on web when don`t have page to pop",
      () {
    String? route =
        RouteUtils.findBeforeRoute('/courses/1/modules/2/editLesson/3', routes);
    expect(route, '/courses/1/modules');

    route =
        RouteUtils.findBeforeRoute('/courses/1/modules/2/newLesson', routes);
    expect(route, '/courses/1/modules');

    route = RouteUtils.findBeforeRoute('/courses/1/modules', routes);
    expect(route, '/courses');

    route = RouteUtils.findBeforeRoute('/courses', routes);
    expect(route, null);

    route =
        RouteUtils.findBeforeRoute('/cour/1/modules/2/editLesson/3', routes);
    expect(route, null);
  });
}
