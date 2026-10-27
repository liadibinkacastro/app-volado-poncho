import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const PilloPonchoApp());
}

class PilloPonchoApp extends StatelessWidget {
  const PilloPonchoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VoladoPage(),
    );
  }
}

class VoladoPage extends StatefulWidget {
  const VoladoPage({super.key});
  @override
  State<VoladoPage> createState() => _VoladoPageState();
}

class _VoladoPageState extends State<VoladoPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animacion;
  bool esAguila = true;
  bool girando = false;

  // Color de tu programa original
  final Color colorFondo = const Color(0xFF302702);
  final Color colorBoton = const Color(0xFF551B05);

  // --- SOLO ESTO SE AGREGÓ PARA PAPELITOS ---
  late AnimationController _confettiController;
  List<Particle> confettis = [];
  final rand = Random();
  // --- FIN DE LO AGREGADO ---

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animacion = Tween<double>(begin: 0, end: 1440).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.addListener(() {
      setState(() {});
    });

    // --- SOLO ESTO SE AGREGÓ ---
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    // --- FIN ---

    // lanzar al inicio como en tu tkinter
    WidgetsBinding.instance.addPostFrameCallback((_) => lanzar());
  }
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(const AssetImage('assets/aguila.jpeg'), context);
  precacheImage(const AssetImage('assets/sello.jpeg'), context);
}
  void lanzar() {
    if (girando) return;
    esAguila = Random().nextBool();
    girando = true;
    confettis = []; // limpia papelitos anteriores
    _controller.reset();
    _controller.forward().then((_) {
      setState(() => girando = false);
      
      // --- SOLO ESTO SE AGREGÓ: papelitos solo cuando elige cara o sello ---
      setState(() {
        confettis = List.generate(250, (_) {
          return Particle(
            x: rand.nextDouble(),
            y: -0.2 - rand.nextDouble() * 0.3,
            color: [Colors.red, Colors.yellow, Colors.green, Colors.pink, Colors.cyan, Colors.orange, Colors.purple, Colors.white][rand.nextInt(8)],
            size: 8 + rand.nextDouble() * 12,
            speed: 0.4 + rand.nextDouble() * 0.8,
            drift: (rand.nextDouble() - 0.5) * 0.2,
          );
        });
      });
      _confettiController.forward(from: 0);
      // --- FIN ---
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose(); // solo esto se agregó
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double angulo = _animacion.value;
    // misma lógica que tu python: cada 90 grados cambia la cara
    bool mostrarAguila = (angulo % 180) < 90 ? esAguila : !esAguila;
    String imagen = mostrarAguila ? 'assets/aguila.jpeg' : 'assets/sello.jpeg';
    
    // factor como en tu código: abs(cos(radians(a)))
    double factor = cos(angulo * pi / 180).abs();
    // que no se haga 0 totalmente
    factor = factor.clamp(0.15, 1.0);

    return Scaffold(
      backgroundColor: colorFondo,
      body: Stack( // se cambió a Stack solo para poder poner los papelitos encima
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                const SizedBox(height: 40),
                // EL VOLADO - AHORA SE TOCA LA MONEDA
                GestureDetector(
                  onTap: lanzar,
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Center(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..setEntry(0, 0, factor),
                        child: ClipOval(
                          child: Image.asset(
                            imagen,
                            width: 250,
                            height: 250,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // --- SOLO ESTO SE AGREGÓ: LOS PAPELITOS ---
          AnimatedBuilder(
            animation: _confettiController,
            builder: (_, __) {
              return Stack(
                children: confettis.map((c) {
                  double progress = _confettiController.value;
                  double dy = c.y + progress * c.speed * 1.5;
                  double dx = c.x + progress * c.drift;
                  if (dy > 1.2) return const SizedBox(); // ya cayó
                  return Positioned(
                    left: MediaQuery.of(context).size.width * dx,
                    top: MediaQuery.of(context).size.height * dy,
                    child: Transform.rotate(
                      angle: progress * 10 + c.x,
                      child: Container(
                        width: c.size,
                        height: c.size * 0.6,
                        color: c.color,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          // --- FIN ---
        ],
      ),
    );
  }
}

// --- SOLO ESTA CLASE SE AGREGÓ PARA PAPELITOS ---
class Particle {
  double x, y, size, speed, drift;
  Color color;
  Particle({required this.x, required this.y, required this.color, required this.size, required this.speed, required this.drift});
}