import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:clean_architecture_example/layers/domain/entity/character.dart';

part 'character_details_state.dart';

class CharacterDetailsCubit extends Cubit<CharacterDetailsState> {
  CharacterDetailsCubit({
    required Character character,
  }) : super(CharacterDetailsState(character));
}
