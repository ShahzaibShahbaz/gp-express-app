class LocationData {
  static const Map<String, Map<String, List<String>>> countryData = {
    'France': {
      'Paris': ['Charles de Gaulle Airport', 'Orly Airport'],
      'Nice': ['Nice Côte d\'Azur Airport'],
      'Lyon': ['Lyon-Saint Exupéry Airport'],
    },
    'United Kingdom': {
      'London': ['Heathrow Airport', 'Gatwick Airport', 'Stansted Airport'],
      'Manchester': ['Manchester Airport'],
      'Birmingham': ['Birmingham Airport'],
    },
    'Germany': {
      'Berlin': ['Berlin Brandenburg Airport'],
      'Munich': ['Munich Airport'],
      'Frankfurt': ['Frankfurt Airport'],
    },
    'Spain': {
      'Madrid': ['Adolfo Suárez Madrid–Barajas Airport'],
      'Barcelona': ['Barcelona–El Prat Airport'],
      'Malaga': ['Málaga Airport'],
    },
    'Italy': {
      'Rome': ['Leonardo da Vinci International Airport'],
      'Milan': ['Milan Malpensa Airport', 'Milan Linate Airport'],
      'Venice': ['Venice Marco Polo Airport'],
    },
  };

  static List<String> getCountries() {
    return countryData.keys.toList();
  }

  static List<String> getCitiesForCountry(String country) {
    return countryData[country]?.keys.toList() ?? [];
  }

  static List<String> getAirportsForCity(String country, String city) {
    return countryData[country]?[city] ?? [];
  }
}