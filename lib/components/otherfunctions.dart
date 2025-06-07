bool checkForCollisions(player, terrain) {
  final hitbox = player.hitbox;
  final playerPosX = player.position.x + hitbox.offsetX;
  final playerPosY = player.position.y + hitbox.offsetY;
  final playerSizeW = hitbox.width;
  final playerSizeH = hitbox.height;

  final terrainPosX = terrain.x;
  final terrainPosY = terrain.y;
  final terrainSizeW = terrain.width;
  final terrainSizeH = terrain.height;

  final fixedX = player.scale.x < 0
      ? playerPosX - (hitbox.offsetX * 2) - playerSizeW
      : playerPosX;
  final fixedY = terrain.isPlatform ? playerPosY + playerSizeH : playerPosY;

  return (fixedY < terrainPosY + terrainSizeH &&
      playerPosY + playerSizeH > terrainPosY &&
      fixedX < terrainPosX + terrainSizeW &&
      fixedX + playerSizeW > terrainPosX);
}
