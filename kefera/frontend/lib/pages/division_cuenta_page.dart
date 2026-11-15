import 'package:flutter/material.dart';
import '../models/carrito.dart';
import '../services/api_service.dart';

class _Comensal {
  final int id;
  final String nombre;

  const _Comensal({required this.id, required this.nombre});
}

class DivisionCuentaPage extends StatefulWidget {
  const DivisionCuentaPage({super.key});

  @override
  State<DivisionCuentaPage> createState() => _DivisionCuentaPageState();
}

class _DivisionCuentaPageState extends State<DivisionCuentaPage> {
  final TextEditingController _mesaController = TextEditingController();
  final TextEditingController _capacidadController =
      TextEditingController(text: '4');
  final TextEditingController _nombreController = TextEditingController();

  int? _capacidad;
  int _siguienteId = 1;
  final ApiService _api = ApiService();
  bool _guardando = false;
  bool _cargandoCuenta = false;
  int? get _numeroMesa => int.tryParse(_mesaController.text.trim());
  final List<_Comensal> _comensales = [];
  final Map<int, Set<int>> _participantesPorProducto = {};

  double get _total => Carrito.total();

  int get _totalAsignado =>
      _participantesPorProducto.values.fold<int>(
        0,
        (total, participantes) => total + participantes.length,
      );

  @override
  void dispose() {
    _mesaController.dispose();
    _capacidadController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _configurarMesa() async {
    final numeroMesa = _mesaController.text.trim();
    final capacidad = int.tryParse(_capacidadController.text.trim());

    if (numeroMesa.isEmpty || capacidad == null || capacidad < 1) {
      _mostrarMensaje('Introduce una mesa y una capacidad válida.');
      return;
    }
    if (capacidad > 30) {
      _mostrarMensaje('La capacidad máxima admitida es de 30 personas.');
      return;
    }

    setState(() {
      _capacidad = capacidad;
      _comensales.clear();
      _participantesPorProducto.clear();
      _siguienteId = 1;
      _cargandoCuenta = true;
    });
    try {
      final existente = await _api.obtenerCuentaCompartida(int.parse(numeroMesa));
      if (existente != null && mounted) {
        final lista = (existente['comensales'] as List? ?? []);
        final asignaciones = (existente['asignaciones'] as List? ?? []);
        setState(() {
          _comensales.clear();
          for (final raw in lista) {
            final item = Map<String, dynamic>.from(raw);
            final id = (item['id'] as num).toInt();
            _comensales.add(_Comensal(id: id, nombre: item['nombre'].toString()));
            if (id >= _siguienteId) _siguienteId = id + 1;
          }
          _participantesPorProducto.clear();
          for (final raw in asignaciones) {
            final item = Map<String, dynamic>.from(raw);
            final index = (item['indiceProducto'] as num).toInt();
            if (index >= 0 && index < Carrito.productos.length) {
              _participantesPorProducto[index] =
                  (item['comensales'] as List).map((e) => (e as num).toInt()).toSet();
            }
          }
        });
        _mostrarMensaje('Cuenta compartida recuperada de la mesa $numeroMesa.');
      }
    } catch (e) {
      _mostrarMensaje('No se pudo recuperar la cuenta: $e');
    } finally {
      if (mounted) setState(() => _cargandoCuenta = false);
    }
  }

  Future<void> _guardarCuenta() async {
    final mesa = _numeroMesa;
    final capacidad = _capacidad;
    if (mesa == null || capacidad == null || !mounted) return;
    setState(() => _guardando = true);
    final payload = <String, dynamic>{
      'capacidad': capacidad,
      'comensales': _comensales.map((c) => {'id': c.id, 'nombre': c.nombre}).toList(),
      'asignaciones': _participantesPorProducto.entries.map((entry) => {
        'indiceProducto': entry.key,
        'productoId': Carrito.productos[entry.key].producto['idProducto'],
        'nombreProducto': Carrito.productos[entry.key].producto['nombre'],
        'cantidad': Carrito.productos[entry.key].cantidad,
        'precioUnitario': Carrito.productos[entry.key].producto['precio'],
        'comensales': entry.value.toList(),
      }).toList(),
    };
    try {
      await _api.guardarCuentaCompartida(mesa, payload);
    } catch (e) {
      if (mounted) _mostrarMensaje('No se pudo guardar en el servidor: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _anadirComensal() {
    final nombre = _nombreController.text.trim();
    if (_capacidad == null) {
      _mostrarMensaje('Primero configura la mesa.');
      return;
    }
    if (nombre.isEmpty) {
      _mostrarMensaje('Escribe el nombre del comensal.');
      return;
    }
    if (_comensales.length >= _capacidad!) {
      _mostrarMensaje('La mesa ya ha alcanzado su capacidad.');
      return;
    }
    if (_comensales.any(
      (comensal) => comensal.nombre.toLowerCase() == nombre.toLowerCase(),
    )) {
      _mostrarMensaje('Ya existe un comensal con ese nombre.');
      return;
    }

    setState(() {
      _comensales.add(_Comensal(id: _siguienteId++, nombre: nombre));
      _nombreController.clear();
    });
    _guardarCuenta();
  }

  void _eliminarComensal(_Comensal comensal) {
    setState(() {
      _comensales.removeWhere((item) => item.id == comensal.id);
      for (final participantes in _participantesPorProducto.values) {
        participantes.remove(comensal.id);
      }
    });
    _guardarCuenta();
  }

  void _cambiarParticipacion(int productoIndex, int comensalId, bool marcado) {
    setState(() {
      final participantes =
          _participantesPorProducto.putIfAbsent(productoIndex, () => <int>{});
      if (marcado) {
        participantes.add(comensalId);
      } else {
        participantes.remove(comensalId);
      }
    });
    _guardarCuenta();
  }

  int _centimosAsignados(int productoIndex, int comensalId) {
    final participantes =
        (_participantesPorProducto[productoIndex] ?? <int>{}).toList()..sort();
    if (participantes.isEmpty) return 0;

    final item = Carrito.productos[productoIndex];
    final totalCentimos = (item.subtotal * 100).round();
    final base = totalCentimos ~/ participantes.length;
    final resto = totalCentimos % participantes.length;
    final posicion = participantes.indexOf(comensalId);
    if (posicion < 0) return 0;

    // Los céntimos sobrantes se reparten de uno en uno para que la suma
    // de las partes coincida exactamente con el subtotal original.
    return base + (posicion < resto ? 1 : 0);
  }

  double _importePersona(int comensalId) {
    var centimos = 0;
    for (var i = 0; i < Carrito.productos.length; i++) {
      centimos += _centimosAsignados(i, comensalId);
    }
    return centimos / 100;
  }

  double _importeCompartido(int productoIndex, int comensalId) {
    return _centimosAsignados(productoIndex, comensalId) / 100;
  }

  double _importeAsignadoProducto(int index) {
    final participantes = _participantesPorProducto[index] ?? <int>{};
    if (participantes.isEmpty) return 0;
    return Carrito.productos[index].subtotal;
  }

  bool get _todoAsignado {
    if (_comensales.isEmpty || Carrito.productos.isEmpty) return false;
    for (var i = 0; i < Carrito.productos.length; i++) {
      if ((_participantesPorProducto[i] ?? <int>{}).isEmpty) return false;
    }
    return true;
  }

  void _mostrarResumen() {
    if (_capacidad == null) {
      _mostrarMensaje('Configura primero la mesa.');
      return;
    }
    if (_comensales.isEmpty) {
      _mostrarMensaje('Añade al menos un comensal.');
      return;
    }
    if (!_todoAsignado) {
      _mostrarMensaje('Asigna cada producto a uno o varios comensales.');
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF171717),
        title: const Text(
          'Resumen de la cuenta',
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                'Mesa ${_mesaController.text} · ${_comensales.length} comensales',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              ..._comensales.map((comensal) {
                final productosPersona = <String>[];
                for (var i = 0; i < Carrito.productos.length; i++) {
                  final participantes =
                      _participantesPorProducto[i] ?? <int>{};
                  if (participantes.contains(comensal.id)) {
                    final item = Carrito.productos[i];
                    final parte = _importeCompartido(i, comensal.id);
                    productosPersona.add(
                      '${item.producto["nombre"]} · ${parte.toStringAsFixed(2)} €',
                    );
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comensal.nombre,
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ...productosPersona.map(
                        (producto) => Text(
                          producto,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      Text(
                        'Total: ${_importePersona(comensal.id).toStringAsFixed(2)} €',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(color: Colors.white24),
              Text(
                'Total de la mesa: ${_total.toStringAsFixed(2)} €',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Este resumen calcula el reparto de consumiciones. El cobro real debe realizarse mediante el flujo de pago del establecimiento.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'VOLVER',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Carrito.productos.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dividir cuenta')),
        body: const Center(
          child: Text(
            'No hay productos en el carrito.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cuenta compartida')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _seccionTitulo('1. Configura la mesa'),
          const Text(
            'Indica el número de mesa y cuántas personas caben en ella.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _mesaController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _decoracion('N.º de mesa'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _capacidadController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _decoracion('Capacidad'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _configurarMesa,
              child: const Text('CONFIGURAR MESA'),
            ),
          ),
          if (_guardando || _cargandoCuenta)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text('Sincronizando cuenta...', style: TextStyle(color: Colors.white70)),
              ]),
            ),
          if (_capacidad != null) ...[
            const SizedBox(height: 22),
            _seccionTitulo('2. Añade a los comensales'),
            Text(
              '${_comensales.length} de $_capacidad plazas ocupadas',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nombreController,
                    style: const TextStyle(color: Colors.white),
                    textCapitalization: TextCapitalization.words,
                    decoration: _decoracion('Nombre del comensal'),
                    onSubmitted: (_) => _anadirComensal(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _anadirComensal,
                  icon: const Icon(Icons.person_add),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
            if (_comensales.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Todavía no hay personas añadidas.',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ..._comensales.map(
              (comensal) => Card(
                color: const Color(0xFF1B1B1B),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    child: Text(comensal.nombre[0].toUpperCase()),
                  ),
                  title: Text(comensal.nombre),
                  trailing: IconButton(
                    tooltip: 'Eliminar comensal',
                    onPressed: () => _eliminarComensal(comensal),
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _seccionTitulo('3. Reparte las consumiciones'),
            const Text(
              'Marca quién ha compartido cada producto. Si varias personas lo han consumido, el importe se reparte entre ellas.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            ...List.generate(Carrito.productos.length, (index) {
              final item = Carrito.productos[index];
              final participantes =
                  _participantesPorProducto[index] ?? <int>{};
              final asignado = participantes.isNotEmpty;
              return Card(
                color: const Color(0xFF1B1B1B),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.restaurant,
                            color: Color(0xFFD4AF37),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.producto['nombre']?.toString() ??
                                      'Producto',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Cantidad: ${item.cantidad} · '
                                  '${item.subtotal.toStringAsFixed(2)} €',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            asignado ? Icons.check_circle : Icons.warning,
                            color: asignado
                                ? Colors.greenAccent
                                : Colors.orangeAccent,
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24),
                      if (_comensales.isEmpty)
                        const Text(
                          'Añade comensales para poder asignar este producto.',
                          style: TextStyle(color: Colors.white54),
                        )
                      else
                        ..._comensales.map(
                          (comensal) => CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            activeColor: const Color(0xFFD4AF37),
                            checkColor: Colors.black,
                            title: Text(
                              comensal.nombre,
                              style: const TextStyle(color: Colors.white),
                            ),
                            value: participantes.contains(comensal.id),
                            onChanged: (marcado) => _cambiarParticipacion(
                              index,
                              comensal.id,
                              marcado ?? false,
                            ),
                          ),
                        ),
                      if (asignado)
                        Text(
                          'Cada participante paga desde '
                          '${(item.subtotal / participantes.length).toStringAsFixed(2)} € '
                          '(reparto exacto al céntimo en el resumen)',
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        const Text(
                          'Pendiente de asignar',
                          style: TextStyle(color: Colors.orangeAccent),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            _seccionTitulo('4. Resumen'),
            Card(
              color: const Color(0xFF1B1B1B),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    ..._comensales.map(
                      (comensal) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                comensal.nombre,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            Text(
                              '${_importePersona(comensal.id).toStringAsFixed(2)} €',
                              style: const TextStyle(
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white24),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Total de la mesa',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${_total.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Productos asignados: ${_participantesPorProducto.values.where((p) => p.isNotEmpty).length} de ${Carrito.productos.length}',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _mostrarResumen,
                icon: const Icon(Icons.receipt_long),
                label: const Text('VER RESUMEN INDIVIDUAL'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _seccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        titulo,
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  InputDecoration _decoracion(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60),
      filled: true,
      fillColor: const Color(0xFF1B1B1B),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD4AF37)),
      ),
    );
  }
}
