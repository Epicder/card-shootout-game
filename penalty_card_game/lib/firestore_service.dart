import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addPlayerToFirestore(String collection, String playerId, Map<String, dynamic> playerData) async {
    try {
      // Verificamos si el documento ya existe
      DocumentSnapshot doc = await _db.collection(collection).doc(playerId).get();

      if (doc.exists) {
        print('Player $playerId already exists in Firestore');
        await _db.collection(collection).doc(playerId).set(playerData);
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
        'shooting_options': 8
      },
      {
        'name': 'Lionel Messi',
        'position': 'Forward',
        'level': 94,
        'country': 'Argentina',
        'image': 'URL',
        'shooting_options': 8
      },      
      {
        'name': 'Robert Lewandowski',
        'position': 'Forward',
        'level': 90,
        'country': 'Poland',
        'image': 'URL',
        'shooting_options': 8
      },
      {
        'name': 'Kylian Mbappé',
        'position': 'Forward',
        'level': 92,
        'country': 'France',
        'image': 'URL',
        'shooting_options': 8
      },
      {
        'name': 'Erling Haaland',
        'position': 'Forward',
        'level': 91,
        'country': 'Norway',
        'image': 'URL',
        'shooting_options': 8
      },
      {
        'name': 'Neymar Jr.',
        'position': 'Forward',
        'level': 90,
        'country': 'Brazil',
        'image': 'URL',
        'shooting_options': 8
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
        'shooting_options': 8
      },
      {
        'name': 'Romelu Lukaku',
        'position': 'Forward',
        'level': 83,
        'country': 'Belgium',
        'image': 'URL',
        'shooting_options': 4
      },
      {
        'name': 'Luis Suárez',
        'position': 'Forward',
        'level': 88,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Furuguay.png?alt=media&token=1fd1fbe0-5ea8-43af-afdf-c5a012bc1db8',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fsuarez.png?alt=media&token=3ca13315-8cfa-4499-a52d-85fc6f3c43e6',
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
        'shooting_options': 8
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
        'level': 81,
        'country': 'Brazil',
        'image': 'URL',
        'shooting_options': 4
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
        'shooting_options': 8
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
        'shooting_options': 4
      },
      {
        'name': 'Raphaël Varane',
        'position': 'Defender',
        'level': 84,
        'country': 'France',
        'image': 'URL',
        'shooting_options': 4
      },
      {
        'name': 'Jordi Alba',
        'position': 'Defender',
        'level': 83,
        'country': 'Spain',
        'image': 'URL',
        'shooting_options': 4
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
        'level': 90,
        'country': 'Brazil',
        'image': 'URL',
        'shooting_options': 8
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
