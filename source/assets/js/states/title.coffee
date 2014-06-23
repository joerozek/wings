class TitleState extends Phaser.State
  constructor: -> super

  preload: ->
    @game.load.image('background', 'assets/images/background.png')
    @game.load.atlasJSONHash('plane', 'assets/images/planes.png', 'assets/images/plane_fly.json')
    @game.load.atlasJSONHash('phone', 'assets/images/phone.png', 'assets/images/phone_tilt.json')
    @game.load.image('foreground', 'assets/images/groundGrass.png')
    @game.load.image('foreground', 'assets/images/groundGrass.png')
    @game.load.image('stalactite', 'assets/images/rockGrass.png')
    @game.load.image('getReady', 'assets/images/textGetReady.png')
    @game.load.image('gameOver', 'assets/images/textGameOver.png')
    @game.load.image('stalagmite', 'assets/images/rockGrassDown.png')
    @game.load.image('speaker', 'assets/images/speaker_on.png')
    @game.load.image('strings', 'assets/images/strings.png')
    @game.load.physics('physicsData', 'assets/images/package.json')
    @game.load.bitmapFont('numbers', 'assets/fonts/numbers.png', 'assets/fonts/numbers.xml')
    @game.load.bitmapFont('alphabet', 'assets/fonts/alphabet.png', 'assets/fonts/alphabet.xml')
    @game.load.audio('music', ['assets/audio/copycat.mp3'])


  create: ->
    @background = @game.add.tileSprite 0, 0, 800, 480, 'background'
    @strings = @game.add.sprite(-527, 180, 'strings')
#    @strings = @game.add.sprite(573, 180, 'strings')
    @plane = @game.add.sprite(-400, 185, 'plane')
#    @plane = @game.add.sprite(700, 185, 'plane')
    @title =  @game.add.bitmapText(-900, 150, 'alphabet',"WINGS", 120)
#    @title =  @game.add.bitmapText(200, 150, 'alphabet',"WINGS", 120)
    @instructions = @game.add.bitmapText(265, 285, 'alphabet',"TAP TO START", 36)
    @instructions2 = @game.add.bitmapText(228, 325, 'alphabet',"TILT PHONE TO FLY", 36)
    @instructions.alpha = 0
    @instructions2.alpha = 0
    @plane.animations.add('fly')
    @plane.animations.play('fly', 15, true)
    @phone = @game.add.sprite(362, 385, 'phone')
    @phone.animations.add('tilt')
    @phone.animations.play('tilt', 1, true)
    @phone.alpha = 0
    @speaker = @game.add.sprite(700, 365, 'speaker')
    @speaker.alpha = 0
    @game.add.tween(@title).to({ x: 200 }, 3000, Phaser.Easing.Linear.None).start()
    @game.add.tween(@plane).to({ x: 700 }, 3000, Phaser.Easing.Linear.None)
    .to({x:939}, 1000, Phaser.Easing.Linear.None).start()
    @game.add.tween(@strings).to({ x: 573 }, 3000, Phaser.Easing.Linear.None)
    .to({x:663, y:205, alpha:0}, 300, Phaser.Easing.Linear.None).start()
    @game.add.tween(@instructions).to({alpha:0}, 3000, Phaser.Easing.Linear.None)
    .to({alpha:1}, 300, Phaser.Easing.Linear.None).start()
    @game.add.tween(@phone).to({alpha:0}, 3000, Phaser.Easing.Linear.None)
    .to({alpha:1}, 300, Phaser.Easing.Linear.None).start()
    @game.add.tween(@instructions2).to({alpha:0}, 3000, Phaser.Easing.Linear.None)
    .to({alpha:1}, 300, Phaser.Easing.Linear.None).start()
    @game.add.tween(@speaker).to({alpha:0}, 3000, Phaser.Easing.Linear.None)
    .to({alpha:1}, 300, Phaser.Easing.Linear.None).start()

    if @game.scaleToFit
      @game.stage.scaleMode = Phaser.StageScaleMode.SHOW_ALL
      @game.stage.scale.setShowAll()
      @game.stage.scale.refresh()
  render: ->
    if @game.input.pointer1.isDown or @game.input.mousePointer.isDown then @_start()

  _start: ->
    @game.state.start('main')