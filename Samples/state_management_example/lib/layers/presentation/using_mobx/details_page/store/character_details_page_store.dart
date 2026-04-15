import 'package:mobx/mobx.dart';
import 'package:clean_architecture_example/layers/domain/entity/character.dart';

part 'character_details_page_store.g.dart';

class CharacterDetailsPageStore = CharacterDetailsPageStoreBase
    with _$CharacterDetailsPageStore;

abstract class CharacterDetailsPageStoreBase with Store {
  CharacterDetailsPageStoreBase({
    required Character character,
  }) : _character = character;

  @readonly
  // ignore: prefer_final_fields
  late Character _character;
}
