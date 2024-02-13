class ProjectUnit {
  final int project_id;
  final String project_name;
  final int project_time;
  final int project_year;
  final String project_address;
  final String project_province;
  final String project_district;
  final String project_subdistrict;
  final DateTime project_start_date;
  final DateTime project_end_date;
  final String project_shph;

  ProjectUnit({
    required this.project_id,
    required this.project_name,
    required this.project_time,
    required this.project_year,
    required this.project_address,
    required this.project_province,
    required this.project_district,
    required this.project_subdistrict,
    required this.project_start_date,
    required this.project_end_date,
    required this.project_shph,
  });
}

List<ProjectUnit> parseJsonDataProject(dynamic jsonData) {
  List<ProjectUnit> projectList = [];

  for (var projectJson in jsonData) {
    ProjectUnit project = ProjectUnit(
      project_id: projectJson['project_id'],
      project_name: projectJson['project_name'],
      project_time: projectJson['project_time'],
      project_year: projectJson['project_year'],
      project_address: projectJson['project_address'],
      project_province: projectJson['project_province'],
      project_district: projectJson['project_district'],
      project_subdistrict: projectJson['project_subdistrict'],
      project_start_date: DateTime.parse(projectJson['project_start_date']),
      project_end_date: DateTime.parse(projectJson['project_end_date']),
      project_shph: projectJson['project_shph'],
    );
    projectList.add(project);
  }

  return projectList;
}
