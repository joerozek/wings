class MainState extends Phaser.State
  constructor: -> super

  preload: ->
    @game.load.image('background', 'assets/images/background.png')
    @game.load.atlasJSONHash('plane', 'assets/images/planes.png', 'assets/images/plane_fly.json')
    @game.load.image('foreground', 'assets/images/groundGrass.png')
    @game.load.image('stalactite', 'assets/images/rockGrass.png')
    @game.load.image('getReady', 'assets/images/textGetReady.png')
    @game.load.image('gameOver', 'assets/images/textGameOver.png')
    @game.load.image('stalagmite', 'assets/images/rockGrassDown.png')
    @game.load.physics('physicsData', 'assets/images/package.json')

  create: ->
    @gameEnded = false

    @game.physics.startSystem(Phaser.Physics.P2JS)
    @game.physics.p2.setImpactEvents(true)

    @planeCollisionGroup = game.physics.p2.createCollisionGroup()
    @rockCollisionGroup = game.physics.p2.createCollisionGroup()
    @game.physics.p2.updateBoundsCollisionGroup()
    @background = @game.add.tileSprite 0, 0, 800, 480, 'background'
    @getReady = @game.add.sprite(200,210,'getReady')
    @gameOver = @game.add.sprite(200,210,'gameOver')
    @gameOver.visible = false
    @readyTimer = @game.time.events.loop(2000, @_hideGetReady, @)
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
    if @game.scaleToFit
      @game.stage.scaleMode = Phaser.StageScaleMode.SHOW_ALL
      @game.stage.scale.setShowAll()
      @game.stage.scale.refresh()


  update: ->
    @background.tilePosition.x += -1
    @foreground.tilePosition.x += -2.75
    @foregroundTop.tilePosition.x += 2.75
#    @_watchForKeyPress()

  render:() ->
    if @gameEnded and @game.input.pointer1.isDown then @_restart()

  _hideGetReady:() ->
    if gyro.getFeatures().length > 0
      gyro.frequency = 10
      gyro.startTracking (o) =>
        if (o.x > -5.5)
          @_up()
        else
          @_down()
    else
      @gamOver.visible = true;

    @game.time.events.remove(@readyTimer)
    @rockTimer = @game.time.events.loop(1500, @_addNewRockObsticle, @)
    @getReady.visible = false

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

  _addRock:(x, y, group, physicsData) ->
    @rock = rock
    rock = group.getFirstDead()
    rock.body.clearShapes()
    rock.reset(x, y)
    rock.body.loadPolygon('physicsData', physicsData)
    rock.body.setCollisionGroup @rockCollisionGroup
    rock.body.collides(@planeCollisionGroup)
    rock.body.velocity.x = -130
    rock.body.gravity = 0

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

  _down:() ->
#    @plane.body.velocity.x = -75
    @plane.body.velocity.y = -150
    @plane.body.angle = -10

  _up:() ->
#    @plane.body.velocity.x = 75
    @plane.body.velocity.y = 150
    @plane.body.angle = 10