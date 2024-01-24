class Patient {
  final int patient_id;
  final String patient_name;
  final String patient_surname;
  final String patient_nationalid;
  final DateTime patient_birthday;
  final int patient_age;

  Patient({
    required this.patient_id,
    required this.patient_name,
    required this.patient_surname,
    required this.patient_nationalid,
    required this.patient_birthday,
    required this.patient_age,
  });
}

List<Patient> parseJsonDataPatient(dynamic jsonData) {
  List<Patient> patientList = [];

  for (var patientJson in jsonData) {
    Patient patient = Patient(
      patient_id: patientJson['patient_id'],
      patient_name: patientJson['patient_name'],
      patient_surname: patientJson['patient_surname'],
      patient_nationalid: patientJson['patient_nationalid'],
      patient_birthday: DateTime.parse(patientJson['patient_birthday']),
      patient_age: patientJson['patient_age'],
    );
    patientList.add(patient);
  }

  return patientList;
}
