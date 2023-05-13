class StaffModel {
  final String staffId;
  final String companyId;
  final String qrCode;
  final String auth;
  final String nick;
  final String firstName;
  final String lastName;
  final String tel;
  final String mail;
  final String sex;
  final String password;
  final String? enteringDate;
  final String gradeLevel;
  final String nationalLevel;
  final DateTime birthday;
  final String belongs;
  final String salaryMonth;
  final String salaryDay;
  final String? salaryMinute;
  final String salaryTime;
  final String image;
  final String testAdditionalRate;
  final String qualityAdditionalRate;
  final String shift;
  final String? tablePosition;
  final bool isPush;
  final String comment;
  final String? menuResponse;
  final String addRate;
  final String testRate;
  final String qualityRate;

  const StaffModel(
      {required this.staffId,
      required this.companyId,
      required this.qrCode,
      required this.auth,
      required this.nick,
      required this.firstName,
      required this.lastName,
      required this.tel,
      required this.mail,
      required this.sex,
      required this.password,
      this.enteringDate,
      required this.gradeLevel,
      required this.nationalLevel,
      required this.birthday,
      required this.belongs,
      required this.salaryMonth,
      required this.salaryDay,
      this.salaryMinute,
      required this.salaryTime,
      required this.image,
      required this.testAdditionalRate,
      required this.qualityAdditionalRate,
      required this.shift,
      this.tablePosition,
      required this.isPush,
      required this.comment,
      this.menuResponse,
      required this.addRate,
      required this.testRate,
      required this.qualityRate});

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      staffId: json['staff_id'] ?? '',
      companyId: json['company_id'] ?? '',
      qrCode: json['staff_qrcode'] ?? '',
      auth: json['staff_auth'] ?? '1',
      nick: json['staff_nick'] ?? '',
      firstName: json['staff_first_name'] ?? '',
      lastName: json['staff_last_name'] ?? '',
      tel: json['staff_tel'] ?? '',
      mail: json['staff_mail'] ?? '',
      sex: json['staff_sex'] ?? '1',
      password: json['staff_password'] == null ? '' : json['staff_sex'],
      enteringDate: json['staff_entering_date'],
      gradeLevel: json['staff_grade_level'] ?? '',
      nationalLevel: json['staff_national_level'] ?? '',
      birthday: (json['staff_birthday'] == null ||
              json['staff_birthday'] == '0000-00-00')
          ? DateTime.now()
          : DateTime.parse(json['staff_birthday']),
      belongs: json['staff_belongs'] ?? '',
      salaryMonth: json['staff_salary_months'] ?? '',
      salaryDay: json['staff_salary_days'] ?? '',
      salaryMinute: json['staff_salary_minutes'],
      salaryTime: json['staff_salary_times'] ?? '',
      image: json['staff_image'] ?? '',
      testAdditionalRate: json['staff_test_additional_rate'] ?? '',
      qualityAdditionalRate: json['staff_quality_additional_rate'] ?? '',
      shift: json['staff_shift'] ?? '',
      tablePosition: json['table_position'],
      isPush: (json['is_push'] == null || json['is_push'].toString() == '1')
          ? true
          : false,
      comment: json['staff_comment'] ?? '',
      menuResponse: json['menu_response'],
      addRate: json['add_rate'] ?? '',
      testRate: json['test_rate'] ?? '',
      qualityRate: json['quality_rate'] ?? '',
    );
  }
}
