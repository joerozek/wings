window.onload = ->
  @game = new Phaser.Game(800, 480, Phaser.AUTO)
  @game.state.add 'main', new MainState, true