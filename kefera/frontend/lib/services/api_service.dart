import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

/*static const String baseUrl =
    'https://tiara-thirteen-output.ngrok-free.dev/api/productos';*/

static const String baseUrl =
'http://localhost:8080/api';

  Future<List<dynamic>> obtenerProductos() async {

    final response = await http.get(
      Uri.parse('$baseUrl/productos'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Error cargando productos');
  }

  Future<dynamic> obtenerDetalleProducto(
      int id) async {

    final response = await http.get(
      Uri.parse('$baseUrl/productos/$id/detalle'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
        'Error cargando detalle');
  }

  Future<List<dynamic>> obtenerProductosPorCategoria(
    int idCategoria) async {

  final response = await http.get(
    Uri.parse(
      '$baseUrl/productos/categoria/$idCategoria',
    ),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception(
      'Error cargando productos');
}

  Future<List<dynamic>> obtenerCategorias() async {

    final response = await http.get(
      Uri.parse('$baseUrl/categorias'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
        'Error cargando categorías');
  }

  Future<List<dynamic>> obtenerRecomendaciones(
      int id) async {

    final response = await http.get(
      Uri.parse(
          '$baseUrl/recomendaciones/$id'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
        'Error cargando recomendaciones');
  }


  Future<Map<String, dynamic>?> obtenerCuentaCompartida(int numeroMesa) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cuentas-compartidas/mesa/$numeroMesa'),
    );
    if (response.statusCode == 404) return null;
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception('Error recuperando la cuenta compartida: ${response.statusCode}');
  }

  Future<void> guardarCuentaCompartida(
    int numeroMesa,
    Map<String, dynamic> datos,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cuentas-compartidas/mesa/$numeroMesa'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error guardando la cuenta compartida: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> cerrarCuentaCompartida(int numeroMesa) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cuentas-compartidas/mesa/$numeroMesa'),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error cerrando la cuenta compartida');
    }
  }

}