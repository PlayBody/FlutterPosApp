//String apiBase = 'https://www.visit-pos.com/cloud_devotion';
String apiBase = 'http://65.109.96.229:82';

String apiMaster = '$apiBase/apis/master';

String apiStaffLogin = '$apiBase/apistaffs/login';
String adviseMovieBase = '$apiBase/assets/video/advise/';
String ticketImageUrl = '$apiBase/assets/images/tickets/';
String menuImageUrl = '$apiBase/assets/images/menus/';
String organImageUrl = '$apiBase/assets/images/organs/';

String apiGetStaffAvatarUrl = '$apiBase/apistaffs/renderAvatar?staff_id=';

String apiLoadShiftLockUrl = '$apiBase/apishifts/loadLockStatus';
String apiSaveShiftLockUrl = '$apiBase/apishifts/updateLockStatus';

String apiLoadCompanyListUrl = '$apiBase/apicompanies/loadCompanyList';
String apiLoadCompanyInfoUrl = '$apiBase/apicompanies/loadCompanyInfo';

String apiLoadOrganSetTableUrl = '$apiBase/apiorgans/loadOrganSetTableData';

String apiLoadStaffSettingUrl = '$apiBase/apistaffs/loadStaffSetting';
String apiSaveStaffSettingUrl = '$apiBase/apistaffs/saveStaffSetting';

String apiLoadAttendanceUrl = '$apiBase/apistaffs/loadStaffAttendance';
String apiUpdateAttendanceUrl = '$apiBase/apistaffs/updateStaffAttendance';

String apiLoadTablesUrl = '$apiBase/apitables/loadTables';
String apiUpdateTableTitleUrl = '$apiBase/apitables/updateTableTitle';
String apiUpdateTableStartTimeUrl = '$apiBase/apitables/updateTableStarTime';

String apiLoadUserFromQrCodeUrl = '$apiBase/apiusers/loadUserFromQrNo';

String apiLoadTableDetailUrl = '$apiBase/apitables/loadTableDetail';
String apiUpdateTableStatusUrl = '$apiBase/apitables/updateTableStatus';

String apiDeleteTableMenuUrl = '$apiBase/apitables/deleteTableMenu';

String apiLoadOrderMenusUrl = '$apiBase/apimenus/loadOrderMenus';
String apiRegReserveMenusUrl = '$apiBase/apimenus/registerReserveMenus';

String apiLoadMenuListUrl = '$apiBase/apimenus/loadMenuList';
String apiLoadMenuDetailUrl = '$apiBase/apimenus/loadMenuDetail';
String apiLoadMenuOrgansUrl = '$apiBase/apimenus/loadMenuOrgans';
String apiSaveMenuUrl = '$apiBase/apimenus/saveMenu';
String apiDeleteMenuUrl = '$apiBase/apimenus/deleteMenu';
String apiLoadMenuVariationUrl = '$apiBase/apimenus/loadMenuVariationRecord';
String apiLoadMenuVariationListUrl = '$apiBase/apimenus/loadMenuVariations';

String apiSaveMenuVariationUrl = '$apiBase/apimenus/saveMenuVariation';
String apiDeleteMenuVariationUrl = '$apiBase/apimenus/deleteMenuVariation';

String apiLoadCompanyStaffListUrl = '$apiBase/apistaffs/loadStaffCompanyList';
String apiLoadStaffInfoUrl = '$apiBase/apistaffs/loadStaffInfo';
String apiSaveStaffInfoUrl = '$apiBase/apistaffs/saveStaffInfo';
String apiLoadStaffPointUrl = '$apiBase/apistaffs/loadStaffPoint';
String apiSaveStaffPointUrl = '$apiBase/apistaffs/saveStaffPoint';
String apiSavePointAddUrl = '$apiBase/apistaffs/savePointAdd';
String apiDeletePointAddUrl = '$apiBase/apistaffs/deletePointAdd';
String apiDeleteStaffInfoUrl = '$apiBase/apistaffs/deleteStaffInfo';
String apiStaffUploadAvatorUrl = '$apiBase/apistaffs/uploadPicture';
String apiStaffAddpointSubmitUrl = '$apiBase/apistaffs/submitAddPoint';

String apiLoadSumSalesUrl = '$apiBase/apisums/loadSumSales';
String apiLoadSumSaleDetailUrl = '$apiBase/apisums/loadSumSaleDetail';
String apiLoadSumSaleItemUrl = '$apiBase/apisums/loadSumSaleItem';
String apiDeleteSumSaleUrl = '$apiBase/apisums/deleteSale';

String apiLoadSettingUrl = '$apiBase/apisettings/loadOrganSetting';
String apiSaveSettingUrl = '$apiBase/apisettings/saveOrganSetting';
String apiUploadPrintLogoUrl = '$apiBase/apisettings/uploadPrintPicture';
String apiUpdateOrganTitleUrl = '$apiBase/apisettings/updateOrganTitle';
String apiPrintLogoUrl = '$apiBase/assets/images/prints/';

String apiLoadOrganTimesUrl = '$apiBase/apiorgans/loadOrganTimes';
String apiDeleteOrganTimeUrl = '$apiBase/apiorgans/deleteOrganTime';

String apiLoadOrganShiftTimesUrl = '$apiBase/apiorgans/loadOrganShiftTimes';
String apiSaveOrganShiftTimeUrl = '$apiBase/apiorgans/saveOrganShiftTime';
String apiDeleteOrganShiftTimeUrl = '$apiBase/apiorgans/deleteOrganShiftTime';

String apiLoadOrganListUrl = '$apiBase/apiorgans/loadOrganList';
String apiLoadOrganByStaffIdUrl = '$apiBase/apiorgans/loadOrganListByStaff';
String apiLoadOrganEditUrl = '$apiBase/apiorgans/loadOrganInfo';
String apiSaveOrganUrl = '$apiBase/apiorgans/saveOrgan';
String apiDeleteOrganUrl = '$apiBase/apiorgans/deleteOrgan';
String apiCreateOrganBossUrl = '$apiBase/apiorgans/createBossAccount';
String apiDeleteOrganBossUrl = '$apiBase/apiorgans/deleteBossAccount';

String apiLoadCompanyData = '$apiBase/apicompanies/loadCompanyData';
String apiSaveCompanyData = '$apiBase/apicompanies/saveCompany';
String apiSaveOrganData = '$apiBase/apicompanies/saveOrgan';
String apiDeleteOrganData = '$apiBase/apicompanies/deleteOrgan';
String apiDeleteCompanyData = '$apiBase/apicompanies/deleteCompany';

String apiLoadInitShiftStaus = '$apiBase/apishiftsettings/loadStatus';
// String apiSaveInitShift = '$apiBase/apishiftsettings/saveShift';
String apiCopyShiftCountUrl = '$apiBase/apishiftsettings/copyShiftCounts';
String apiDeleteInitShift = '$apiBase/apishiftsettings/deleteShift';
String apiLoadShiftOtherOrganExistUrl =
    '$apiBase/apishifts/loadOtherOrganExist';
String apiLoadReserveStaffsUrl = '$apiBase/apireserves/loadReserveStaff';
String apiSaveShiftCompleteUrl = '$apiBase/apishifts/saveShiftComplete';

String apiLoadCountShift = '$apiBase/apishiftsettings/loadShiftCount';
String apiLoadCountShiftStatus =
    '$apiBase/apishiftsettings/loadCountShiftStatus';
String apiSaveCountShift = '$apiBase/apishiftsettings/saveShiftCount';
String apiDeleteCountShift = '$apiBase/apishiftsettings/deleteShiftCount';

String apiLoadShiftStatus = '$apiBase/apishifts/loadShiftStatus';
String apiSubmitShiftStatus = '$apiBase/apishifts/submitShift';
String apiActionShiftStatus = '$apiBase/apishifts/actionStaffShift';
String apiDeleteShift = '$apiBase/apishifts/deleteShift';

String apiLoadShiftStatusManage = '$apiBase/apishifts/loadStaffManageStatus';

String apiRejectReserveDataUrl = '$apiBase/apireserves/rejectReserve';
String apiApplyReserveDataUrl = '$apiBase/apireserves/applyReserve';

//---------------- Admin ------------------------
String adviseVideoUrl = '$apiBase/assets/video/advise/';

String apiLoadAdminHome = '$apiBase/api/loadAdminHome';
String apiLoadConnectHomeMenus = '$apiBase/api/loadConnectHomeMenuSetting';
String apiSaveConnectHomeMenus = '$apiBase/api/saveConnectHomeMenuSetting';

String apiLoadGroupListUrl = '$apiBase/apigroups/loadGroupList';
String apiLoadGroupInfoUrl = '$apiBase/apigroups/loadGroupInfo';
String apiSaveGroupNameUrl = '$apiBase/apigroups/saveGroupName';
String apiLoadUserWithGroupUrl = '$apiBase/apiusers/loadUserWithGroupList';
String apiUpdateUserGroupUrl = '$apiBase/apigroups/updateUserGroup';
String apiLoadUserInGroupUrl = '$apiBase/apiusers/loadUserInGroupList';
String apiLoadUserListUrl = '$apiBase/apiusers/loadUserList';
String apiLoadUserInfoUrl = '$apiBase/apiusers/loadUserInfo';
String apiSaveUserInfoUrl = '$apiBase/apiusers/saveUserInfo';

String apiSaveOrgan = '$apiBase/apiorgans/saveOrgan';
String apiLoadOrganInfo = '$apiBase/apiorgans/loadOrganInfo';
String apiDeleteOrgan = '$apiBase/apiorgans/deleteOrgan';
String apiUploadOrganPhoto = '$apiBase/apiorgans/uploadPicture';

String apiLoadAdminMenuListUrl = '$apiBase/apimenus/loadAdminMenuList';
String apiSaveAdminMenuUrl = '$apiBase/apimenus/saveAdminMenu';
String apiLoadAdminMenuInfoUrl = '$apiBase/apimenus/loadAdminMenuInfo';
String apiDeleteAdminMenuUrl = '$apiBase/apimenus/deleteAdminMenu';
String apiUploadMenuPhoto = '$apiBase/apimenus/uploadPicture';

String apiLoadMessagesUrl = '$apiBase/apimessages/loadMessages';
String apiLoadMessageUserListUrl = '$apiBase/apimessages/loadMessageUserList';
String apiUploadMessageAttachFileUrl = '$apiBase/apimessages/uploadAttachment';
// String apiUploadMessageVideoFileUrl = '$apiBase/apimessages/uploadMessageVideo';

String apiLoadCouponInfoUrl = '$apiBase/apicoupons/loadCouponInfo';
String apiSaveCouponUrl = '$apiBase/apicoupons/saveCoupon';
String apiSaveUserCouponUrl = '$apiBase/apicoupons/saveUserCoupons';

// String apiLoadTeacherListUrl = '$apiBase/apiteachers/loadTeacherList';
String apiSaveTeacherUrl = '$apiBase/apiteachers/saveTeacher';
String apiLoadAdviseListUrl = '$apiBase/apiadvises/loadAdviseList';
String apiLoadAdviseInfoUrl = '$apiBase/apiadvises/loadAdviseInfo';
String apiSaveAdviseInfoUrl = '$apiBase/apiadvises/saveAdviseInfo';
String apiUploadAdviseVideo = '$apiBase/apiadvises/uploadVideo';
String apiLoadReserveList = '$apiBase/apireserves/loadReserveList';
String apiLoadFavortieQuestionUrl =
    '$apiBase/apiquestions/loadFavoriteQuestions';
String apiSaveFavortieQuestionUrl =
    '$apiBase/apiquestions/saveFavoriteQuestion';
String apiLoadQuestionUrl = '$apiBase/apiquestions/loadQuestions';
String apiDeleteReserve = '$apiBase/apireserves/deleteReserve';
String apiLoadPaySlipsUrl = '$apiBase/apipayslips/loadPaySlips';

String apiLoadInitShift = '$apiBase/apishiftsettings/loadInitShifts';
String apiSaveInitShift = '$apiBase/apishiftsettings/saveInitShift';
String apiLoadShiftsUrl = '$apiBase/apishifts/loadShifts';
String apiLoadShiftCountsUrl = '$apiBase/apishifts/loadShiftCounts';
String apiInitShiftUrl = '$apiBase/apis/shift/shifts/applyInitShift';
String apiSaveShiftUrl = '$apiBase/apishifts/saveShift';
String apiLoadShiftManage = '$apiBase/apishifts/loadShiftManage';
String apiUpdateShiftChange = '$apiBase/apishifts/updateShiftChange';
String apiAutoControlShift = '$apiBase/apishifts/autoControlShift';

String apiLoadReserves = '$apiBase/apireserves/loadReserves';

String apiLoadTableTitle = '$apiBase/apiorders/loadTableTitle';
String apiUpdateTableTitle = '$apiBase/apiorders/updateTableTitle';

String apiLoadOrderList = '$apiBase/apiorders/loadOrderList';
String apiLoadOrderUserIds = '$apiBase/apiorders/loadOrderUserIds';

String apiLoadOrganTables = '$apiBase/apiorders/loadOrganTables';
String apiLoadCurrentOrganTables = '$apiBase/apiorders/loadCurrentOrganTables';
String apiAcceptCurrentOrder = '$apiBase/apiorders/acceptOrderRequest';
String apiLoadOrderInfo = '$apiBase/apiorders/loadOrderInfo';
String apiAddOrder = '$apiBase/apiorders/addOrder';
String apiExitOrder = '$apiBase/apiorders/exitOrder';
String apiResetOrder = '$apiBase/apiorders/resetOrder';
String apiUpdateOrder = '$apiBase/apiorders/updateOrder';
String apiApplyReserveOrder = '$apiBase/apiorders/applyReserveOrder';
String apiRejectOrder = '$apiBase/apiorders/rejectOrder';
String apiSaveOrderMenus = '$apiBase/apiorders/saveOrderMenus';
String apiDeleteOrder = '$apiBase/apiorders/deleteOrder';
String apiDeleteOrderMenu = '$apiBase/apiorders/deleteOrderMenu';

String apiLoadMasterPointSpecialPeriodSetting =
    '$apiBase/apis/master/point/getSpecialPeriodRatesByOrgan';
String apiSaveMasterPointSpecialPeriodSetting =
    '$apiBase/apis/master/point/saveSpecialPointRateSetting';
String apiDeleteMasterPointSpecialPeriodSetting =
    '$apiBase/apis/master/point/deleteSpecialPointRateSetting';
String apiLoadMasterPointSpeicalLimits = '$apiMaster/point/getSpecialLimits';
String apiSaveMasterPointSpeicalLimits = '$apiMaster/point/saveSpecialLimit';
String apiDeleteMasterPointSpeicalLimit = '$apiMaster/point/deleteSpecialLimit';

//----------------------new.shift----------------------------------------
String apiLoadShiftInit = '$apiBase/apis/shift/initShift/load';
String apiGetShiftInit = '$apiBase/apis/shift/initShift/getFromSelDate';

//-----------------------attend-------------------------------------------
String apiGetAttendStatus = '$apiBase/apis/attend/loadAttendOrgan';
String apiUpdateAttend = '$apiBase/apis/attend/updateAttend';

String apiLoadSlipsUrl = '$apiBase/apis/slip/loadPaySlipMonth';

//------------------------shift--------------------------------------------

String apiShiftSaveStaffInput = '$apiBase/apis/shift/shifts/saveStaffInput';
String apiShiftLoadManage = '$apiBase/apis/shift/managements/loadInit';
String apiShiftLoadManagePsg = '$apiBase/apis/shift/managements/loadInitPsg';
String apiShiftSaveShiftManage =
    '$apiBase/apis/shift/managements/saveShiftManage';

String apiGetBadgeCount = '$apiBase/apis/notification/loadBadgeCounts';
