# Easy Thermal Print

A Flutter package for easy thermal printing. It provides a simple API that lets you print text, or custom widgets to a thermal printer. The package currently supports Bluetooth Low Energy (BLE) printers and is thus compatible with all platforms that support BLE.

### Features

- ✅ Print text and custom widgets to thermal printers.
- ✅ Support for Bluetooth Low Energy (BLE) printers.
- ✅ customizable print settings:
  - Label Size / continuous paper
  - optional half-tone printing (░▒█)
  - Text styling
- ✅ dry run mode for testing without a printer
- ✅ view print output via `PrintedViewer` widget

### Supported Devices

- out-of-the-box support for:
  - [Phomemo](https://www.phomemo.com/) printers
- support for other BLE thermal via config _(feel free to reach out, so we can add it to the included list)_

### Example

_<img src="https://raw.githubusercontent.com/RobinNaumann/easy_thermal_print/main/assets/scs_1.png" style="border-radius: 10px" width="300" alt="Example Screenshot"/>_

### Usage

1. import the package:

   ```sh
   flutter pub add easy_thermal_print
   ```

2. initialize the Bluetooth service and discover devices

   ```dart
   /// create a new instance of the BluetoothService.
   /// provide a list of printers to scan for.
   final bluetoothService = BluetoothPrintersService(
   printers: [...phomemoPrinters],
   );
   ```

   ```dart
   /// ⚠️ make sure the user grants the permissions before scanning
   bluetoothService.discover();
   // devices will appear in: bluetoothService.connectedPrinters
   ```

3. start printing 🎉
   ```dart
   printer.printWidget( // or printText
       containerKey,
       PrintConfig(halfTones: true,labelSize: Size(60, 12)),
   );
   ```
   - make sure to wrap the stuff you want to print in a `Printable` widget

### Required Permissions

##### Android

Add the following permissions to your `AndroidManifest.xml`:

```xml
    ...
    <uses-feature android:name="android.hardware.bluetooth_le" android:required="false" />
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
</manifest>
```

##### iOS / macOS

Add the following keys to your `Release/Debug.entitlements`:

```xml
    ...
    <key>com.apple.security.device.bluetooth</key>
	<true/>
  </dict>
</plist>
```

### Project Acknowledgements:

- [phomemo-tools](https://github.com/vivier/phomemo-tools) for details regarding the printing protocol
- [phomemo](https://pub.dev/packages/phomemo) for the setup for printing widgets to an image

<br><br>
Have a great day,<br>
Yours, Robin

[!["donate"](https://robbb.in/donate/widgets/btn_long_git.png)](https://robbb.in/donate)
