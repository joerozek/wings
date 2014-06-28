(function() {
  var LogoSprite, MainState, TitleState,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.onload = function() {
    this.game = new Phaser.Game(800, 450, Phaser.CANVAS);
    this.game.state.add('title', new TitleState, true);
    return this.game.state.add('main', new MainState, false);
  };

  LogoSprite = (function(_super) {
    __extends(LogoSprite, _super);

    function LogoSprite() {
      LogoSprite.__super__.constructor.apply(this, arguments);
      this.anchor = {
        x: 0.5,
        y: 0.5
      };
    }

    return LogoSprite;

  })(Phaser.Sprite);

  MainState = (function(_super) {
    __extends(MainState, _super);

    function MainState() {
      MainState.__super__.constructor.apply(this, arguments);
    }

    MainState.prototype.create = function() {
      var _this = this;
      this.soundOff = false;
      if (parseInt(window.localStorage.getItem('audioSetting'), 10) === 1) {
        this.soundOff = true;
      }
      if (!this.soundOff) {
        this.audio = new Media('/android_asset/www/assets/audio/copycat.mp3');
        this.audio.play();
      }
      this.score = 0;
      this.scorableRocks = [];
      this.gameEnded = false;
      gyro.frequency = 15;
      this.highScore = window.localStorage.getItem("highScore") || 0;
      this.game.physics.startSystem(Phaser.Physics.P2JS);
      this.game.physics.p2.setImpactEvents(true);
      this.planeCollisionGroup = game.physics.p2.createCollisionGroup();
      this.rockCollisionGroup = game.physics.p2.createCollisionGroup();
      this.game.physics.p2.updateBoundsCollisionGroup();
      this.background = this.game.add.tileSprite(0, 0, 800, 480, 'background');
      this.getReady = this.game.add.sprite(200, 160, 'getReady');
      this.count = 3;
      this.countDown = this.game.add.bitmapText(360, 260, 'numbers', "" + this.count, 64);
      this.gameOver = this.game.add.sprite(200, 160, 'gameOver');
      this.gameOver.visible = false;
      this.readyTimer = this.game.time.events.loop(2250, this._hideGetReady, this);
      this.countDownTimer = this.game.time.events.loop(750, this._countDown, this);
      this.stalagmite = this._createRockGroup('stalagmite');
      this.stalactite = this._createRockGroup('stalactite');
      this.plane = this.game.add.sprite(100, 201, 'plane');
      this.plane.events.onOutOfBounds.add(this._gameOver, this);
      this.game.physics.p2.enable(this.plane);
      this.plane.body.clearShapes();
      this.plane.checkWorldBounds = true;
      this.plane.body.loadPolygon('physicsData', 'planeRed1');
      this.plane.body.collideWorldBounds = false;
      this.plane.animations.add('fly');
      this.plane.animations.play('fly', 15, true);
      this.plane.body.setCollisionGroup(this.planeCollisionGroup);
      this.plane.body.collides(this.rockCollisionGroup, function(body1, body2) {
        return _this._gameOver();
      }, this);
      this._steady();
      this.foreground = this.game.add.tileSprite(0, 379, 808, 71, 'foreground');
      this.foregroundTop = this.game.add.tileSprite(800, 71, 808, 71, 'foreground');
      this.foregroundTop.angle = 180;
      this.scoreText = this.game.add.bitmapText(730, 15, 'numbers', "" + this.score, 30);
      this.highScoreLabel = this.game.add.bitmapText(20, 15, 'alphabet', "HIGH SCORE", 32);
      this.highScoreText = this.game.add.bitmapText(220, 17, 'numbers', "" + this.highScore, 30);
      if (this.game.scaleToFit) {
        this.game.stage.scaleMode = Phaser.StageScaleMode.SHOW_ALL;
        this.game.stage.scale.setShowAll();
        return this.game.stage.scale.refresh();
      }
    };

    MainState.prototype.update = function() {
      this.background.tilePosition.x += -2;
      this.foreground.tilePosition.x += -6.75;
      this.foregroundTop.tilePosition.x += 6.75;
      if (!this.gameEnded) {
        return this._updateScore();
      }
    };

    MainState.prototype._countDown = function() {
      this.count--;
      this.countDown.setText("" + this.count);
      if (this.count === 1) {
        return this.game.time.events.remove(this.countDownTimer);
      }
    };

    MainState.prototype._hideGetReady = function() {
      var _this = this;
      if (gyro.getFeatures().length > 0) {
        gyro.startTracking(function(o) {
          if (o.gamma <= 0 && o.gamma > -20) {
            return _this._down();
          } else if (o.gamma > 0 && o.gamma < 20) {
            return _this._up();
          }
        });
        gyro.calibrate();
      }
      this.game.time.events.remove(this.readyTimer);
      this.rockTimer = this.game.time.events.loop(600, this._addNewRockObsticle, this);
      this.getReady.visible = false;
      return this.countDown.visible = false;
    };

    MainState.prototype._createRockGroup = function(name, physicsData) {
      var group,
        _this = this;
      group = this.game.add.group();
      group.createMultiple(10, name);
      group.setAll('outOfBoundsKill', true);
      group.setAll('checkWorldBounds', true);
      group.setAll('enableBodyDebug', true);
      this.game.physics.p2.enable(group);
      group.forEach(function(rock) {
        rock.body.immovable = true;
        rock.body.setZeroDamping();
        rock.body.fixedRotation = true;
        return rock.body.collideWorldBounds = false;
      }, this);
      return group;
    };

    MainState.prototype._updateScore = function() {
      var i, rock, _results;
      i = 0;
      _results = [];
      while (i < this.scorableRocks.length) {
        rock = this.scorableRocks[i];
        if (rock.body.x < this.plane.body.x) {
          this.score++;
          this.scoreText.setText("" + this.score);
          if (!(this.highScore >= this.score)) {
            this.highScore = this.score;
          }
          this.highScoreText.setText("" + this.highScore);
          _results.push(this.scorableRocks.splice(i, 1));
        } else {
          _results.push(i++);
        }
      }
      return _results;
    };

    MainState.prototype._addRock = function(x, y, group, physicsData) {
      var rock;
      rock = group.getFirstDead();
      rock.body.clearShapes();
      rock.reset(x, y);
      rock.body.loadPolygon('physicsData', physicsData);
      rock.body.setCollisionGroup(this.rockCollisionGroup);
      rock.body.collides(this.planeCollisionGroup);
      rock.body.velocity.x = -390;
      rock.body.gravity = 0;
      return this.scorableRocks.push(rock);
    };

    MainState.prototype._addNewRockObsticle = function() {
      var group, physicsData, prob, x, y;
      prob = Math.random();
      group = {};
      physicsData = "";
      if (prob > .7) {
        y = Math.random() * (105 - 30) + 30;
        x = 850;
        group = this.stalagmite;
        physicsData = "rockGrassDown";
        this._addRock(x, y, group, physicsData);
      } else if (prob > .4) {
        x = 850;
        y = Math.random() * (420 - 375) + 375;
        group = this.stalactite;
        physicsData = "rockGrass";
        this._addRock(x, y, group, physicsData);
      } else if (prob > .1) {
        y = Math.random() * (45 - 15) + 15;
        x = 850;
        group = this.stalagmite;
        physicsData = "rockGrassDown";
        this._addRock(x, y, group, physicsData);
        x = 850;
        y = y + Math.random() * (420 - 395) + 395;
        group = this.stalactite;
        physicsData = "rockGrass";
        this._addRock(x, y, group, physicsData);
      }
    };

    MainState.prototype._gameOver = function(plane, rocks) {
      var backButton, restartButton,
        _this = this;
      if (!this.gameEnded) {
        this.gameEnded = true;
        if (!this.soundOff) {
          this.audio.seekTo(159000);
          setTimeout(function() {
            _this.audio.stop();
            return _this.audio.release();
          }, 1000);
        }
        if (this.score > this.highScore) {
          this.highScore = this.score;
        }
        window.localStorage.setItem('highScore', this.highScore);
        this.gameOver.bringToTop();
        this.gameOver.visible = true;
        restartButton = this.game.add.button(440, 260, 'transparent', this._restart, this);
        restartButton.width = 160;
        restartButton.height = 40;
        backButton = this.game.add.button(240, 260, 'transparent', this._title, this);
        backButton.width = 100;
        backButton.height = 40;
        this.restartText = this.game.add.bitmapText(440, 260, 'alphabet-red', "RESTART");
        this.backText = this.game.add.bitmapText(240, 260, 'alphabet-red', "BACK");
      }
      gyro.stopTracking();
      return this.game.time.events.remove(this.rockTimer);
    };

    MainState.prototype._restart = function() {
      this.game.time.events.remove(this.rockTimer);
      return this.game.state.start('main');
    };

    MainState.prototype._title = function() {
      this.game.time.events.remove(this.rockTimer);
      return this.game.state.start('title');
    };

    MainState.prototype._watchForKeyPress = function() {
      if (this.game.input.keyboard.isDown(Phaser.Keyboard.UP)) {
        this._up();
      } else if (game.input.keyboard.isDown(Phaser.Keyboard.DOWN)) {
        this._down();
      }
    };

    MainState.prototype._steady = function() {
      this.plane.body.velocity.x = 0;
      this.plane.body.velocity.y = 0;
      return this.plane.rotation = 0;
    };

    MainState.prototype._up = function() {
      this.plane.body.velocity.y = -200;
      return this.plane.body.angle = -10;
    };

    MainState.prototype._down = function() {
      this.plane.body.velocity.y = 200;
      return this.plane.body.angle = 10;
    };

    return MainState;

  })(Phaser.State);

  TitleState = (function(_super) {
    __extends(TitleState, _super);

    function TitleState() {
      TitleState.__super__.constructor.apply(this, arguments);
    }

    TitleState.prototype.preload = function() {
      this.game.load.image('background', 'assets/images/background.png');
      this.game.load.atlasJSONHash('plane', 'assets/images/planes.png', 'assets/images/plane_fly.json');
      this.game.load.atlasJSONHash('phone', 'assets/images/phone.png', 'assets/images/phone_tilt.json');
      this.game.load.image('foreground', 'assets/images/groundGrass.png');
      this.game.load.image('stalactite', 'assets/images/rockGrass.png');
      this.game.load.image('getReady', 'assets/images/textGetReady.png');
      this.game.load.image('transparent', 'assets/images/transparent.png');
      this.game.load.spritesheet('audioButton', 'assets/images/speaker_on_off.png', 85, 85);
      this.game.load.image('gameOver', 'assets/images/textGameOver.png');
      this.game.load.image('stalagmite', 'assets/images/rockGrassDown.png');
      this.game.load.image('strings', 'assets/images/strings.png');
      this.game.load.physics('physicsData', 'assets/images/physics-simple.json');
      this.game.load.bitmapFont('numbers', 'assets/fonts/numbers.png', 'assets/fonts/numbers.xml');
      this.game.load.bitmapFont('alphabet', 'assets/fonts/alphabet.png', 'assets/fonts/alphabet.xml');
      this.game.load.bitmapFont('alphabet-red', 'assets/fonts/alphabet-red.png', 'assets/fonts/alphabet.xml');
      this.audio = new Media('assets/audio/copycat.mp3');
      this.game.scale.scaleMode = Phaser.ScaleManager.SHOW_ALL;
      return this.game.scale.setScreenSize();
    };

    TitleState.prototype.create = function() {
      if (window.localStorage.getItem('audioSetting') != null) {
        this.soundOff = window.localStorage.getItem('audioSetting');
      } else {
        this.soundOff = 0;
      }
      this.background = this.game.add.tileSprite(0, 0, 800, 480, 'background');
      this.strings = this.game.add.sprite(-527, 180, 'strings');
      this.plane = this.game.add.sprite(-400, 185, 'plane');
      this.title = this.game.add.bitmapText(-900, 150, 'alphabet-red', "WINGS", 120);
      this.instructions = this.game.add.bitmapText(265, 285, 'alphabet', "TAP TO START", 36);
      this.instructions2 = this.game.add.bitmapText(228, 325, 'alphabet', "TILT PHONE TO FLY", 36);
      this.instructions.alpha = 0;
      this.instructions2.alpha = 0;
      this.plane.animations.add('fly');
      this.plane.animations.play('fly', 15, true);
      this.phone = this.game.add.sprite(362, 385, 'phone');
      this.phone.animations.add('tilt');
      this.phone.animations.play('tilt', 1, true);
      this.phone.alpha = 0;
      this.startButton = this.game.add.button(0, 0, 'transparent', this._start, this);
      this.startButton.width = 800;
      this.startButton.height = 450;
      this.speaker = this.game.add.button(700, 365, 'audioButton', this._toggleAudio, this);
      this.speaker.alpha = 0;
      this.speaker.frame = this.soundOff;
      this.game.add.tween(this.title).to({
        x: 200
      }, 3000, Phaser.Easing.Linear.None).start();
      this.game.add.tween(this.plane).to({
        x: 700
      }, 3000, Phaser.Easing.Linear.None).to({
        x: 939
      }, 1000, Phaser.Easing.Linear.None).start();
      this.game.add.tween(this.strings).to({
        x: 573
      }, 3000, Phaser.Easing.Linear.None).to({
        x: 663,
        y: 205,
        alpha: 0
      }, 300, Phaser.Easing.Linear.None).start();
      this.game.add.tween(this.instructions).to({
        alpha: 0
      }, 3000, Phaser.Easing.Linear.None).to({
        alpha: 1
      }, 300, Phaser.Easing.Linear.None).start();
      this.game.add.tween(this.phone).to({
        alpha: 0
      }, 3000, Phaser.Easing.Linear.None).to({
        alpha: 1
      }, 300, Phaser.Easing.Linear.None).start();
      this.game.add.tween(this.instructions2).to({
        alpha: 0
      }, 3000, Phaser.Easing.Linear.None).to({
        alpha: 1
      }, 300, Phaser.Easing.Linear.None).start();
      this.game.add.tween(this.speaker).to({
        alpha: 0
      }, 3000, Phaser.Easing.Linear.None).to({
        alpha: 1
      }, 300, Phaser.Easing.Linear.None).start();
      if (this.game.scaleToFit) {
        this.game.stage.scaleMode = Phaser.StageScaleMode.SHOW_ALL;
        this.game.stage.scale.setShowAll();
        return this.game.stage.scale.refresh();
      }
    };

    TitleState.prototype.render = function() {};

    TitleState.prototype._start = function() {
      return this.game.state.start('main');
    };

    TitleState.prototype._toggleAudio = function() {
      this.soundOff++;
      this.soundOff = this.soundOff % 2;
      window.localStorage.setItem('audioSetting', this.soundOff);
      return this.speaker.frame = this.soundOff;
    };

    return TitleState;

  })(Phaser.State);

}).call(this);

/**
 * A JavaScript project for accessing the accelerometer and gyro from various devices
 *
 * @author Tom Gallacher <tom.gallacher23@gmail.com>
 * @copyright Tom Gallacher <http://www.tomg.co>
 * @version 0.0.1a
 * @license MIT License
 * @options frequency, callback
 */
(function (root, factory) {
		if (typeof define === 'function' && define.amd) {
				// AMD. Register as an anonymous module.
				define(factory);
		} else if (typeof exports === 'object') {
				// Node. Does not work with strict CommonJS, but
				// only CommonJS-like enviroments that support module.exports,
				// like Node.
				module.exports = factory();
		} else {
				// Browser globals (root is window)
				root.returnExports = factory();
	}
}(this, function () {
	var measurements = {
				x: null,
				y: null,
				z: null,
				alpha: null,
				beta: null,
				gamma: null
			},
			calibration = {
				x: 0,
				y: 0,
				z: 0,
				alpha: 0,
				beta: 0,
				gamma: 0
			},
			interval = null,
			features = [];

	var gyro = {};

	/**
	 * @public
	 */
    window.gyro = gyro;
	gyro.frequency = 500; //ms

	gyro.calibrate = function() {
		for (var i in measurements) {

			calibration[i] = (typeof measurements[i] === 'number') ? measurements[i] : 0;
		}
	};

	gyro.getOrientation = function() {
		return measurements;
	};

	gyro.startTracking = function(callback) {
		interval = setInterval(function() {
			callback(measurements);
		}, gyro.frequency);
	};

	gyro.stopTracking = function() {
        calibration = {
            x: 0,
            y: 0,
            z: 0,
            alpha: 0,
            beta: 0,
            gamma: 0
        };
		clearInterval(interval);
	};

	/**
	 * Current available features are:
	 * MozOrientation
	 * devicemotion
	 * deviceorientation
	 */
	gyro.hasFeature = function(feature) {
		for (var i in features) {
			if (feature == features[i]) {
				return true;
			}
		}
		return false;
	};

	gyro.getFeatures = function() {
		return features;
	};


	/**
	 * @private
	 */
	// it doesn't make sense to depend on a "window" module
	// since deviceorientation & devicemotion make just sense in the browser
	// so old school test used.
	if (window && window.addEventListener) {
		function setupListeners() {
			window.addEventListener('MozOrientation', function(e) {
				features.push('MozOrientation');
				measurements.x = e.x - calibration.x;
				measurements.y = e.y - calibration.y;
				measurements.z = e.z - calibration.z;
			}, true);

			window.addEventListener('devicemotion', function(e) {
				features.push('devicemotion');
				measurements.x = e.accelerationIncludingGravity.x - calibration.x;
				measurements.y = e.accelerationIncludingGravity.y - calibration.y;
				measurements.z = e.accelerationIncludingGravity.z - calibration.z;
			}, true);

			window.addEventListener('deviceorientation', function(e) {
				features.push('deviceorientation');
				measurements.alpha = e.alpha - calibration.alpha;
				measurements.beta = e.beta - calibration.beta;
				measurements.gamma = e.gamma - calibration.gamma;
			}, true);
		}
		setupListeners();
	}

	return gyro;
}));
