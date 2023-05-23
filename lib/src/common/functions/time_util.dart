import 'dart:math';

import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/model/shift_model.dart';
import 'package:staff_pos_app/src/model/stafflistmodel.dart';

const int WEEK_COUNT = 7;
const int MINUTE_ON_HOUR = 1441;
const bool USE_REST_FLAG = true;

class WorkTime {
  static const int STATE_BLOCKED = 0;
  static const int STATE_NORMAL = 1;
  static const int STATE_EMPTY = 2;

  int state = STATE_EMPTY;
  String id = '-1';
  int st = 0;
  int en = 0;

  int ost = 0;
  int oen = 0;

  dynamic meta;

  WorkTime() {
    state = STATE_EMPTY;
    id = '-1';
    st = 0;
    en = 0;
    ost = 0;
    oen = 0;
  }

  factory WorkTime.fromShift(ShiftModel shift) {
    WorkTime w = WorkTime();
    if (constShiftAutoUsingList.contains(shift.shiftType)) {
      w.state = STATE_NORMAL;
    } else {
      w.state = STATE_BLOCKED;
    }
    w.id = shift.shiftId;
    w.st = shift.fromTime.hour * 60 + shift.fromTime.minute;
    w.en = shift.toTime.hour * 60 + shift.toTime.minute;
    w.ost = w.st;
    w.oen = w.en;
    return w;
  }

  factory WorkTime.fromAutoCalc(String organId, WorkTime other,
      DateTime weekFirstDay, int week, String staffId, int uniqueId) {
    String shiftType = constShiftApply;

    int st = other.st;
    int en = other.en;

    if (other.isChanged()) {
      shiftType = constShiftRequest;
    }
    if (other.isBadTime()) {
      shiftType = constShiftReject;
      st = other.ost;
      en = other.oen;
    }
    DateTime dst = weekFirstDay
        .add(Duration(days: week, hours: st ~/ 60, minutes: st % 60));
    DateTime den = weekFirstDay
        .add(Duration(days: week, hours: en ~/ 60, minutes: en % 60));
    WorkTime wt = other;
    wt.meta = ShiftModel(
        shiftId: wt.id,
        organId: organId,
        staffId: staffId,
        fromTime: dst,
        toTime: den,
        shiftType: shiftType,
        uniqueId: uniqueId);
    return wt;
  }

  bool isChanged() {
    if (st < ost || en > oen) {
      return true;
    }
    return false;
  }

  bool isBadTime() {
    if (en - st <= 0) {
      return true;
    }
    return false;
  }

  bool isUpdated() {
    if (state == STATE_BLOCKED) {
      return false;
    } else if (state == STATE_NORMAL) {
      return true;
    } else {
      if (ost == st && oen == en) {
        return false;
      }
      return true;
    }
  }

  bool isNormal() {
    return state == STATE_NORMAL;
  }

  bool isEmpty() {
    return state == STATE_EMPTY;
  }

  int getUsedMinute() {
    if (state == STATE_BLOCKED) {
      return 0;
    }
    return en - st;
  }
}

class WorkPlan {
  int st = 0;
  int en = 0;

  // private
  List<int> req = [];
  List<int> now = [];

  WorkPlan.newInstance() {
    req = List.filled(MINUTE_ON_HOUR, 0);
    now = List.filled(MINUTE_ON_HOUR, 0);
    st = 0;
    en = 0;
  }

  bool isNull() {
    return en <= st;
  }

  void appendPlan(DateTime from, DateTime to, int requireCount) {
    int tst, ten;
    tst = from.hour * 60 + from.minute;
    ten = to.hour * 60 + to.minute;
    if (st == en) {
      st = tst;
      en = ten;
    } else {
      st = min(st, tst);
      en = max(en, ten);
    }
    int i;
    for (i = tst; i < ten; i++) {
      req[i] += requireCount;
    }
  }

  List<int> getMaxInterval() {
    int ns = st;
    int ne = st;
    int s = st;
    int e = st;
    int i;
    for (i = st; i < en; i++) {
      if (req[i] > now[i]) {
        e = i + 1;
      } else {
        if (ne - ns < e - s) {
          ne = e;
          ns = s;
        }
        s = i + 1;
        e = i + 1;
      }
    }
    if (ne - ns < e - s) {
      ne = e;
      ns = s;
    }
    return [ns, ne];
  }
}

class Worker {
  List<WorkTime> times = [];
  int hopeMinuteOnWeek = 0;

  dynamic meta;

  int getRestMinute() {
    int used = 0;
    for (WorkTime time in times) {
      used += time.getUsedMinute();
    }
    return hopeMinuteOnWeek - used;
  }

  Worker() {
    times = List.generate(WEEK_COUNT, (index) => WorkTime());
  }

  factory Worker.fromStaffList(StaffListModel model) {
    Worker w = Worker();
    w.hopeMinuteOnWeek = (model.staffShift ?? 0) * 60;
    w.meta = model;
    return w;
  }

  void setShift(ShiftModel? s) {
    if (s != null) {
      times[s.fromTime.weekday - 1] = WorkTime.fromShift(s);
    }
  }
}

class WorkControl {
  static int _counter = 0;

  static int getGenCounter() {
    _counter++;
    return _counter;
  }

  static List<WorkTime> assignWorkTime(List<Worker> workers,
      List<WorkPlan> plans, String organId, DateTime weekFirstDay) {
    int i, j, k;
    workers.sort((a, b) => -a.hopeMinuteOnWeek.compareTo(b.hopeMinuteOnWeek));

    int workerCount = workers.length;
    for (i = 0; i < workerCount; i++) {
      Worker worker = workers[i];
      for (j = 0; j < WEEK_COUNT; j++) {
        WorkPlan plan = plans[j];
        if (plans[j].isNull()) {
          continue;
        }
        WorkTime t = worker.times[j];
        if (!t.isNormal()) {
          continue;
        }
        int st = t.st;
        int en = t.en;
        int tst = t.st;
        int ten = t.st;
        int nst = 0;
        int nen = 0;
        for (k = st; k < en; k++) {
          if (plan.req[k] > plan.now[k]) {
            ten = k + 1;
          } else {
            if (nen - nst < ten - tst) {
              nst = tst;
              nen = ten;
            }
            tst = k + 1;
            ten = k + 1;
          }
        }
        if (nen - nst < ten - tst) {
          nst = tst;
          nen = ten;
        }
        t.st = nst;
        t.en = nen;
        for (k = nst; k < nen; k++) {
          plan.now[k]++;
        }
      }
    }

    for (i = 0; i < workerCount; i++) {
      Worker worker = workers[i];
      int rest = worker.getRestMinute();
      for (j = 0; j < WEEK_COUNT; j++) {
        WorkPlan plan = plans[j];
        if (plans[j].isNull()) {
          continue;
        }
        WorkTime t = worker.times[j];
        if (!t.isNormal()) {
          continue;
        }
        if (USE_REST_FLAG && rest <= 0) {
          continue;
        }
        for (k = t.st - 1; k >= plan.st; k--) {
          if (plan.req[k] <= plan.now[k]) {
            break;
          } else {
            plan.now[k]++;
            t.st--;
            rest--;
            if (USE_REST_FLAG && rest == 0) {
              break;
            }
          }
        }
        if (USE_REST_FLAG && rest <= 0) {
          continue;
        }
        for (k = t.en; k < plan.en; k++) {
          if (plan.req[k] <= plan.now[k]) {
            break;
          } else {
            plan.now[k]++;
            t.en++;
            rest--;
            if (USE_REST_FLAG && rest == 0) {
              break;
            }
          }
        }
      }
    }

    for (i = 0; i < workerCount; i++) {
      Worker worker = workers[i];
      int rest = worker.getRestMinute();
      for (j = 0; j < WEEK_COUNT; j++) {
        WorkTime t = worker.times[j];
        if (!t.isEmpty()) {
          continue;
        }
        if (USE_REST_FLAG && rest <= 0) {
          continue;
        }
        WorkPlan plan = plans[j];
        List<int> interval = plan.getMaxInterval();
        int st = interval[0];
        int en = interval[1];
        if (st >= en) {
          continue;
        }
        t.st = st;
        t.en = en;
        rest -= (t.en - t.st);
        for (k = st; k < en; k++) {
          plan.now[k]++;
        }
      }
    }

    List<WorkTime> times = [];
    for (i = 0; i < workerCount; i++) {
      List<WorkTime> workTime = workers[i].times;
      for (j = 0; j < workTime.length; j++) {
        if (workTime[j].isUpdated()) {
          times.add(WorkTime.fromAutoCalc(organId, workTime[j], weekFirstDay, j,
              workers[i].meta.staffId ?? "", getGenCounter()));
        }
      }
    }
    return times;
  }
}
