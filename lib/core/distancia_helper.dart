import 'dart:math';

class Coordenada {
  final double latitude;
  final double longitude;

  const Coordenada(this.latitude, this.longitude);
}

class DistanciaHelper {
  static const double custoPorKm = 3.00; 
  static const double custoPorKg = 0.15;

  static const Map<String, Coordenada> cidades = {
    'Belo Horizonte': Coordenada(-19.9167, -43.9345),
    'Brasilia': Coordenada(-15.7938, -47.8827),
    'Curitiba': Coordenada(-25.4284, -49.2733),
    'Porto Alegre': Coordenada(-30.0346, -51.2177),
    'Rio de Janeiro': Coordenada(-22.9068, -43.1729),
    'Sao Paulo': Coordenada(-23.5505, -46.6333),
  };

  static double calcularDistanciaEmKm(String origem, String destino) {
    final coordOrigem = cidades[origem];
    final coordDestino = cidades[destino];

    if (coordOrigem == null || coordDestino == null) return 0.0;

    const r = 6371;

    final dLat = (coordDestino.latitude - coordOrigem.latitude) * pi / 180;
    final dLon = (coordDestino.longitude - coordOrigem.longitude) * pi / 180;

    final lat1Rad = coordOrigem.latitude * pi / 180;
    final lat2Rad = coordDestino.latitude * pi / 180;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return r * c;
  }

  // calcula o custo de frete sugerido considerando a distância percorrida e o peso total da carga
  static double calcularFreteSugerido(String origem, String destino, double pesoTotal) {
    final distancia = calcularDistanciaEmKm(origem, destino);
    if (distancia == 0.0) return 0.0;
    
    final custoDistancia = distancia * custoPorKm;
    final custoCarga = pesoTotal * custoPorKg;

    return custoDistancia + custoCarga;
  }
}