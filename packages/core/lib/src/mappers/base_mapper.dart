abstract class BaseMapper<Entity, Dto> {
  const BaseMapper();

  Entity mapToEntity(Dto dto);
  Dto mapToDto(Entity entity);

  List<Entity> mapToEntityList(List<Dto> dtos) {
    return dtos.map(mapToEntity).toList();
  }

  List<Dto> mapToDtoList(List<Entity> entities) {
    return entities.map(mapToDto).toList();
  }
}
