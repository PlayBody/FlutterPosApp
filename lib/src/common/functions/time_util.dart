import 'package:intl/intl.dart';
import 'package:staff_pos_app/src/common/const.dart';
import 'package:staff_pos_app/src/model/shift_model.dart';
import 'package:staff_pos_app/src/model/stafflistmodel.dart';

const int WEEK_COUNT = 7; // 한주일개수
const int MINUTE_ON_HOUR = 1441; // 하루의 총 분수+1
const bool USE_REST_FLAG = true; // 직원이 한주일동안 희망하는 시간을 초과하지 않도록 시간조절

class WorkTime {
  static const int STATE_BLOCKED = 0; // 리용할수 없음 (휴식, 점외대기)
  static const int STATE_NORMAL = 1; // 리용가능
  static const int STATE_EMPTY = 2; // 아무것도 요청한것이 없음

  int state = STATE_EMPTY; // 상태
  String id = '-1'; // 식별자
  int st = 0; // 시작분
  int en = 0; // 마감분

  int ost = 0; // 원래 시작분
  int oen = 0; // 원래 마감

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
      DateTime weekFirstDay, int week, String staffId) {
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
        shiftType: shiftType);
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
  int count = 0;

  // private
  List<int> req = [];
  List<int> now = [];

  WorkPlan.newInstance() {
    req = List.filled(MINUTE_ON_HOUR, 0);
    now = List.filled(MINUTE_ON_HOUR, 0);
  }

  WorkPlan(DateTime from, DateTime to, int requireCount) {
    st = from.hour * 60 + from.minute;
    en = to.hour * 60 + to.minute;
    count = requireCount;
    req = List.filled(MINUTE_ON_HOUR, 0);
    now = List.filled(MINUTE_ON_HOUR, 0);
    int i;
    for (i = st; i < en; i++) {
      req[i] = count;
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
  static List<WorkTime> AssignWorkTime(
      List<Worker> workers /** 직원들 */,
      List<WorkPlan> plans /** 계획들 7일 */,
      String organId,
      DateTime weekFirstDay) {
    // i: 항상 직원을 지적하는 첨수로만 리용한다.
    // j: 항상 요일을 지적하는 첨수로만 리용한다.
    // k: 항상 분을 지적하는 첨수로만 리용한다.
    int i, j, k;
    // 모든 직원들을 주당 작업희망하는 시간순서대로 정렬한다.
    workers.sort((a, b) => -a.hopeMinuteOnWeek.compareTo(b.hopeMinuteOnWeek));

    // 첫번째 코드부분...
    // 이 부분에서는 모든 직원들을 상점이 바라는 시간표에 맞추어 가능한껏 넣어준다.
    // 직원들이 요구하는 시간이 상점에서 요구하는 시간보다 더 긴 경우 잘라버리는 조작이 들어간다.
    // 즉 이 부분을 통과하면 모든 직원들은 자기가 바라는 시간구역안에서 같거나 작은 시간구역으로 이전된다.
    // 특수경우의 직원에 대해서는 계산을 무시한다. (휴식, 부재, 미등록)

    int workerCount = workers.length;
    // i: 직원첨수, 직원들을 차례로 순환한다.
    for (i = 0; i < workerCount; i++) {
      // worker: 선택된 개별적인 직원
      Worker worker = workers[i];
      // j: 요일을 의미한다.
      for (j = 0; j < WEEK_COUNT; j++) {
        // j번째 요일의 출근계획
        WorkPlan plan = plans[j];
        // 그 요일에 상점에서 사람을 요구하지 않으면 자동무시
        if (plans[j].count == 0) {
          continue;
        }
        // t: 직원의 j 요일에 대한 작업시간 관계를 나타내는 변수
        WorkTime t = worker.times[j];
        // 만일 j 요일에 직원이 휴식, 부재이거나 일하겠다는 요청이 없으면 다음번 순환으로 넘긴다.
        if (!t.isNormal()) {
          continue;
        }
        // st: j번째 요일에 t가 바라는 작업시작시간.
        // en: j번째 요일에 t가 바라는 작업마감시간.
        int st = t.st;
        int en = t.en;
        // tst: 림시 적합한 시간선의 시작
        // ten: 림시 적합한 시간선의 마감
        int tst = t.st;
        int ten = t.st;
        // nst: 가장 적합한 시간선의 시작
        // nen: 가장 적합한 시간선의 마감
        int nst = 0;
        int nen = 0;
        // k: 작업예상시간
        for (k = st; k < en; k++) {
          // 현재의 계획된 시간에 인원이 모자라는가를 검사
          if (plan.req[k] > plan.now[k]) {
            // 모자라면 직원이 바라는 림시작업마감시간을 늘구어준다
            ten = k + 1;
          } else {
            // 이미 직원이 다 찼을 경우 현재 시간선의 보관여부를 따진다.
            if (nen - nst < ten - tst) {
              // 현재 상태가 좋으면 림시보관한다.
              nst = tst;
              nen = ten;
            }
            // 다음번에 더 좋은 시간선이 나올수 있으므로 그것을 찾기위해 림시변수를 갱신한다.
            tst = k + 1;
            ten = k + 1;
          }
        }
        // 마지막으로 한번 더 시간선의 보관여부를 따져본다.
        if (nen - nst < ten - tst) {
          // 현재 상태가 좋으면 림시보관한다.
          nst = tst;
          nen = ten;
        }
        // 현재의 시간선을 등록한다.
        t.st = nst;
        t.en = nen;
        for (k = nst; k < nen; k++) {
          plan.now[k]++;
        }
      }
    }
    // 웃부분 코드를 통하여 모든 직원들은 자기가 바라는 시간구역에 놓이게 되였다.

    // 두번째 코드부분...
    // 이 부분에서는 상점의 립장에서 상점이 요구하는 시간에 무조건 직원이 있어야 한다는것을 고려한다.
    // 상점이 요구하는 시간에 충분한 직원들이 없는 경우 더 늘구어주는 조작이 들어간다.
    // 특수경우의 직원에 대해서는 계산을 무시한다. (휴식, 부재, 미등록)

    for (i = 0; i < workerCount; i++) {
      Worker worker = workers[i];
      // 직원이 한주 일하고싶은 총 시간에서 현재까지 등록된 시간을 던 나머지 유용한 시간을 얻는다.
      int rest = worker.getRestMinute();
      for (j = 0; j < WEEK_COUNT; j++) {
        // j번째 요일의 출근계획
        WorkPlan plan = plans[j];
        // 그 요일에 상점에서 사람을 요구하지 않으면 자동무시
        if (plans[j].count == 0) {
          continue;
        }
        // t: 직원의 j 요일에 대한 작업시간 관계를 나타내는 변수
        WorkTime t = worker.times[j];
        // 만일 j 요일에 직원이 휴식, 부재이거나 일하겠다는 요청이 없으면 다음번 순환으로 넘긴다.
        if (!t.isNormal()) {
          continue;
        }
        // 직원이 일할 여유시간이 모자라면 그만둔다.
        if (USE_REST_FLAG && rest <= 0) {
          continue;
        }
        // 직원의 현재 시간선시작점을 앞쪽으로 최대로 늘군다.
        for (k = t.st - 1; k >= plan.st; k--) {
          // 앞쪽이 막혔으면 그만두고 그렇지 않으면 늘군다.
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
        // 직원이 일할 여유시간이 모자라면 그만둔다.
        if (USE_REST_FLAG && rest <= 0) {
          continue;
        }
        // 이번에는 뒤쪽으로 최대로 늘구어본다.
        for (k = t.en; k < plan.en; k++) {
          // 뒤쪽 막혔으면 그만두고 그렇지 않으면 늘군다.
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

    // 세번째 코드부분...
    // 두번째 부분을 통과한 후에도 여전히 상점의 요구를 만족시키지 못하는것을 고려하여 미등록한 직원들도 일할것을 요구한다.
    // 여기서는 오직 미등록한 직원들만 가지고 시간선을 만들어준다.
    for (i = 0; i < workerCount; i++) {
      Worker worker = workers[i];
      // 직원이 한주 일하고싶은 총 시간에서 현재까지 등록된 시간을 던 나머지 유용한 시간을 얻는다.
      int rest = worker.getRestMinute();
      for (j = 0; j < WEEK_COUNT; j++) {
        // t: 직원의 j 요일에 대한 작업시간 관계를 나타내는 변수
        WorkTime t = worker.times[j];
        // 직원이 등록가능한 상태인가를 따져본다.
        if (!t.isEmpty()) {
          continue;
        }
        // 직원이 일할 여유시간이 있는가를 검사한다.
        if (USE_REST_FLAG && rest <= 0) {
          continue;
        }
        // j번째 요일의 출근계획
        WorkPlan plan = plans[j];
        // 계획에서 가장 긴 빈 시간선을 얻는다.
        List<int> interval = plan.getMaxInterval();
        int st = interval[0];
        int en = interval[1];
        // 빈 시간선이 없으면 좋다. 그냥 넘긴다.
        if (st >= en) {
          continue;
        }
        // 시간을 할당한다.
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
              workers[i].meta.staffId ?? ""));
        }
      }
    }
    return times;
  }
}
