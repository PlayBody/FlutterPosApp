import 'package:flutter/material.dart';

// ---------------- Store URL -----------------------
const String consAndroidStore =
    'https://play.google.com/apps/internaltest/4701332527315630553';

const int constIsTestApi = 0;

// ---------------- Permission Manager -----------------------
const int constAuthGuest = 0;
const int constAuthStaff = 1;
const int constAuthBoss = 2;
const int constAuthManager = 3;
const int constAuthOwner = 4;
const int constAuthSystem = 5;

const String constOrderStatusNone = '0';
const String constOrderStatusReserveRequest = '1';
const String constOrderStatusReserveReject = '2';
const String constOrderStatusReserveCancel = '3';
const String constOrderStatusReserveApply = '4';
const String constOrderStatusTableReject = '5';
const String constOrderStatusTableStart = '6';
const String constOrderStatusTableEnd = '7';
const String constOrderStatusTableComplete = '8';

const String constPayMethodCredit = '1';
const String constPayMethodCash = '2';
const String constPayMethodOther = '3';

const String constReserveRequest = '1';
const String constReserveApply = '2';
const String constReserveReject = '3';
const String constReserveCancel = '4';
const String constReserveEntering = '5';
const String constReserveComplete = '6';

// ---------------- Shift status -----------------------
const String constShiftSubmit = '1';
const String constShiftReject = '2';
const String constShiftOut = '3';
const String constShiftRest = '4';
const String constShiftRequest = '5';
const String constShiftMeReject = '6';
const String constShiftMeReply = '7';
const String constShiftMeApply = '9';
const String constShiftApply = '10';

const List<String> constShiftUsingList = [
  '1',
  '2',
  '3',
  '5',
  '6',
  '7',
  '9',
  '10'
];

//var c = Colors.blue;
const constShiftAppoints = {
  constShiftSubmit: {'color': '0xff2196f3', 'subject': '申請中', 'note': ''},
  constShiftReject: {'color': '0xffb72727', 'subject': '拒否', 'note': ''},
  constShiftOut: {'color': '0xff7d4285', 'subject': '店外待機', 'note': ''},
  constShiftRest: {'color': '0xff979797', 'subject': '休み', 'note': ''},
  constShiftRequest: {'color': '0xffe58f0e', 'subject': '出勤要請', 'note': ''},
  constShiftMeReject: {'color': '0xffb72727', 'subject': '要求拒否', 'note': ''},
  constShiftMeReply: {'color': '0xffa5c109', 'subject': '回答済み', 'note': ''},
  constShiftMeApply: {
    'color': '0xff09c153',
    'subject': '回答済み - 承認',
    'note': ''
  },
  constShiftApply: {'color': '0xff09c153', 'subject': '承認', 'note': ''},
};

List<dynamic> authList = [
  {'value': constAuthGuest.toString(), 'label': 'ゲスト'},
  {'value': constAuthStaff.toString(), 'label': 'スタッフ'},
  {'value': constAuthBoss.toString(), 'label': '店長'},
  {'value': constAuthManager.toString(), 'label': 'マネージャー'},
  {'value': constAuthOwner.toString(), 'label': 'オーナー'}
];

List<String> weekAry = ['月', '火', '水', '木', '金', '土', '日'];
List<dynamic> constWeeks = [
  {'key': 'Mon', 'val': '月曜日', 'value': '1'},
  {'key': 'Tue', 'val': '火曜日', 'value': '2'},
  {'key': 'Wed', 'val': '水曜日', 'value': '3'},
  {'key': 'Thu', 'val': '木曜日', 'value': '4'},
  {'key': 'Fri', 'val': '金曜日', 'value': '5'},
  {'key': 'Sat', 'val': '土曜日', 'value': '6'},
  {'key': 'Sun', 'val': '日曜日', 'value': '7'},
];

List<dynamic> constStaffPointAllMenu = [
  {'key': '1', 'val': 'ランクA'}, //修了
  {'key': '2', 'val': 'ランクB'}, //未修了
  {'key': '3', 'val': 'ランクC'},
];

List<dynamic> constPayMethod = [
  {'key': constPayMethodCash, 'val': '現金'},
  {'key': constPayMethodOther, 'val': 'その他電子マネー'},
  {'key': constPayMethodCredit, 'val': 'クレジットカード'},
];

List<dynamic> constEntering = [
  {'key': '1', 'val': 'はい'},
  {'key': '2', 'val': 'いいえ'},
  {'key': '3', 'val': 'お断り'},
];

List<dynamic> constCouponCondition = [
  {'key': '1', 'val': '他クーポンと併用不可'},
  {'key': '2', 'val': '他クーポンと併用化'},
];

// List<String> menuQuantity = ['1', '2', '3', '4'];
List<String> dropTableCount = [];
List<String> dropEnteringCount = [
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '10'
];

List<dynamic> constSex = [
  {'value': '1', 'label': '男'},
  {'value': '2', 'label': '女'},
];

List<dynamic> constAges = [
  {'key': '20', 'val': '20歳以下'},
  {'key': '20-30', 'val': '20~30歳'},
  {'key': '30-40', 'val': '30~40歳'},
  {'key': '40-50', 'val': '40~50歳'},
  {'key': '50', 'val': '50歳以上'},
];

List<String> constPointUnit = ['回', '分', '件'];

String constCheckinTypeNone = '0';
String constCheckinTypeBoth = '1';
String constCheckinTypeOnlyReserve = '2';

var primaryColor = const Color(0xff117fc1);
var redColor = const Color(0xffee385a);
var bodyColor = const Color(0xfffbfbfb);

var licenseHtml = r"""
    <h5>（目的）</h5>
    <h3>第１条 本利用規約は、Devotionが提供するクラウドPOSアプリケーション「VISIT」(以下、本アプリ)の利用に関し、これを利用するすべての者に適用される利用条件その他の事項を定めることを目的とします。</h3>
    
    <h5>（定義）</h5>
    <h3>第２条　本利用規約で使用する用語の定義は、次の各号のとおりとします。</h3>

    <h5>（本利用規約への同意）</h5>
    <h3>第３条 アプリ利用者は、本利用規約の定めに従って本アプリを利用しなければならず、本利用規約の内容を十分に理解した上で、本利用規約に同意しない限り、本アプリを利用できません。</h3>
    <p>アプリ利用者は、実際に本アプリの利用を開始した場合には、本利用規約の内容を十分に理解した上で、本利用規約に同意したものとみなされます。</p>
    
    <h5>（本アプリ等に関する知的財産権等）</h5>
    <h3>第４条 Devotionがアプリ利用者に提供する一切のサービス、プログラム及び各種著作物（本利用規約及び利用手順書等を含みます。以下同じ。）に関する著作権及び著作者人格権、商標権その他の知的財産権並びにノウハウその他の知的財産に係る権利は、全てDevotion又は正当な権利者に帰属し、本アプリの利用は、本利用規約で別途定める場合を除き、アプリ利用者に対するこれらの知的財産に係る権利の移転又は使用権の設定若しくは許諾を意味するものではありません。</h3>
    <h4>１ アプリ利用者は、本アプリの利用に際し、Devotionがアプリ利用者に提供する一切のサービス、プログラム及び各種著作物を次の各号のとおり取り扱うものとします。</h4>
    <p>一 本利用規約に従った本アプリの適正な利用のためにのみ使用すること。</p>
    <p>二 複製、改変、編集、頒布等を行わず、また、リバースエンジニアリングを行わないこと。</p>
    <p>三 営利目的の有無にかかわらず、第三者に貸与、譲渡若しくは承継し、又は担保の設定をしないこと。</p>
    <p>四 Devotion又はDevotionが指定する者が表示した著作権表示又は商標権表示を削除又は変更しないこと。</p>

    <h5>（利用可能時間及び利用の停止等）</h5>
    <h3>第５条 本アプリの利用可能時間は、原則として24時間365日とします。ただし、サーバの運転状況により、本アプリの一部の機能の提供ができない場合があります。</h3>
    <h4>１Devotionは、次の各号のいずれかに該当すると認められる場合は、アプリ利用者に対し、事前にDevotionの公式サイトまたは本アプリ内に掲載した上で、本アプリの利用の停止、休止又は中断をさせることができるものとします。ただし、緊急を要する場合は、事前に通知することなく本アプリの利用の停止、休止又は中断をさせることができるものとします。</h4>
    <p>一 本アプリの運用機器等のメンテナンスが予定される場合</p>
    <p>二 電気通信事業者の役務が提供されない場合</p>
    <p>三 天災、事変その他の非常事態が発生した場合又は本アプリの運用に係る重大な障害が発生した場合</p>
    <p>四 法令又はこれに基づく措置により、本アプリの運用が不可能となった場合</p>
    <p>五 その他、Devotionにおいて、本アプリの利用の停止、休止又は中断が必要と判断した場合</p>
    <h4>２ Devotionは、本アプリの利用が著しく集中した場合には、本アプリの利用を制限することができるものとします。</h4>
    
    <h5>（アプリ利用者のサポート）</h5>
    <h3>第６条 Devotionは、本アプリに関するお問い合わせを受け付けるため、サポートデスクを設置します。サポートデスクは、アプリ利用者からの本アプリに関するお問い合わせ・ご相談をメールで受け付け、回答することにより、本アプリの利用に係るアプリ利用者の支援を行うとともに、本アプリの機能等の改善を図るための情報の集約を行うことを目的とします。メールの受信可能時間は、原則として24時間365日とします。ただし、メールサーバーの運転状況等により、メールの受信ができない場合があります。また、お問い合わせの内容等により、回答までに時間がかかる場合又は回答しかねる場合があります。</h3>

    <h5>（禁止事項及び遵守事項）</h5>
    <h3>第７条　アプリ利用者は、本アプリの利用に当たり、次の各号に掲げる行為を行うことを禁じます。</h3>
    <p>一 本アプリを本来の目的以外の目的で利用すること。</p>
    <p>二 不正アクセス行為、本アプリのサーバーやネットワークシステムに支障を与える行為、本アプリを不正に操作する行為、本アプリの不具合を意図的に利用する行為をすること。</p>
    <p>三 類似又は同様の問い合わせを必要以上に繰り返す行為、提供者に対し不当な要求をする行為、その他の提供者による本アプリの適正な管理及び運用並びに第三者による本アプリの利用を妨害し、これらに支障を与える行為をすること。</p>
    <p>四 本アプリに対し、ウイルス・マルウェア等に感染したファイルを故意に送信すること。</p>
    <p>五 法令若しくは公序良俗に違反する行為又はそのおそれがある行為、反社会的勢力に対する利益供与その他の協力行為、提供者又は第三者になりすます行為、意図的に虚偽の情報を流布させる行為をすること。</p>
    <p>六 第三者の個人情報、利用情報などを不正に収集、開示又は提供する行為をすること。</p>
    <p>七 その他、本アプリの適正な運用に支障を及ぼす行為又はそのおそれがある行為であるとDevotionが判断する行為をすること。</p>

    <h4>２ Devotionは、アプリ利用者が前項各号のいずれかに該当する行為を行った場合又は行うおそれがあると認められた場合は、事前に通知することなく、当該アプリ利用者による本アプリの利用を停止させることができるものとします。</h4>
    <h4>３ アプリ利用者は、本アプリの利用に当たり、以下の事項を遵守するものとします。</h4>
    <p>一 複数のスマートフォン端末を保有する場合は、最も利用する端末に本アプリを導入すること。</p>
    <p>二 アプリ導入端末を第三者に持ち歩かせないようにすること。</p>
    <p>三 本アプリが更新され、アプリ利用者においてダウンロードが可能な状態になったときには、アプリ導入端末に最新のアプリケーションをダウンロードして更新すること。</p>
    <p>四 アプリ導入端末を第三者に譲渡、承継若しくは貸与し、又は破棄する場合は、あらかじめ本アプリを削除すること。</p>


    <h5>（アプリ利用者の設備等）</h5>
    <h3>第８条 アプリ利用者は、本アプリを利用するために必要なすべての機器及びソフトウェア（スマートフォン端末及び通信手段に係るすべてのものを含みます。）を自己の負担において準備するものとします。その際、必要な手続は、アプリ利用者が自己の責任で行うものとします。</h3>
    <p>Ⅰ本アプリを利用するために必要な通信費用その他本アプリの利用に係る一切の費用は、アプリ利用者の負担とします。</p>
    <p>３ アプリ利用者が未成年者である場合は、当該アプリ利用者は、親権者その他の法定代理人が本アプリの利用に同意した上で、自らに対してその使用を認めたスマートフォン端末を使用して、本アプリを利用するものとします。</p>

    <h5>（免責事項）</h5>
    <h3>第９条 Devotionは、本アプリを利用すること（利用に際してウイルス・マルウェア等に感染したことその他理由の如何を問いません。）又は利用できないこと（本アプリの利用の停止、休止、中断若しくは制限、本アプリの動作不良又は通信回線の障害その他理由の如何を問いません。）その他本アプリに起因又は関連してアプリ利用者又は第三者が被った損害について一切の責任を負わないものとします。</h3>
    <h4>２ アプリ導入端末の位置測定は、アプリ導入端末の性能、所持する方向などの条件や状態によって測定値に差が生じるため、本アプリで計測する接触の距離と時間について正確性を保証するものではありません。</h4>

    <h5>（アプリの利用中止及び記録の削除）</h5>
    <h3>第１０条 アプリ利用者は、いつでも任意に、本アプリをアプリ導入端末から削除することにより、本アプリの利用を中止できます。本アプリをアプリ導入端末から削除した場合は、その端末に記録されていた情報は、全て削除され復元はできません。</h3>

    <h5>（本利用規約の変更）</h5>
    <h3>第１１条</h3>
    <h4>１Devotionが必要があると認めるときは、アプリ利用者に対し事前に通知を行うことなく、いつでも本利用規約を変更することができるものとします。</h4>
    <h4>２ Devotionは、本利用規約の変更を行った場合には、遅滞なく本アプリ内に掲載するものとし、変更後の本利用規約はかかる掲載がなされた時点からその効力を生ずるものとします。</h4>
    <h4>３ 前項に規定する変更後の本利用規約の掲載後に、アプリ利用者が本アプリを実際に利用した場合には、当該利用の時点で、アプリ利用者は変更後の本利用規約の内容を十分に理解した上で、変更後の本利用規約に同意したものとみなされます。</h4>

    <h5>（譲渡等禁止）</h5>
    <h3>第１２条 本アプリの利用権は、第三者に譲渡、貸与、承継、相続又は担保として提供することはできません。</h3>

    <h5>（準拠法及び合意管轄）</h5>
    <h3>第１３条 本利用規約及び本アプリの利用に関連するすべての事項の準拠法は、日本法とします。</h3>
    <h4>２ 本アプリの利用に起因又は関連してDevotionとアプリ利用者との間に生じたすべての紛争については、名古屋地方裁判所を第一審の専属的合意管轄裁判所とします。</h4>
""";

// ignore: constant_identifier_names
const int MAX_TICKET_COUNT = 50;
