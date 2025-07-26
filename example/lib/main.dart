import 'package:easy_thermal_print/easy_thermal_print.dart';
import 'package:elbe/elbe.dart';

void main() {
  runApp(const App());
}

final router = GoRouter(
  routes: [GoRoute(path: '/', builder: (context, _) => const HomePage())],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) =>
      ElbeApp(debugShowCheckedModeBanner: false, router: router);
}

final GlobalKey containerKey = GlobalKey();
final bluetoothService = BluetoothPrintersService(
  printers: [...phomemoPrinters],
);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      title: "Easy Thermal Print Demo",
      children:
          [
            StreamBuilder(
              stream: bluetoothService.connectedPrinters,
              builder:
                  (context, devs) => Column(
                    children: [
                      for (final printer in devs.data ?? <ThermalPrinter>[])
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children:
                                [
                                  Text.h5(printer.model.deviceName),
                                  Text(printer.deviceId),
                                  Button.minor(
                                    label: "Print Widget",
                                    onTap: () async {
                                      await printer.printWidget(
                                        containerKey,
                                        PrintConfig(
                                          halfTones: true,
                                          labelSize: Size(double.infinity, 12),
                                        ),
                                      );
                                    },
                                  ),
                                  PrintedViewer(printer: printer),
                                ].spaced(),
                          ),
                        ),
                    ],
                  ),
            ),
            Button.major(
              label: "Scan for Printers",
              onTap: () => bluetoothService.discover(),
            ),

            Button.minor(
              label: "Disconnect All",
              onTap: () => bluetoothService.disconnectAll(),
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  border: WBorder.all(color: Colors.green, width: 1),
                ),
                child: Printable(
                  key: containerKey,
                  child: Container(
                    margin: EdgeInsets.only(right: 30, bottom: 0),
                    padding: EdgeInsets.all(3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("☺️🚂📚🎉"),
                        Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            border: WBorder.all(color: Colors.black, width: 3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ].spaced(),
    );
  }
}
