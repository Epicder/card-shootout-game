import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addPlayerToFirestore(String collection, String playerId, Map<String, dynamic> playerData) async {
    try {
      // Verificamos si el documento ya existe
      DocumentSnapshot doc = await _db.collection(collection).doc(playerId).get();

      if (doc.exists) {
        print('Player $playerId already exists in Firestore');
      } else {
        await _db.collection(collection).doc(playerId).set(playerData);
        print('Player $playerId added successfully');
      }
    } catch (e) {
      print('Error adding player $playerId: $e');
    }
  }
  

  Future<void> addMultiplePlayers() async {
    // Jugadores para la colección de Delanteros (Forwards)
    List<Map<String, dynamic>> forwards = [
      {
        'name': 'Cristiano Ronaldo',
        'position': 'Forward',
        'level': 93,
        'country': 'Portugal',
        'image': 'URL',
        'shooting_options': 7
      },
      {
        'name': 'Lionel Messi',
        'position': 'Forward',
        'level': 94,
        'country': 'Argentina',
        'image': 'URL',
        'shooting_options': 7
      },      
      {
        'name': 'Robert Lewandowski',
        'position': 'Forward',
        'level': 90,
        'country': 'Poland',
        'image': 'URL',
        'shooting_options': 7
      },
      {
        'name': 'Kylian Mbappé',
        'position': 'Forward',
        'level': 92,
        'country': 'France',
        'image': 'URL',
        'shooting_options': 7
      },
      {
        'name': 'Erling Haaland',
        'position': 'Forward',
        'level': 91,
        'country': 'Norway',
        'image': 'URL',
        'shooting_options': 7
      },
      {
        'name': 'Neymar Jr.',
        'position': 'Forward',
        'level': 90,
        'country': 'Brazil',
        'image': 'URL',
        'shooting_options': 7
      },
      {
        'name': 'Karim Benzema',
        'position': 'Forward',
        'level': 88,
        'country': 'France',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Harry Kane',
        'position': 'Forward',
        'level': 90,
        'country': 'England',
        'image': 'URL',
        'shooting_options': 7
      },
      {
        'name': 'Romelu Lukaku',
        'position': 'Forward',
        'level': 83,
        'country': 'Belgium',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Luis Suárez',
        'position': 'Forward',
        'level': 88,
        'country': 'Uruguay',
        'image': 'URL',
        'shooting_options': 6
      }
      // Agrega más jugadores de delanteros aquí
    ];

    // Jugadores para la colección de Mediocampistas (Midfielders)
    List<Map<String, dynamic>> midfielders = [
      {
        'name': 'Kevin De Bruyne',
        'position': 'Midfielder',
        'level': 91,
        'country': 'Belgium',
        'image': 'URL',
        'shooting_options': 7
      },
      {
        'name': 'Luka Modrić',
        'position': 'Midfielder',
        'level': 87,
        'country': 'Croatia',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Bruno Fernandes',
        'position': 'Midfielder',
        'level': 88,
        'country': 'Portugal',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Joshua Kimmich',
        'position': 'Midfielder',
        'level': 89,
        'country': 'Germany',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Toni Kroos',
        'position': 'Midfielder',
        'level': 87,
        'country': 'Germany',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Marco Verratti',
        'position': 'Midfielder',
        'level': 85,
        'country': 'Italy',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Paul Pogba',
        'position': 'Midfielder',
        'level': 84,
        'country': 'France',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Bernardo Silva',
        'position': 'Midfielder',
        'level': 88,
        'country': 'Portugal',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Frenkie de Jong',
        'position': 'Midfielder',
        'level': 85,
        'country': 'Netherlands',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Casemiro',
        'position': 'Midfielder',
        'level': 85,
        'country': 'Brazil',
        'image': 'URL',
        'shooting_options': 6
      }
      // Agrega más jugadores de mediocampistas aquí
    ];

    // Jugadores para la colección de Defensas (Defenders)
    List<Map<String, dynamic>> defenders = [
      {
        'name': 'Virgil van Dijk',
        'position': 'Defender',
        'level': 91,
        'country': 'Netherlands',
        'image': 'URL',
        'shooting_options': 7
      },
      {
        'name': 'Sergio Ramos',
        'position': 'Defender',
        'level': 87,
        'country': 'Spain',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Kalidou Koulibaly',
        'position': 'Defender',
        'level': 86,
        'country': 'Senegal',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Rúben Dias',
        'position': 'Defender',
        'level': 88,
        'country': 'Portugal',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Marquinhos',
        'position': 'Defender',
        'level': 85,
        'country': 'Brazil',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Thiago Silva',
        'position': 'Defender',
        'level': 83,
        'country': 'Brazil',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Raphaël Varane',
        'position': 'Defender',
        'level': 84,
        'country': 'France',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Jordi Alba',
        'position': 'Defender',
        'level': 83,
        'country': 'Spain',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Trent Alexander-Arnold',
        'position': 'Defender',
        'level': 88,
        'country': 'England',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Andrew Robertson',
        'position': 'Defender',
        'level': 87,
        'country': 'Scotland',
        'image': 'URL',
        'shooting_options': 6
      }
      // Agrega más jugadores de defensas aquí
    ];

    // Jugadores para la colección de Goleros (Goalkeepers)
    List<Map<String, dynamic>> goalkeepers = [
      {
        'name': 'Jan Oblak',
        'position': 'Goalkeeper',
        'level': 90,
        'country': 'Slovenia',
        'image': 'URL',
        'shooting_options': 8
      },
      {
        'name': 'Manuel Neuer',
        'position': 'Goalkeeper',
        'level': 87,
        'country': 'Germany',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Alisson Becker',
        'position': 'Goalkeeper',
        'level': 89,
        'country': 'Brazil',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Thibaut Courtois',
        'position': 'Goalkeeper',
        'level': 91,
        'country': 'Belgium',
        'image': 'URL',
        'shooting_options': 8
      },
      {
        'name': 'Marc-André ter Stegen',
        'position': 'Goalkeeper',
        'level': 88,
        'country': 'Germany',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Ederson Moraes',
        'position': 'Goalkeeper',
        'level': 89,
        'country': 'Brazil',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Keylor Navas',
        'position': 'Goalkeeper',
        'level': 85,
        'country': 'Costa Rica',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Gianluigi Donnarumma',
        'position': 'Goalkeeper',
        'level': 87,
        'country': 'Italy',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Wojciech Szczęsny',
        'position': 'Goalkeeper',
        'level': 86,
        'country': 'Poland',
        'image': 'URL',
        'shooting_options': 6
      },
      {
        'name': 'Hugo Lloris',
        'position': 'Goalkeeper',
        'level': 84,
        'country': 'France',
        'image': 'URL',
        'shooting_options': 6
      }
      // Agrega más jugadores de goleros aquí
    ];

    // Añadir los jugadores de cada colección
    for (var player in forwards) {
      await addPlayerToFirestore('Delanteros', player['name'].toLowerCase().replaceAll(' ', '_'), player);
    }

    for (var player in midfielders) {
      await addPlayerToFirestore('Mediocampistas', player['name'].toLowerCase().replaceAll(' ', '_'), player);
    }

    for (var player in defenders) {
      await addPlayerToFirestore('Defensas', player['name'].toLowerCase().replaceAll(' ', '_'), player);
    }

    for (var player in goalkeepers) {
      await addPlayerToFirestore('Goleros', player['name'].toLowerCase().replaceAll(' ', '_'), player);
    }
  }
}
