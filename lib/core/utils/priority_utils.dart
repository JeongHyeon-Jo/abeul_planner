// lib/core/utils/priority_utils.dart
int priorityValue(String priority) {
  switch (priority) {
    case '중요':
      return 0;
    case '보통':
      return 1;
    case '낮음':
    default:
      return 2;
  }
}
