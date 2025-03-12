class TagService {
  // Temporary in-memory storage for course tags
  final Map<String, Set<String>> _courseTags = {};

  // Predefined available tags
  final Set<String> availableTags = {
    'Flutter',
    'React',
    'Node.js',
    'Python',
    'JavaScript',
    'TypeScript',
    'Web Dev',
    'Mobile Dev',
    'Data Science',
    'DevOps',
    'Machine Learning',
    'UI/UX',
    'Frontend',
    'Backend',
    'Full Stack',
    'Cloud',
    'Database',
    'API',
  };

  // Initialize with some sample tags for courses
  void addTagsToCourse(String courseId, List<String> tags) {
    _courseTags[courseId] = tags.toSet();
  }

  // Get tags for a specific course
  List<String> getCourseTags(String courseId) {
    return _courseTags[courseId]?.toList() ?? [];
  }

  // Get all available tags
  List<String> getAllTags() {
    return availableTags.toList();
  }

  // Check if course has specific tag
  bool courseHasTag(String courseId, String tag) {
    return _courseTags[courseId]?.contains(tag) ?? false;
  }
}
