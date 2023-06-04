import 'package:staff_pos_app/src/interface/pos/staffs/staffedit.dart';
import 'package:staff_pos_app/src/model/order_menu_model.dart';
import 'package:staff_pos_app/src/model/shift_model.dart';
import 'package:staff_pos_app/src/model/staff_model.dart';

// SharedPreferences Key
String isBiometricEnableKey = 'isBiometricEnable_key';
String isSaveLoginInfoKey = 'isSaveLoginInfo_key';

String companyId = ''; // company_id
String staffId = '';
String loginEmail = '';
String loginName = '';
String organId = '';
int auth = 0; //1:staff 2:organBoss 3:manager 4: owner 5:system_manager

bool isLogin = false;

String orderQuantity = '';
bool orderInputSaveFlag = false;
List<OrderMenuModel> orderMenus = [];

String appTitle = '';
String adminAppTitle = '';
bool isWideScreen = false;

String? editMenuId;

bool isAttendance = false;
var organShifts = [];

// List<dynamic> saveControlShifts = [];
List<dynamic> saveShiftFromAutoControl = [];

int progressPercent = 0;
bool isUpload = false;

// String? staffApplyTime = '';
// String? staffApplicationTime = '';

// Shift Engine
int shiftWeekPlanMinute = 0;
int shiftWeekStaffMinute = 0;
