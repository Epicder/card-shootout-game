import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';


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
    // Función para obtener un golero aleatorio para la CPU
  Future<Map<String, dynamic>> getRandomCPUGoalkeeper() async {
    final goalkeepersSnapshot = await _db.collection('Goleros').get();
    final random = Random();

    if (goalkeepersSnapshot.docs.isNotEmpty) {
      final randomGoalkeeper = goalkeepersSnapshot.docs[random.nextInt(goalkeepersSnapshot.docs.length)];
      return randomGoalkeeper.data();
    } else {
      throw Exception("No hay goleros disponibles en la colección.");
    }
  }

  // Función para obtener un jugador de campo aleatorio para la CPU
  Future<Map<String, dynamic>> getRandomCPUPlayer() async {
    List<String> playerCollections = ['Delanteros', 'Mediocampistas', 'Defensas'];
    final random = Random();

    // Selecciona una colección aleatoria (delanteros, mediocampistas o defensas)
    String randomCollection = playerCollections[random.nextInt(playerCollections.length)];
    final playersSnapshot = await _db.collection(randomCollection).get();

    if (playersSnapshot.docs.isNotEmpty) {
      final randomPlayer = playersSnapshot.docs[random.nextInt(playersSnapshot.docs.length)];
      return randomPlayer.data();
    } else {
      throw Exception("No hay jugadores disponibles en la colección de $randomCollection.");
    }
  }

  

  Future<void> addMultiplePlayers() async {
    // Jugadores para la colección de Delanteros (Forwards)
    List<Map<String, dynamic>> forwards = [
      {
        'name': 'Cristiano R.',
        'position': 'Forward',
        'level': 93,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fportugal.png?alt=media&token=90963739-20bd-4e8c-a943-f915d688d775',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fcristiano_r.png?alt=media&token=f26aade5-87a2-4dbc-a849-d05501a1df77',
        'shooting_options': 8
      },
      {
        'name': 'Lionel Messi',
        'position': 'Forward',
        'level': 94,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fargentina.png?alt=media&token=1933ea2e-ed3b-4d03-8109-ecd926d057fe',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Flionel_messi.png?alt=media&token=b3437fe7-2b40-41c4-8300-c04a10b99e16',
        'shooting_options': 8
      },      
      {
        'name': 'Robert Lewa.',
        'position': 'Forward',
        'level': 90,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fpoland.png?alt=media&token=1b44fafd-ae78-4125-a8ba-e35bb511f09b',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Frobert_lewa.png?alt=media&token=1369401d-51d0-4b2e-aa52-ad67b40e2fc4',
        'shooting_options': 8
      },
      {
        'name': 'Kylian Mbappé',
        'position': 'Forward',
        'level': 92,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Ffrance.png?alt=media&token=cce71ca2-1b5d-4f3e-a6be-bcbe180d0d2a',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fkylian_mbappe.png?alt=media&token=e7be8164-2ca7-4a70-8148-a60179f81935',
        'shooting_options': 8
      },
      {
        'name': 'Erling Haaland',
        'position': 'Forward',
        'level': 91,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fnorway.png?alt=media&token=0502cf1d-0168-4d11-9f71-ec38ddbea4eb',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Ferling_haaland.png?alt=media&token=91399090-e89a-4ef2-952c-733c5adab56a',
        'shooting_options': 8
      },
      {
        'name': 'Neymar Jr.',
        'position': 'Forward',
        'level': 90,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fbrazil.png?alt=media&token=292b2a01-dfc4-40c7-9872-a67bc7c1b252',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fneymar_jr.png?alt=media&token=fb13ce28-5ef1-4f0f-8594-9fbbe6e8451a',
        'shooting_options': 8
      },
      {
        'name': 'Karim Benzema',
        'position': 'Forward',
        'level': 88,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Ffrance.png?alt=media&token=cce71ca2-1b5d-4f3e-a6be-bcbe180d0d2a',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fkarim_benzema.png?alt=media&token=76010d2d-78c1-4ea0-bd5f-eb96b9e093d1',
        'shooting_options': 6
      },
      {
        'name': 'Harry Kane',
        'position': 'Forward',
        'level': 90,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fengland.png?alt=media&token=133cd839-d3a1-464a-9083-e93cb2be4b5c',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fharry_kane.png?alt=media&token=814885ad-0969-430b-9cb5-0187868279b9',
        'shooting_options': 8
      },
      {
        'name': 'Romelu Lukaku',
        'position': 'Forward',
        'level': 83,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fbelgium.png?alt=media&token=4776fa8f-57eb-49d9-bdc1-a4067c927ca7',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fromeu_lukaku.png?alt=media&token=96661468-2ea4-4490-ad9f-7b8687e53ef1',
        'shooting_options': 4
      },
      {
        'name': 'Luis Suárez',
        'position': 'Forward',
        'level': 88,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Furuguay.png?alt=media&token=1fd1fbe0-5ea8-43af-afdf-c5a012bc1db8',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fluis_suarez.png?alt=media&token=9d4c24d3-d2a9-419f-b615-b01e72120291',
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
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fbelgium.png?alt=media&token=4776fa8f-57eb-49d9-bdc1-a4067c927ca7',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fkevin_de_brunye.png?alt=media&token=065f1210-b7d2-4d3f-afcd-6f12dcbee57b',
        'shooting_options': 8
      },
      {
        'name': 'Luka Modrić',
        'position': 'Midfielder',
        'level': 87,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fcroatia.png?alt=media&token=7ff3d218-6a13-43ed-95b0-c8937623c7cf',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fluka_modric.png?alt=media&token=7349e651-a743-47e2-bcdc-62b935bfd6e9',
        'shooting_options': 6
      },
      {
        'name': 'Bruno Fer.',
        'position': 'Midfielder',
        'level': 88,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fportugal.png?alt=media&token=90963739-20bd-4e8c-a943-f915d688d775',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fbruno_fernandez.png?alt=media&token=0484aa19-0fa1-4d19-8378-6a6d698ffb12',
        'shooting_options': 6
      },
      {
        'name': 'Joshua Kimmich',
        'position': 'Midfielder',
        'level': 89,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fgermany.png?alt=media&token=fc88da10-e951-4385-8779-65ad7817abfe',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fjoshua_kimmich.png?alt=media&token=f8f5413a-a654-46d3-9147-6cc4a08175af',
        'shooting_options': 6
      },
      {
        'name': 'Toni Kroos',
        'position': 'Midfielder',
        'level': 87,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fgermany.png?alt=media&token=fc88da10-e951-4385-8779-65ad7817abfe',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Ftoni_kroos.png?alt=media&token=1e068f22-8b80-420f-9b9c-1c82cd1583b0',
        'shooting_options': 6
      },
      {
        'name': 'Marco Verratti',
        'position': 'Midfielder',
        'level': 85,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fitaly.png?alt=media&token=76826ce1-a667-4ac5-a7ac-20d4f49439d7',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fmarco_verratti.png?alt=media&token=6149e06a-f3b2-47a6-b682-eeff11c25c58',
        'shooting_options': 6
      },
      {
        'name': 'Paul Pogba',
        'position': 'Midfielder',
        'level': 84,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Ffrance.png?alt=media&token=cce71ca2-1b5d-4f3e-a6be-bcbe180d0d2a',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fpaul_pogba.png?alt=media&token=0dc0b091-793d-4b58-898a-4e4aaee15abd',
        'shooting_options': 6
      },
      {
        'name': 'Bernardo Silva',
        'position': 'Midfielder',
        'level': 88,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fportugal.png?alt=media&token=90963739-20bd-4e8c-a943-f915d688d775',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fbernardo_silva.png?alt=media&token=b2eb70c2-397a-4230-89b3-0c60dab48a20',
        'shooting_options': 6
      },
      {
        'name': 'Frenkie de Jong',
        'position': 'Midfielder',
        'level': 85,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fnetherlands.png?alt=media&token=9afaef90-3151-4e7b-956d-6f6162dbae8a',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Ffrenkie_de_jong.png?alt=media&token=d7ac89a0-8cdd-4bc5-ad39-09c823e4e5e8',
        'shooting_options': 6
      },
      {
        'name': 'Casemiro',
        'position': 'Midfielder',
        'level': 81,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fbrazil.png?alt=media&token=292b2a01-dfc4-40c7-9872-a67bc7c1b252',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fcasemiro.png?alt=media&token=edc56ba6-fa59-4fce-9ece-cbb95cd49eb1',
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
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fnetherlands.png?alt=media&token=9afaef90-3151-4e7b-956d-6f6162dbae8a',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fvirgil_v_d.png?alt=media&token=014d3355-0dd2-4092-a63b-77c71f653219',
        'shooting_options': 8
      },
      {
        'name': 'Sergio Ramos',
        'position': 'Defender',
        'level': 87,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fspain.png?alt=media&token=ef07c766-0a06-4c9a-8ede-4a4c30db963b',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fsergio_ramos.png?alt=media&token=4fc6a0f2-55be-4151-a7b3-ee0d7509f330',
        'shooting_options': 6
      },
      {
        'name': 'Kalidou K.',
        'position': 'Defender',
        'level': 86,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fsenegal.png?alt=media&token=ea2b8062-17d9-4cd0-a8e0-15004f7d4ea8',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fkalidou_k.png?alt=media&token=cd5c6952-b504-435f-9b2d-785d44b9a5b2',
        'shooting_options': 6
      },
      {
        'name': 'Rúben Dias',
        'position': 'Defender',
        'level': 88,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fportugal.png?alt=media&token=90963739-20bd-4e8c-a943-f915d688d775',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fruben_dias.png?alt=media&token=64cf9ae9-d993-438b-ba1a-82229da5bc6a',
        'shooting_options': 6
      },
      {
        'name': 'Marquinhos',
        'position': 'Defender',
        'level': 85,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fbrazil.png?alt=media&token=292b2a01-dfc4-40c7-9872-a67bc7c1b252',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fmarquinhos.png?alt=media&token=f31e6225-f9b3-435e-ba43-810ecbc6f63f',
        'shooting_options': 6
      },
      {
        'name': 'Thiago Silva',
        'position': 'Defender',
        'level': 83,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fbrazil.png?alt=media&token=292b2a01-dfc4-40c7-9872-a67bc7c1b252',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fthiago_silva.png?alt=media&token=8d8110b0-510e-4ff9-b7bd-d9a158537709',
        'shooting_options': 4
      },
      {
        'name': 'Raphaël Varane',
        'position': 'Defender',
        'level': 84,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Ffrance.png?alt=media&token=cce71ca2-1b5d-4f3e-a6be-bcbe180d0d2a',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Frapahel_varane.png?alt=media&token=f3bf4a7d-5944-448a-a4d4-65ff57adb37b',
        'shooting_options': 4
      },
      {
        'name': 'Jordi Alba',
        'position': 'Defender',
        'level': 83,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fspain.png?alt=media&token=ef07c766-0a06-4c9a-8ede-4a4c30db963b',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fjordi_alba.png?alt=media&token=72f4955f-df7d-41aa-9fe1-e1459142aa62',
        'shooting_options': 4
      },
      {
        'name': 'Trent A.A.',
        'position': 'Defender',
        'level': 88,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fengland.png?alt=media&token=133cd839-d3a1-464a-9083-e93cb2be4b5c',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Ftrent_a_a.png?alt=media&token=05e07732-504b-48e2-a044-c959844f09e8',
        'shooting_options': 6
      },
      {
        'name': 'Andrew R.',
        'position': 'Defender',
        'level': 87,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fscotland.png?alt=media&token=fab0ad08-6f43-498d-a29f-926563388dc7',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fandrew_r.png?alt=media&token=69027220-70f6-4a43-87a0-d5b55ac3809a',
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
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fslovenia.png?alt=media&token=d779bd81-edca-4add-9063-201267756fef',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fjan_oblak.png?alt=media&token=371289e7-84e0-4274-80f8-81bdadc6afe8',
        'shooting_options': 8
      },
      {
        'name': 'Manuel Neuer',
        'position': 'Goalkeeper',
        'level': 87,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fgermany.png?alt=media&token=fc88da10-e951-4385-8779-65ad7817abfe',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fmanuel_neuer.png?alt=media&token=e437c29b-c2e4-47f5-96e0-0432cc675bb8',
        'shooting_options': 6
      },
      {
        'name': 'Alisson Becker',
        'position': 'Goalkeeper',
        'level': 89,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fbrazil.png?alt=media&token=292b2a01-dfc4-40c7-9872-a67bc7c1b252',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Falisson_becker.png?alt=media&token=a600f170-fb82-4032-b46b-4f6d67287afe',
        'shooting_options': 6
      },
      {
        'name': 'Thibaut Courtois',
        'position': 'Goalkeeper',
        'level': 91,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fbelgium.png?alt=media&token=4776fa8f-57eb-49d9-bdc1-a4067c927ca7',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fthibaut_courtois.png?alt=media&token=ea41e418-c82f-4082-a1bc-408ea7aa536e',
        'shooting_options': 8
      },
      {
        'name': 'Marc-André T.S.',
        'position': 'Goalkeeper',
        'level': 88,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fgermany.png?alt=media&token=fc88da10-e951-4385-8779-65ad7817abfe',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fmarc-andre_t_s.png?alt=media&token=5b42e383-a910-4aba-aa8f-b0de149d4aa4',
        'shooting_options': 6
      },
      {
        'name': 'Ederson Moraes',
        'position': 'Goalkeeper',
        'level': 90,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fbrazil.png?alt=media&token=292b2a01-dfc4-40c7-9872-a67bc7c1b252',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Federson_morales.png?alt=media&token=3530b9db-e3ea-4482-a10f-631df3bfb2eb',
        'shooting_options': 8
      },
      {
        'name': 'Keylor Navas',
        'position': 'Goalkeeper',
        'level': 85,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fcosta_rica.png?alt=media&token=3ac2643c-adfc-46a7-81da-52f6df88f546',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fkeylor_navas.png?alt=media&token=888b2008-bd60-45ba-b930-d66ce141263f',
        'shooting_options': 6
      },
      {
        'name': 'Gianluigi Don.',
        'position': 'Goalkeeper',
        'level': 87,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fitaly.png?alt=media&token=76826ce1-a667-4ac5-a7ac-20d4f49439d7',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fgianluigi_don.png?alt=media&token=2656403c-624f-4ed8-86a5-00343e807b0a',
        'shooting_options': 6
      },
      {
        'name': 'Wojciech S.',
        'position': 'Goalkeeper',
        'level': 86,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Fpoland.png?alt=media&token=1b44fafd-ae78-4125-a8ba-e35bb511f09b',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fwojciech_s.png?alt=media&token=e49f7ca3-8ac8-4618-87f6-900c6d4367ec',
        'shooting_options': 6
      },
      {
        'name': 'Hugo Lloris',
        'position': 'Goalkeeper',
        'level': 84,
        'country': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/country_flags%2Ffrance.png?alt=media&token=cce71ca2-1b5d-4f3e-a6be-bcbe180d0d2a',
        'image': 'https://firebasestorage.googleapis.com/v0/b/penalty-card-game-login.appspot.com/o/players_images%2Fhugo_lloris.png?alt=media&token=47b680e2-1be6-44d0-be77-09106181812c',
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
