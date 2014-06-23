window.onload = ->
  @game = new Phaser.Game(800, 450, Phaser.WEBGL)
  @game.state.add 'title', new TitleState, true
  @game.state.add 'main', new MainState, false