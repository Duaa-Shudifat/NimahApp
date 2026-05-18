class AppStrings {
  static bool isArabic = false;

  //  Auth
  static String get login => isArabic ? "تسجيل الدخول" : "Login";
  static String get signUp => isArabic ? "إنشاء حساب" : "Sign Up";
  static String get email => isArabic ? "البريد الإلكتروني" : "Email";
  static String get password => isArabic ? "كلمة المرور" : "Password";
  static String get confirmPassword =>
      isArabic ? "تأكيد كلمة المرور" : "Confirm Password";
  static String get phone => isArabic ? "رقم الهاتف" : "Phone Number";

  //  Profile / Form
  static String get city => isArabic ? "المدينة" : "City";
  static String get role => isArabic ? "الدور" : "Role";

  //  Login screen
  static String get welcomeBack =>
      isArabic ? "مرحباً بعودتك! الرجاء تسجيل الدخول" : "Welcome back! Please login to continue";

  static String get forgetPassword =>
      isArabic ? "نسيت كلمة المرور؟" : "Forget Password?";

  static String get dontHaveAccount =>
      isArabic ? "ليس لديك حساب؟" : "Don’t have an account?";

  //  Buttons
  static String get next => isArabic ? "التالي" : "Next";
  static String get getStarted3 => isArabic ? "ابدأ الآن" : "Get Started";
  static String get loginBtn => isArabic ? "دخول" : "Login";
  static String get signUpBtn => isArabic ? "تسجيل" : "Sign Up";

  //  Launch
  static String get loginBig => isArabic ? "دخول" : "Login";
  static String get signUpBig => isArabic ? "إنشاء حساب" : "Sign Up";

  //  Onboarding A
  static String get orderFood1 =>
      isArabic ? "اطلب طعامك" : "Order For Food";

  static String get orderDesc1 => isArabic
      ? "توصيل وجباتك المفضلة بسرعة وطازجة إلى بابك"
      : "Your favorite meals delivered fast and fresh to your door";

  //  Onboarding B
  static String get easyPayment1 =>
      isArabic ? "الدفع السهل" : "Easy Payment";

  static String get easyPaymentDesc1 => isArabic
      ? "ادفع بسرعة وأمان ببضع نقرات فقط"
      : "Pay quickly and securely with just a few taps";

  //  Onboarding C
  static String get fastDelivery3 =>
      isArabic ? "توصيل سريع" : "Fast Delivery";

  static String get fastDeliveryDesc3 => isArabic
      ? "احصل على طلبك خلال وقت قياسي"
      : "Get your order delivered in no time";

  //  Signup screen
  static String get newAccount =>
      isArabic ? "حساب جديد" : "New Account";

  static String get createAccountDesc1 =>
      isArabic ? "أنشئ حساب جديد للبدء" : "Create a new account to get started";

  static String get selectCity =>
      isArabic ? "اختر المدينة" : "Select City";

  static String get selectRole =>
      isArabic ? "اختر الدور" : "Select Role";



  static String get selectRoleError =>
      isArabic ? "الرجاء اختيار الدور" : "Please select a role";

//CITY
  static String get amman => isArabic ? "عمان" : "Amman";
  static String get irbid => isArabic ? "إربد" : "Irbid";
  static String get zarqa => isArabic ? "الزرقاء" : "Zarqa";
  static String get balqa => isArabic ? "البلقاء" : "Balqa";
  static String get mafraq => isArabic ? "المفرق" : "Mafraq";
  static String get jerash => isArabic ? "جرش" : "Jerash";
  static String get ajloun => isArabic ? "عجلون" : "Ajloun";
  static String get madaba => isArabic ? "مادبا" : "Madaba";
  static String get karak => isArabic ? "الكرك" : "Karak";
  static String get tafila => isArabic ? "الطفيلة" : "Tafilah";
  static String get maan => isArabic ? "معان" : "Ma'an";
  static String get aqaba => isArabic ? "العقبة" : "Aqaba";
//ROLE
  static String get customer => isArabic ? "مستخدم" : "Customer";
  static String get provider => isArabic ? "مزود خدمة" : "Provider";
  static String get driver => isArabic ? "سائق" : "Driver";

//FORGET_PASSWORD
  static String get sendBtn => isArabic ? "إرسال" : "Send";
  static String get forgetPasswordTitle =>
      isArabic ? "نسيت كلمة المرور" : "Forget Password";
  static String get forgetPasswordDesc =>
      isArabic
          ? "أدخل بريدك الإلكتروني لإرسال رابط إعادة التعيين"
          : "Enter your email to receive a reset link";
  static String get emailSentMsg =>
      isArabic
          ? "تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني"
          : "Reset link sent to your email";

  // PHONE VALIDATION
  static String get phoneRequired =>
      isArabic ? "رقم الهاتف مطلوب" : "Phone is required";

  static String get phoneInvalid =>
      isArabic ? "رقم الهاتف ينبغي أن يبدأ بـ +962" : "Phone should start with +962";

  static String get phoneLengthInvalid =>
      isArabic ? "رقم الهاتف ينبغي أن يكون 13 رقم" : "Phone should be 13 digits";

// PASSWORD VALIDATION
  static String get passwordRequired =>
      isArabic ? "كلمة المرور مطلوبة" : "Password is required";

  static String get passwordWeak =>
      isArabic
          ? "كلمة المرور 8 أحرف على الأقل وتحتوي حروف + أرقام + رمز"
          : "Password should be 8+ chars with letters, numbers & symbol";

// SUCCESS
  static String get accountCreated =>
      isArabic ? "تم إنشاء الحساب بنجاح" : "Account created successfully";
  // PHONE PREFIX
  static String get phoneCode =>
      isArabic ? "+٩٦٢" : "+962";

  static String get passwordLengthError =>
      isArabic ? "كلمة المرور ينبغي 8 أحرف على الأقل" : "Password should be at least 8 characters";

  static String get passwordComplexityError =>
      isArabic ? "ينبغي تحتوي حرف كبير وصغير ورقم ورمز" : "Should contain upper, lower, number & symbol";

  // HOME SCREEN
  static String get search =>
      isArabic ? "بحث" : "Search";

  static String get goodMorning =>
      isArabic ? "صباح الخير" : "Good Morning";

  static String get breakfastTime =>
      isArabic ? "انه وقت الإفطار" : "Rise And Shine! It's Breakfast Time";

  static String get bestSeller =>
      isArabic ? "الأكثر مبيعاً" : "Best Seller";

  static String get recommended =>
      isArabic ? "مقترح لك" : "Recommended";
  static String get meals =>
      isArabic ? "وجبات" : "Meals";

  static String get freshProduce =>
      isArabic ? "خضار وفواكه" : "Fresh Produce";

  static String get bakeryProducts =>
      isArabic ? "مخبوزات" : "Bakery Products";

  static String get Store =>
      isArabic ? "مخازن" : "Store";

  // ================= PROFILE =================

  static String get myOrders =>
      isArabic ? "طلباتي" : "My Orders";

  static String get myProfile =>
      isArabic ? "ملفي الشخصي" : "My Profile";

  static String get deliveryAddress =>
      isArabic ? "عنوان التوصيل" : "Delivery Address";

  static String get paymentMethods =>
      isArabic ? "طرق الدفع" : "Payment Methods";

  static String get contactUs =>
      isArabic ? "تواصل معنا" : "Contact Us";

  static String get helpFaq =>
      isArabic ? "المساعدة والأسئلة" : "Help & FAQs";

  static String get settings =>
      isArabic ? "الإعدادات" : "Settings";

  static String get logout =>
      isArabic ? "تسجيل الخروج" : "Log Out";

  static String get active => isArabic ? "نشطة" : "Active";
  static String get completed => isArabic ? "مكتملة" : "Completed";
  static String get canceled => isArabic ? "ملغية" : "Canceled";

  static String get noActiveOrders =>
      isArabic
          ? "ليس لديك أي طلبات نشطة في الوقت الحالي"
          : "You don’t have any active orders at this time";

  static String get AdminDashboard => isArabic ? "Admin Dashboard" : "لوحة تحكم المسؤول";

  static String get users => isArabic ? "المستخدمون" : "Users";
  static String get orders => isArabic ? "الطلبات" : "Orders";
  static String get completedLabel => isArabic ? "مكتملة" : "Completed";
  static String get cancelledLabel => isArabic ? "ملغية" : "Cancelled";
  static String get revenue => isArabic ? "الإيرادات" : "Revenue";
  static String get currency => isArabic ? "دينار" : "JD";
  static String get blockedUsersTitle => isArabic ? "المستخدمون المحظورون" : "Blocked Users";
  static String get usersLabel => isArabic ? "مستخدمين" : "Users";
  static String get providersLabel => isArabic ? "مزودين" : "Providers";
  static String get driversLabel => isArabic ? "سائقين" : "Drivers";

  static String get driversTitle => isArabic ? "إدارة السائقين" : "Drivers Management";
  static String get driverName => isArabic ? "اسم السائق" : "Driver Name";
  static String get driverCar => isArabic ? "نوع السيارة" : "Car Type";
  static String get driverGov => isArabic ? "المحافظة" : "Governorate";
  static String get driverStatus => isArabic ? "الحالة" : "Status";
  static String get pendingStatus => isArabic ? "قيد الانتظار" : "Pending";
  static String get approvedStatus => isArabic ? "مقبول" : "Approved";
  static String get blockedStatus => isArabic ? "محظور" : "Blocked";
  static String get activeStatus => isArabic ? "نشط" : "Active";
  static String get acceptLabel => isArabic ? "قبول" : "Accept";
  static String get rejectLabel => isArabic ? "رفض" : "Reject";
  static String get blockLabel => isArabic ? "حظر" : "Block";
  static String get unblockLabel => isArabic ? "إلغاء الحظر" : "Unblock";

  static String get ratingLabel => isArabic ? "التقييم" : "Rating";
  static String get feedbackTitle => isArabic ? "آراء العملاء" : "Customer Feedback";


  static String get feedbackComment1 => isArabic ? "خدمة رائعة! توصيل سريع ونظيف جداً." : "Great service! Very fast and clean delivery.";
  static String get feedbackComment2 => isArabic ? "الطعام كان دافئاً ولذيذاً، شكراً!" : "Food was warm and tasty, thanks!";
  static String get feedbackComment3 => isArabic ? "جيد ولكن يمكن تحسين التغليف." : "Good but packaging can improve.";
  static String get customerPhoneLabel => isArabic ? "رقم الزبون" : "Customer Phone";
  static String get driverPhoneLabel => isArabic ? "رقم السائق" : "Driver Phone";
  static String get restaurantLabel => isArabic ? "المطعم" : "Restaurant";
  static String get locationLabel => isArabic ? "الموقع" : "Location";
  static String get timeLabel => isArabic ? "الوقت" : "Time";
  static String get approvedOrdersTab => isArabic ? "الطلبات المقبولة" : "Approved Orders";
  static String get canceledOrdersTab => isArabic ? "الطلبات الملغية" : "Canceled Orders";
  static String get ordersDashboard => isArabic ? "لوحة تحكم الطلبات" : "Orders Dashboard";

  static String get usersAnalytics => isArabic ? "تحليلات المستخدمين" : "Users Analytics";
  static String get fillFieldsError => isArabic ? "الرجاء تعبئة جميع الحقول" : "Please fill all fields";
// Firebase Auth Errors
  static String get userNotFound => isArabic ? "لا يوجد حساب بهذا البريد" : "No user found with this email";
  static String get wrongPassword => isArabic ? "كلمة المرور غير صحيحة" : "Wrong password";
  static String get invalidEmail => isArabic ? "صيغة البريد الإلكتروني غير صحيحة" : "Invalid email format";
  static String get invalidCredential => isArabic ? "خطأ في البريد الإلكتروني أو كلمة المرور" : "Wrong email or password";
  static String get accountNotFoundSignUp => isArabic ? "الحساب غير موجود، الرجاء إنشاء حساب" : "Account not found. Please sign up.";
  static String get generalError => isArabic ? "حدث خطأ ما، حاول مرة أخرى" : "An error occurred";

  static String get passwordsNotMatch => isArabic ? "كلمتا المرور غير متطابقتين" : "Passwords do not match";
  static String get selectVehicleError => isArabic ? "الرجاء اختيار نوع المركبة" : "Please select vehicle type";
  static String get uploadLogoError => isArabic ? "الرجاء رفع شعار المتجر" : "Please upload a logo";
  static String get nameError => isArabic ? "يجب أن يكون الاسم بين 3-30 حرفاً (بدون أرقام)" : "Name must be 3-30 letters only (no numbers)";
  static String get phoneAlreadyExists => isArabic ? "رقم الهاتف مسجل مسبقاً" : "Phone number already registered";
  static String get emailAlreadyInUse => isArabic ? "هذا البريد الإلكتروني مسجل مسبقاً" : "Email already registered";
  static String get weakPassword => isArabic ? "كلمة المرور ضعيفة جداً" : "Password is too weak";
  static String get name => isArabic ? "الاسم" : "Name";
  static String get vehicleType => isArabic ? "نوع المركبة" : "Vehicle Type";
  static String get car => isArabic ? "سيارة" : "Car";
  static String get bike => isArabic ? "دراجة هوائية" : "Bike";
  static String get scooter => isArabic ? "سكوتر" : "Scooter";
  static String get motorcycle => isArabic ? "دراجة نارية" : "Motorcycle";
  static String get uploadLogo => isArabic ? "رفع الشعار" : "Upload Logo";
  static String get imageSelected => isArabic ? "✅ تم اختيار الصورة" : "✅ Image Selected";
  static String get phoneVerified => isArabic ? "تم التحقق من الهاتف ✅" : "Phone Verified ✅";
  static String get invalidCode => isArabic ? "الكود غير صحيح ❌" : "Invalid code ❌";
  static String get enterOTP => isArabic ? "أدخل رمز التحقق" : "Enter OTP";
  static String get codeSentTo => isArabic ? "تم إرسال الرمز إلى " : "Code sent to ";
  static String get verifyBtn => isArabic ? "تحقق" : "Verify";
  static String get enterFullCodeError => isArabic ? "الرجاء إدخال الكود كاملاً" : "Please enter the full code";
  static String get emailVerified => isArabic ? "تم التحقق من البريد الإلكتروني ✅" : "Email Verified ✅";
  static String get wrongOTP => isArabic ? "رمز التحقق غير صحيح ❌" : "Wrong OTP ❌";
  static String get verifyEmailTitle => isArabic ? "التحقق من البريد الإلكتروني" : "Verify Email";
  static String get checkEmail => isArabic ? "يرجى التحقق من بريدك الإلكتروني" : "Check your email";
  static String get codeSentMessage => isArabic ? "لقد أرسلنا رمزاً مكوناً من 6 أرقام إلى بريدك الإلكتروني" : "We sent a 6-digit code to your email";
  static String get emailEmptyError => isArabic ? "الرجاء إدخال البريد الإلكتروني" : "Please enter your email";
  static String get invalidEmailError => isArabic ? "صيغة البريد الإلكتروني غير صحيحة" : "Invalid email format";
  static String get otpSendFailed => isArabic ? "فشل إرسال رمز التحقق، حاول مرة أخرى" : "Failed to send OTP, try again";
  static String get enterEmailHint => isArabic ? "أدخل عنوان بريدك الإلكتروني" : "Enter your email address";
  static String sentCodeMessage(String email) => isArabic
      ? "لقد أرسلنا رمزاً مكوناً من 6 أرقام إلى\n$email"
      : "We sent a 6-digit code to\n$email";
  static String get resetLinkSent => isArabic ? "تم إرسال رابط إعادة التعيين ✅" : "Reset link sent ✅";
  static String get resetPasswordTitle => isArabic ? "إعادة تعيين كلمة المرور" : "Reset Password";
  static String resetInstructionMessage(String email) => isArabic
      ? "لقد أرسلنا رابط إعادة تعيين كلمة المرور إلى:\n$email\n\nافتح الرابط المرسل لتعيين كلمة مرورك الجديدة."
      : "We sent a password reset link to:\n$email\n\nOpen the link in your email to set your new password.";
  static String get resendLinkBtn => isArabic ? "إعادة إرسال الرابط" : "Resend Link";
  static String get goToLoginBtn => isArabic ? "العودة لتسجيل الدخول" : "Go to Login";


  static String get noFavorites => isArabic ? "لا توجد مفضلات بعد" : "No favorites yet";
  static String get cartLabel => isArabic ? "السلة" : "Cart";
  static String get notificationsLabel => isArabic ? "التنبيهات" : "Notifications";
  static String get profileLabel => isArabic ? "الملف الشخصي" : "Profile";

  // العناوين
  static String get burgerMeal => isArabic ? "وجبة برجر" : "Burger Meal";
  static String get pizzaMeal => isArabic ? "وجبة بيتزا" : "Pizza Meal";
  static String get saladMeal => isArabic ? "وجبة سلطة" : "Salad Meal";

// الحالات
  static String get statusActive => isArabic ? "نشط" : "Active";
  static String get statusCompleted => isArabic ? "مكتمل" : "Completed";

// التفاصيل (بما أن فيها أرقام وعملة JD)
  static String orderDetails(int items, int price) => isArabic
      ? "$items عناصر • $price دينار"
      : "$items items • $price JD";
  static String get tabActive => isArabic ? "النشطة" : "Active";
  static String get tabCompleted => isArabic ? "المكتملة" : "Completed";
  static String get tabCanceled => isArabic ? "الملغاة" : "Canceled";
  static String get cancelReason => isArabic ? "السبب: " : "Reason: ";
  static String get cancelBtn => isArabic ? "إلغاء" : "Cancel";
  static String get reasonChangedMind => isArabic ? "غيرت رأيي" : "Changed my mind";
  static String get reasonMistake => isArabic ? "طلبت عن طريق الخطأ" : "Ordered by mistake";
  static String get reasonTooLate => isArabic ? "التوصيل متأخر جداً" : "Too late delivery";
  static String get reasonOther => isArabic ? "أسباب أخرى" : "Other";
  static String get cancelOrderTitle => isArabic ? "إلغاء الطلب" : "Cancel Order";
  static String get orderCanceledMsg => isArabic ? "تم إلغاء الطلب" : "Order Canceled";
  static String get cancelSuccessDesc => isArabic
      ? "تم إلغاء طلبك بنجاح."
      : "Your order has been successfully canceled.";
  static String get okBtn => isArabic ? "حسناً" : "OK";
  static String get cartBarrierLabel => isArabic ? "سلة التسوق" : "Cart";
  static String get mealDetails => isArabic ? "تفاصيل الوجبة" : "Meal Details";
  static String availableQtyText(String qty) => isArabic
      ? "المتوفر: $qty"
      : "Available: $qty";
  static String get mealDescription => isArabic
      ? "وجبة طازجة وشهية محضرّة بمكونات عالية الجودة. تم إعدادها بعناية لتمنحك أفضل تجربة تذوق."
      : "Fresh and delicious meal made with high quality ingredients. Prepared carefully to give you the best taste experience.";
  static String get addedToCart => isArabic ? "تمت الإضافة إلى السلة" : "Added to cart";

  static String addToCartWithQty(int qty) => isArabic
      ? "أضف إلى السلة ($qty)"
      : "Add to Cart ($qty)";
  static String get favoritesTitle => isArabic ? "المفضلة" : "Favorites";
  static String get chooseMealTitle => isArabic ? "اختر وجبتك المفضلة" : "Choose your favorite meal";
  static String get restaurantsTitle => isArabic ? "المطاعم" : "Restaurants";
  static String get chooseRestaurantTitle => isArabic ? "اختر مطعمك المفضل" : "Choose your favorite restaurant";
  static String get selectLanguage => isArabic ? "اختر اللغة" : "Select Language";
  static String get settingsTitle => isArabic ? "الإعدادات" : "Settings";
  static String get notificationSettings => isArabic ? "إعدادات التنبيهات" : "Notification Setting";
  static String get passwordSettings => isArabic ? "إعدادات كلمة المرور" : "Password Setting";
  static String get language => isArabic ? "اللغة" : "Language";
  static String get deleteAccount => isArabic ? "حذف الحساب" : "Delete Account";
  static String get myOrdersTitle => isArabic ? "طلباتي" : "My Orders";
  static String get myProfileTitle => isArabic ? "ملفي الشخصي" : "My Profile";
  static String get userName => isArabic ? "جون سميث" : "John Smith";
  static String get fullNameLabel => isArabic ? "الاسم الكامل" : "Full Name";
  static String get roleLabel => isArabic ? "الدور" : "Role";
  static String get emailLabel => isArabic ? "البريد الإلكتروني" : "Email";
  static String get phoneLabel => isArabic ? "رقم الهاتف" : "Phone Number";
  static String get updateProfile => isArabic ? "تحديث الملف الشخصي" : "Update Profile";
  static String get homeTitle => isArabic ? "المنزل" : "My home";
  static String get officeTitle => isArabic ? "المكتب" : "My Office";
  static String get parentsTitle => isArabic ? "بيت الأهل" : "Parent's House";
  static String get deliveryAddressTitle => isArabic ? "عنوان التوصيل" : "Delivery Address";
  static String get addNewAddress => isArabic ? "إضافة عنوان جديد" : "Add New Address";
  static String get nameLabel => isArabic ? "الاسم" : "Name";
  static String get addressLabel => isArabic ? "العنوان" : "Address";
  static String get applyBtn => isArabic ? "تطبيق" : "Apply";
  static String get paymentMethodsTitle => isArabic ? "طرق الدفع" : "Payment Methods";
  static String get addCardBtn => isArabic ? "إضافة بطاقة" : "Add Card";
  static String get cardHolderLabel => isArabic ? "اسم صاحب البطاقة" : "Card Holder Name";
  static String get cardNumberLabel => isArabic ? "رقم البطاقة" : "Card Number";
  static String get requiredError => isArabic ? "مطلوب" : "Required";
  static String get invalidNumberError => isArabic ? "رقم غير صالح" : "Invalid number";
  static String get expiryLabel => isArabic ? "تاريخ الانتهاء" : "Expiry";
  static String get expiryHint => isArabic ? "شهر/سنة" : "MM/YY";
  static String get cvvLabel => isArabic ? "رمز الأمان (CVV)" : "CVV";
  static String get invalidError => isArabic ? "غير صالح" : "Invalid";
  static String get saveCardBtn => isArabic ? "حفظ البطاقة" : "Save Card";


  static String get customerService => isArabic ? "خدمة العملاء" : "Customer Service";
  static String get website => isArabic ? "الموقع الإلكتروني" : "Website";
  static String get whatsapp => "Whatsapp";
  static String get facebook => "Facebook";
  static String get instagram => "Instagram";
  static String get helpFAQs => isArabic ? "المساعدة والأسئلة الشائعة" : "Help & FAQs";
  // السؤال الأول
  static String get faqQuestion1 => isArabic ? "ما هو هذا التطبيق؟" : "What is this app?";
  static String get faqAnswer1 => isArabic ? "هذا تطبيق لتوصيل الطعام." : "This is a food delivery app.";

// السؤال الثاني
  static String get faqQuestion2 => isArabic ? "كيف يمكنني الطلب؟" : "How to order?";
  static String get faqAnswer2 => isArabic ? "اختر الطعام ثم انتقل للدفع." : "Select food and checkout.";

  static String get faqQuestion3 => isArabic ? "طرق الدفع" : "Payment methods";
  static String get faqAnswer3 => isArabic ? "بطاقة الدفع أو نقداً." : "Card or cash.";
  static String get generalNotification => isArabic ? "الإشعارات العامة" : "General Notification";
  static String get sound => isArabic ? "الصوت" : "Sound";
  static String get soundCall => isArabic ? "صوت المكالمات" : "Sound Call";
  static String get vibrate => isArabic ? "الاهتزاز" : "Vibrate";
  static String get specialOffers => isArabic ? "العروض الخاصة" : "Special Offers";
  static String get currentPassword => isArabic ? "كلمة المرور الحالية" : "Current Password";
  static String get forgotPassword => isArabic ? "نسيت كلمة المرور؟" : "Forgot Password?";
  static String get newPassword => isArabic ? "كلمة المرور الجديدة" : "New Password";
  static String get confirmNewPassword => isArabic ? "تأكيد كلمة المرور الجديدة" : "Confirm New Password";
  static String get changePasswordBtn => isArabic ? "تغيير كلمة المرور" : "Change Password";
  static String get deleteAccountWarning => isArabic
      ? "هذا الإجراء نهائي ولا يمكن التراجع عنه.\nسيتم حذف جميع بياناتك بشكل دائم."
      : "This action is permanent and cannot be undone.\nAll your data will be removed permanently.";
  static String get cancel => isArabic ? "إلغاء" : "Cancel";
  static String get success => isArabic ? "نجاح" : "Success";
  static String get accountDeletedMessage => isArabic
      ? "لقد تم حذف حسابك نهائياً."
      : "Your account has been permanently deleted.";
  static String get ok => isArabic ? "موافق" : "OK";
  static String get delete => isArabic ? "حذف" : "Delete";
  static String get sadToSeeYouGo => isArabic
      ? "يحزننا رؤيتك ترحل!\nهل تريد حقاً حذف حسابك؟"
      : "We are sad to see you go \nDo you really want to delete your account?";
  static String get continueDelete => isArabic ? "الاستمرار في الحذف" : "Continue Delete";
  static String get deleteAccountTitle => isArabic ? "حذف الحساب" : "Delete Account";
  static String get cardHolderName => isArabic ? "جون سميث" : "John Smith";
  static String get myCart => isArabic ? "سلتي" : "My Cart";
  static String get cartEmpty => isArabic ? "سلتك فارغة 🛒" : "Your cart is empty 🛒";
  static String get total => isArabic ? "الإجمالي" : "Total";
  static String get checkout => isArabic ? "إتمام الطلب" : "Checkout";
  static String get home => isArabic ? "المنزل" : "Home";
  static String get cash => isArabic ? "نقداً" : "Cash";
  static String get work => isArabic ? "العمل" : "Work";
  static String get card => isArabic ? "بطاقة" : "Card";
  static String get noteOptional => isArabic ? "ملاحظات (اختياري)" : "Note (Optional)";
  static String get writeNoteHint => isArabic ? "أضف أي تعليمات خاصة هنا..." : "Add any special instructions here...";
  static String get placeOrder => isArabic ? "إتمام الطلب" : "Place Order";
  static String get deliveryTime => isArabic ? "وقت التوصيل" : "Delivery Time";
  static String get shippingAddress => isArabic ? "عنوان الشحن" : "Shipping Address";
  static String get dummyAddress => isArabic
      ? "٧٧٨ شارع العروبة، عمان، الأردن"
      : "778 Locust View Drive Oaklanda, CA";
  static String get estimatedDelivery => isArabic ? "وقت التوصيل المتوقع" : "Estimated Delivery";
  static String get deliveryDuration => isArabic ? "٢٥ دقيقة" : "25 mins";

  // Timeline States
  static String get orderAccepted => isArabic ? "تم قبول طلبك" : "Your order has been accepted";
  static String get preparingOrder => isArabic ? "المطعم يقوم بتجهيز طلبك" : "The restaurant is preparing your order";
  static String get deliveryOnWay => isArabic ? "السائق في طريقه إليك" : "The delivery is on his way";
  static String get orderDelivered => isArabic ? "تم توصيل الطلب بنجاح" : "Your order has been delivered";

// Minutes
  static String mins(String m) => isArabic ? "$m دقيقة" : "$m min";
  static String get orderConfirmed => isArabic ? "تم تأكيد الطلب!" : "Order Confirmed!";
  static String get cashCard => isArabic ? "بطاقة / نقداً" : "Cash / Card";
  static String get selectRatingError => isArabic ? "الرجاء اختيار التقييم أولاً ⭐" : "Please select rating first ⭐";
  static String ratingValue(double rating) => isArabic ? "التقييم: $rating ⭐" : "Rating: $rating ⭐";
  static String get done => isArabic ? "تم" : "Done";
  static String get rateOrderTitle => isArabic ? "قيّم طلبك" : "Rate Your Order";
  static String get experienceQuestion => isArabic ? "كيف كانت تجربتك؟" : "How was your experience?";
  static String get feedbackHint => isArabic ? "اكتب رأيك هنا..." : "Write your feedback...";
  static String get submit => isArabic ? "إرسال" : "Submit";
  // Notifications
  static String get notifOrderReady => isArabic ? "طلبك أصبح جاهزاً" : "Your order is ready";
  static String get notifDeliveryWay => isArabic ? "السائق في الطريق إليك" : "Delivery on the way";
  static String get notifPaymentReceived => isArabic ? "تم استلام الدفعة" : "Payment received";
  static String get notifRateOrder => isArabic ? "تم توصيل الطلب، يرجى التقييم" : "Your Order is Delivered, Please Rate";
  static String get paymentComingSoon => isArabic ? "تفاصيل الدفع ستتوفر قريباً" : "Payment Details Coming Soon";
  static String get notificationsTitle => isArabic ? "الإشعارات" : "Notifications";
  static String get notificationsSubtitle => isArabic ? "آخر التحديثات لديك" : "Your latest updates";
  static String get noNotifications => isArabic ? "لا توجد إشعارات" : "No notifications";
  static String get driverDashboard => isArabic ? "لوحة تحكم السائق" : "Driver Dashboard";
  static String get welcomeCaptain => isArabic ? "أهلاً بك يا كابتن!" : "Welcome, Captain!";
  static String get totalEarnings => isArabic ? "إجمالي الأرباح" : "Total Earnings";
  static String get ratingTitle => isArabic ? "التقييم" : "Rating";
  static String get goToActiveRequests => isArabic ? "الانتقال إلى الطلبات النشطة" : "Go to Active Requests";
  static String get statusPending => isArabic ? "قيد الانتظار" : "Pending";
  static String get statusAccepted => isArabic ? "مقبول" : "Accepted";
  static String get locationIrbid => isArabic ? "إربد - وسط البلد" : "Irbid - Downtown";
  static String get locationAmman => isArabic ? "عمان - العبدلي" : "Amman - Abdali";
  static String get statusPickedUp => isArabic ? "تم الاستلام" : "Picked up";
  static String get statusOnWay => isArabic ? "في الطريق" : "On the way";
  static String get statusDelivered => isArabic ? "تم التوصيل" : "Delivered";
  static String get noOrdersAvailable => isArabic ? "لا توجد طلبات في هذا القسم" : "No orders available in this section";
  static String get tabNew => isArabic ? "جديد" : "New";
  static String get tabMyTasks => isArabic ? "مهامي" : "My Tasks";
  static String get tabHistory => isArabic ? "السجل" : "History";
  static String get labelCustomer => isArabic ? "الزبون" : "Customer";
  static String get errorFinishOrder => isArabic ? "أنهِ طلبك الحالي أولاً!" : "Finish your current order first!";
  static String get btnAcceptView => isArabic ? "قبول وعرض التفاصيل" : "Accept & View Details";
  static String get btnViewDetails => isArabic ? "عرض تفاصيل الطلب" : "View Order Details";
  static String get orderId => isArabic ? "رقم الطلب" : "Order ID";
  static String get customerDetails => isArabic ? "تفاصيل الزبون" : "Customer Details";
  static String get labelName => isArabic ? "الاسم" : "Name";
  static String get labelPhone => isArabic ? "الهاتف" : "Phone";
  static String get orderedItems => isArabic ? "الأصناف المطلوبة" : "Ordered Items";
  static String get btnConfirmPickup => isArabic ? "تأكيد الاستلام من المطعم" : "Confirm Pickup at Restaurant";
  static String get btnStartDriving => isArabic ? "بدء التوجه للزبون" : "Start Driving to Customer";
  static String get btnConfirmDelivered => isArabic ? "تأكيد توصيل الطلب" : "Confirm Order Delivered";
  static String get btnMissionDone => isArabic ? "تمت المهمة بنجاح ✅" : "Mission Accomplished ✅";
  static String get labelDashboard => isArabic ? "الرئيسية" : "Dashboard";
  static String get navOrders => isArabic ? "الطلبات" : "Orders";
  static String get navMenu => isArabic ? "القائمة" : "Menu";
  static String get navProfile => isArabic ? "الملف الشخصي" : "Profile";
  static String get labelNetProfit => isArabic ? "صافي الأرباح" : "Net Profit";
  static String get labelTotalSales => isArabic ? "إجمالي المبيعات" : "Total Sales";
  static String get labelWastedMeals => isArabic ? "وجبات مهدورة (خسارة)" : "Wasted Meals (Loss)";
  static String get labelCompletedOrders => isArabic ? "الطلبات المكتملة" : "Completed Orders";
  static String get labelMealsInMenu => isArabic ? "وجبات القائمة" : "Meals in Menu";
  static String currency1(String amount) => isArabic ? "$amount دينار" : "$amount JD";
  static String get ordersTracking => isArabic ? "تتبع الطلبات" : "Orders Tracking";

  static String get tabOngoing => isArabic ? "قيد التنفيذ" : "Ongoing";
  static String get orderNum => isArabic ? "طلب رقم #" : "Order #";
  static String get orderStatusCompleted => isArabic ? "الحالة: مكتمل" : "Status: Completed";
// دالة لتركيب جملة العناصر والسعر
  static String itemsAndPrice(int count, String price) =>
      isArabic ? "الأصناف: $count وجبات • ${currency1(price)}" : "Items: $count Meals • ${currency1(price)}";
  static String get btnReady => isArabic ? "جاهز" : "Ready";
  static String get btnAddNewMeal => isArabic ? "إضافة وجبة جديدة" : "Add New Meal";
  static String get labelMealName => isArabic ? "اسم الوجبة" : "Meal Name";
  static String get labelPrice => isArabic ? "السعر" : "Price";
  static String get labelAvailableQuantity => isArabic ? "الكمية المتاحة" : "Available Quantity";
  static String get labelDescription => isArabic ? "ملاحظات / الوصف (اختياري)" : "Notes / Description (Optional)";
  static String get msgEnterMealName => isArabic ? "يرجى إدخال اسم الوجبة!" : "Please enter a meal name!";
  static String get msgUploading => isArabic ? "جاري رفع الصورة..." : "Uploading image...";
  static String get msgUploadError => isArabic ? "فشل رفع الصورة، يرجى المحاولة لاحقاً" : "Upload failed, please try again later";
  static String get msgMealAdded => isArabic ? "تم إضافة الوجبة بنجاح!" : "Meal added successfully!";
  static String get btnSaveMeal => isArabic ? "حفظ الوجبة" : "Save Meal";
  static String get btnEditMeal => isArabic ? "تعديل الوجبة" : "Edit Meal";
  static String get msgMealUpdated => isArabic ? "تم تحديث البيانات بنجاح" : "Data updated successfully";
  static String get btnUpdateMeal => isArabic ? "تحديث الوجبة" : "Update Meal";

  // ======= HomePage defaults =======
  static String selectedCity = isArabic ? "جاري التحميل..." : "Loading...";
  static String? sessionCity;


  static String get titleMyMenu => isArabic ? "قائمتي" : "My Menu";
  static String get msgLoginFirst => isArabic ? "يرجى تسجيل الدخول أولاً" : "Please login first";
  static String get labelAddMeal => isArabic ? "إضافة وجبة" : "Add Meal";
  static String get msgProfileUpdated => isArabic ? "تم تحديث صورة الملف الشخصي بنجاح!" : "Profile image updated successfully!";
  static String get titleMyProfile => isArabic ? "ملفي الشخصي" : "My Profile";
  static String get msgNoData => isArabic ? "لم يتم العثور على بيانات" : "No data found";
  static String get labelNotAvailable => isArabic ? "غير متوفر" : "N/A";
  static String get labelEmail => isArabic ? "البريد الإلكتروني" : "Email";
  static String get labelCity => isArabic ? "المدينة" : "City";
  static String get titleProviderDashboard => isArabic ? "لوحة تحكم المزود" : "Provider Dashboard";



}