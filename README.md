# FE NCKH (Flutter App)

Ung dung Flutter cho phep tim cong thuc, quet nguyen lieu, xem chi tiet mon an va luu pantry.

## 1) Yeu cau moi truong

- Flutter SDK phu hop voi Dart `^3.11.1`
- Android Studio hoac VS Code + Flutter extension
- Android emulator hoac thiet bi that

## 2) Cai dat

```bash
cd fe_nckh
flutter pub get
```

## 3) Ket noi backend local

Backend mac dinh chay o `http://127.0.0.1:5000`.

Neu chay tren Android emulator, can map cong:

```bash
adb reverse tcp:5000 tcp:5000
```

## 4) Chay app

```bash
cd fe_nckh
flutter run --dart-define API_BASE_URL=http://127.0.0.1:5000
```

Neu khong truyen `--dart-define`, app se dung base URL mac dinh trong code.

## 5) Build release (tuy chon)

```bash
flutter build apk --dart-define API_BASE_URL=http://127.0.0.1:5000
```

## 6) Cac man hinh chinh

- Home: goi y nguyen lieu + cong thuc
- Scan: quet anh de nhan dang nguyen lieu
- Recipe: danh sach cong thuc va loc theo keyword/nguyen lieu
- Detail Recipe: thong tin chi tiet mon an + step nau

## 7) Thu muc quan trong

- [fe_nckh/lib/screens](fe_nckh/lib/screens): man hinh UI
- [fe_nckh/lib/services](fe_nckh/lib/services): API service
- [fe_nckh/lib/routes/routes.dart](fe_nckh/lib/routes/routes.dart): dinh tuyen GoRouter
