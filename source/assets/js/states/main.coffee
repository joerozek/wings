class MainState extends Phaser.State
  constructor: -> super

  preload: ->
    @game.load.image('background', 'assets/images/background.png')
    @game.load.atlasJSONHash('plane', 'assets/images/planes.png', 'assets/images/plane_fly.json')
    @game.load.image('foreground', 'assets/images/groundGrass.png')
    @game.load.image('foreground', 'assets/images/groundGrass.png')
    @game.load.image('stalactite', 'assets/images/rockGrass.png')
    @game.load.image('getReady', 'assets/images/textGetReady.png')
    @game.load.image('gameOver', 'assets/images/textGameOver.png')
    @game.load.image('stalagmite', 'assets/images/rockGrassDown.png')
    @game.load.physics('physicsData', 'assets/images/package.json')
    @game.load.bitmapFont('numbers', 'assets/fonts/numbers.png', 'assets/fonts/numbers.xml')


  create: ->
    @debugText2 = {}
    @score = 0
    @scorableRocks = []
    @gameEnded = false
    gyro.frequency = 10

    @game.physics.startSystem(Phaser.Physics.P2JS)
    @game.physics.p2.setImpactEvents(true)

    @planeCollisionGroup = game.physics.p2.createCollisionGroup()
    @rockCollisionGroup = game.physics.p2.createCollisionGroup()
    @game.physics.p2.updateBoundsCollisionGroup()
    @background = @game.add.tileSprite 0, 0, 800, 480, 'background'
    @getReady = @game.add.sprite(200,190,'getReady')
    @count = 3
    @countDown = @game.add.bitmapText(360, 260, 'numbers',"#{@count}", 64);
    @gameOver = @game.add.sprite(200,210,'gameOver')
    @gameOver.visible = false
    @readyTimer = @game.time.events.loop(3000, @_hideGetReady, @)
    @countDownTimer = @game.time.events.loop(1000, @_countDown, @)

    @stalagmite = @_createRockGroup('stalagmite')
    @stalactite = @_createRockGroup('stalactite')

    @plane = @game.add.sprite(100, 200, 'plane')
    @plane.events.onOutOfBounds.add(@_gameOver, @)
    @game.physics.p2.enable(@plane)
    @plane.body.clearShapes()
    @plane.checkWorldBounds = true
    @plane.body.loadPolygon('physicsData', 'planeRed1')
    @plane.body.collideWorldBounds = false
    @plane.animations.add('fly')
    @plane.animations.play('fly', 15, true)
    @plane.body.setCollisionGroup(@planeCollisionGroup)
    @plane.body.collides(@rockCollisionGroup, (body1, body2) =>
      @_gameOver()
    , @)
    @_steady()

    @foreground = @game.add.tileSprite 0, 409, 808, 71, 'foreground'
    @foregroundTop = @game.add.tileSprite 800, 71, 808, 71, 'foreground'
    @foregroundTop.angle = 180
    @scoreText =  @game.add.bitmapText(680, 20, 'numbers',"#{@score}", 48)
    @debugText = @game.add.text(5, 5, "no gyro yet")
    @debugText2 = @game.add.text(5, 35, "no gyro yet")
    if @game.scaleToFit
      @game.stage.scaleMode = Phaser.StageScaleMode.SHOW_ALL
      @game.stage.scale.setShowAll()
      @game.stage.scale.refresh()

  update: ->
    @background.tilePosition.x += -1
    @foreground.tilePosition.x += -2.75
    @foregroundTop.tilePosition.x += 2.75
    @_updateScore()
    @_watchForKeyPress()

  render:() ->
    if @gameEnded and @game.input.pointer1.isDown then @_restart()

  _countDown:() ->
    console.log 'count down'
    @count--
    @countDown.setText("#{@count}" )
    if @count == 1 then @game.time.events.remove(@countDownTimer)

  _hideGetReady:() ->
    if gyro.getFeatures().length > 0
      gyro.stopTracking()
      gyro.startTracking (o) =>
        @debugText.setText("x: #{o.x.toFixed(1)}, y: #{o.y.toFixed(1)} z: #{o.z.toFixed(1)}" )
        @debugText2.setText("alpha: #{o.alpha.toFixed(1)}, beta: #{o.beta.toFixed(1)} gamma: #{o.gamma.toFixed(1)}" )
        if o.gamma <= 0 and o.gamma > -20
          @_down()
        else if o.gamma > 0 and o.gamma < 20
          @_up()
      gyro.calibrate()
    @game.time.events.remove(@readyTimer)
    @rockTimer = @game.time.events.loop(1500, @_addNewRockObsticle, @)
    @getReady.visible = false
    @countDown.visible = false

  _createRockGroup:(name, physicsData) ->
    group = @game.add.group()
    group.createMultiple(10, name)
    group.setAll('outOfBoundsKill', true)
    group.setAll('checkWorldBounds', true)
    group.setAll('enableBodyDebug', true)

    @game.physics.p2.enable(group)
    group.forEach (rock)=>
      rock.body.immovable = true
      rock.body.setZeroDamping()
      rock.body.fixedRotation = true
      rock.body.collideWorldBounds = false
    , @

    group

  _updateScore:() ->
    i = 0
    while i < @scorableRocks.length
      rock = @scorableRocks[i]
      if rock.body.x < @plane.body.x
        @score++
        @scoreText.setText "#{@score}"
        @scorableRocks.splice(i, 1)
      else
        i++

  _addRock:(x, y, group, physicsData) ->
    rock = group.getFirstDead()
    rock.body.clearShapes()
    rock.reset(x, y)
    rock.body.loadPolygon('physicsData', physicsData)
    rock.body.setCollisionGroup @rockCollisionGroup
    rock.body.collides(@planeCollisionGroup)
    rock.body.velocity.x = -130
    rock.body.gravity = 0
    @scorableRocks.push rock

  _addNewRockObsticle:()->
    top = Math.random()<.5
    group = {}
    physicsData = ""
    if top
      y = Math.random()* 135
      x=850
      group = @stalagmite
      physicsData = "rockGrassDown"
    else
      x=850
      y = Math.random()* (480 - 345) + 345
      group = @stalactite
      physicsData = "rockGrass"
    @_addRock(x, y, group, physicsData)
    return

  _gameOver:(plane, rocks) ->
    @gameEnded = true
    @gameOver.bringToTop()
    @gameOver.visible = true

    gyro.stopTracking()
    @game.time.events.remove(@rockTimer)

  _restart:() ->
    gyro.stopTracking()
    @game.time.events.remove(@rockTimer)
    @game.state.start('main')

  _watchForKeyPress:() ->
    if @game.input.keyboard.isDown(Phaser.Keyboard.UP)
      @_up()
    else if (game.input.keyboard.isDown(Phaser.Keyboard.DOWN))
      @_down()
    else
      @_steady()

    return

  _steady:() ->
    @plane.body.velocity.x = 0
    @plane.body.velocity.y = 0
    @plane.rotation = 0

  _up:() ->
#    @plane.body.velocity.x = -75
    @plane.body.velocity.y = -150
    @plane.body.angle = -10


   _down:() ->
#    @plane.body.velocity.x = 75
    @plane.body.velocity.y = 150
    @plane.body.angle = 10