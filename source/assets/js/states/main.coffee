class MainState extends Phaser.State
  constructor: -> super

  create: ->
    @soundOff = false
    if (parseInt(window.localStorage.getItem('audioSetting'), 10) == 1) then @soundOff = true
    unless @soundOff
      @audio = new Media('/android_asset/www/assets/audio/copycat.mp3')
      @audio.play()

    @score = 0
    @scorableRocks = []
    @gameEnded = false
    gyro.frequency = 15
    @highScore = window.localStorage.getItem("highScore") || 0

    @game.physics.startSystem(Phaser.Physics.P2JS)
    @game.physics.p2.setImpactEvents(true)

    @planeCollisionGroup = game.physics.p2.createCollisionGroup()
    @rockCollisionGroup = game.physics.p2.createCollisionGroup()
    @game.physics.p2.updateBoundsCollisionGroup()
    @background = @game.add.tileSprite 0, 0, 800, 480, 'background'
    @getReady = @game.add.sprite(200,160,'getReady')
    @count = 3
    @countDown = @game.add.bitmapText(360, 260, 'numbers',"#{@count}", 64)
    @gameOver = @game.add.sprite(200,160,'gameOver')
    @gameOver.visible = false
    @readyTimer = @game.time.events.loop(2250, @_hideGetReady, @)
    @countDownTimer = @game.time.events.loop(750, @_countDown, @)

    @stalagmite = @_createRockGroup('stalagmite')
    @stalactite = @_createRockGroup('stalactite')

    @plane = @game.add.sprite(100, 201, 'plane')
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

    @foreground = @game.add.tileSprite 0, 379, 808, 71, 'foreground'
    @foregroundTop = @game.add.tileSprite 800, 71, 808, 71, 'foreground'
    @foregroundTop.angle = 180
    @scoreText =  @game.add.bitmapText(730, 15, 'numbers',"#{@score}", 30)
    @highScoreLabel =  @game.add.bitmapText(20, 15, 'alphabet',"HIGH SCORE", 32)
    @highScoreText =  @game.add.bitmapText(220, 17, 'numbers',"#{@highScore}", 30)
    if @game.scaleToFit
      @game.stage.scaleMode = Phaser.StageScaleMode.SHOW_ALL
      @game.stage.scale.setShowAll()
      @game.stage.scale.refresh()

  update: ->
    @background.tilePosition.x += -2
    @foreground.tilePosition.x += -6.75
    @foregroundTop.tilePosition.x += 6.75
    @_updateScore() unless @gameEnded
#    @_watchForKeyPress()

  _countDown:() ->
    @count--
    @countDown.setText("#{@count}" )
    if @count == 1 then @game.time.events.remove(@countDownTimer)

  _hideGetReady:() ->
    if gyro.getFeatures().length > 0
      gyro.startTracking (o) =>
        if o.gamma <= 0 and o.gamma > -20
          @_down()
        else if o.gamma > 0 and o.gamma < 20
          @_up()
      gyro.calibrate()

    @game.time.events.remove(@readyTimer)
    @rockTimer = @game.time.events.loop(600, @_addNewRockObsticle, @)
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
        @highScore = @score unless @highScore >= @score
        @highScoreText.setText "#{@highScore}"
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
    rock.body.velocity.x = -390
    rock.body.gravity = 0
    @scorableRocks.push rock

  _addNewRockObsticle:()->
    prob = Math.random()
    group = {}
    physicsData = ""
    if prob > .7
      y = Math.random()* (105 - 30) + 30
      x=850
      group = @stalagmite
      physicsData = "rockGrassDown"
      @_addRock(x, y, group, physicsData)
    else if prob > .4
      x=850
      y = Math.random()* (420 - 375) + 375
      group = @stalactite
      physicsData = "rockGrass"
      @_addRock(x, y, group, physicsData)
    else if prob > .1
      y = Math.random()* (45 - 15) + 15
      x=850
      group = @stalagmite
      physicsData = "rockGrassDown"
      @_addRock(x, y, group, physicsData)
      x=850
      y = y+ Math.random()* (420 - 395) + 395
      group = @stalactite
      physicsData = "rockGrass"
      @_addRock(x, y, group, physicsData)
#    else
      #star
    return

  _gameOver:(plane, rocks) ->
    unless @gameEnded
      @gameEnded = true
      unless @soundOff
        @audio.seekTo(159000)
        setTimeout(=>
          @audio.stop()
          @audio.release()
        , 1000)
#      @music.play('gameover',0,1,false) unless @soundOff
      if @score > @highScore then @highScore = @score
      window.localStorage.setItem('highScore', @highScore)
      @gameOver.bringToTop()
      @gameOver.visible = true
      restartButton = @game.add.button(440, 260, 'transparent', @_restart, @)
      restartButton.width = 160
      restartButton.height = 40
      backButton = @game.add.button(240, 260, 'transparent', @_title, @)
      backButton.width = 100
      backButton.height = 40
      @restartText = @game.add.bitmapText(440, 260, 'alphabet-red', "RESTART")
      @backText = @game.add.bitmapText(240, 260, 'alphabet-red', "BACK")

    gyro.stopTracking()
    @game.time.events.remove(@rockTimer)

  _restart:() ->
    @game.time.events.remove(@rockTimer)
    @game.state.start('main')

  _title:() ->
    @game.time.events.remove(@rockTimer)
    @game.state.start('title')

  _watchForKeyPress:() ->
    if @game.input.keyboard.isDown(Phaser.Keyboard.UP)
      @_up()
    else if (game.input.keyboard.isDown(Phaser.Keyboard.DOWN))
      @_down()
    return

  _steady:() ->
    @plane.body.velocity.x = 0
    @plane.body.velocity.y = 0
    @plane.rotation = 0

  _up:() ->
    @plane.body.velocity.y = -200
    @plane.body.angle = -10

   _down:() ->
    @plane.body.velocity.y = 200
    @plane.body.angle = 10