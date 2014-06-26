module.exports = (grunt) ->
  'use strict'

  # Load Tasks
  grunt.loadNpmTasks('grunt-autoprefixer')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-cssmin')
  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-stylus')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-express')
  grunt.loadNpmTasks('grunt-open')
  grunt.loadNpmTasks('grunt-phonegap')

  # Define Tasks
  grunt.registerTask('default', ['build', 'server'])
  grunt.registerTask('build', ['clean:build', 'copy', 'stylesheets', 'scripts', 'jade'])
  grunt.registerTask('release', ['build', 'uglify', 'clean:release'])
  grunt.registerTask('scripts', ['coffee', 'concat', 'clean:scripts'])
  grunt.registerTask('server', ['express', 'open', 'watch'])
  grunt.registerTask('stylesheets', ['stylus', 'autoprefixer', 'cssmin', 'clean:stylesheets'])

  pkg = grunt.file.readJSON('package.json')
  # Config
  grunt.config.init
    pkg: grunt.file.readJSON('package.json')

    autoprefixer:
      build:
        expand: true
        cwd: 'build'
        src: [ '**/*.css' ]
        dest: 'build'

    clean:
      all:
        scripts:
          src: [ 'build/assets/js/**/*' ]
        stylesheets:
          src: [ 'build/assets/css/**/*' ]
      build:
        src: ['build']
      scripts:
        src: [ 'build/assets/js/**/*', '!build/assets/js/game.js', '!build/assets/js/phaser.*' ]
      stylesheets:
        src: [ 'build/assets/css/**/*', '!build/assets/css/game.css' ]

    coffee:
      build:
        options:
          bare: false
          join: true
        expand: true
        files:
          'build/assets/js/game.js': [ 'source/assets/js/**/*.coffee' ]

    concat:
      build:
        src: [ 'build/**/*.js', '!build/assets/js/phaser.*', 'builfd' ]
        dest: 'build/assets/js/game.js'

    copy:
      build:
        cwd: 'source'
        src: ['**', '!**/*.styl', '!**/*.coffee', '!**/*.jade']
        dest: 'build'
        expand: true
      phaser:
        cwd: 'node_modules/Phaser/build'
        src: ['*.js']
        dest: 'build/assets/js'
        expand: true
      gyro:
        cwd: 'node_modules/Phaser/build'
        src: ['*.js']
        dest: 'build/assets/js'
        expand: true
    cssmin:
      build:
        files:
          'build/assets/css/game.css': [ 'build/**/*.css' ]

    express:
      server:
        options:
          port: 8000
          hostname: "*"
          bases: [ 'build', 'bower_components' ]
          livereload: true

    jade:
      compile:
        options:
          data: {}
        files: [{
          expand: true
          cwd: 'source'
          src: [ '**/*.jade' ]
          dest: 'build'
          ext: '.html'
        }]

    open:
      build:
        path: 'http://localhost:<%= express.server.options.port%>'

    stylus:
      build:
        options:
          linenos: true
          compress: false
        files: [{
          expand: true
          cwd: 'source'
          src: [ '**/*.styl' ]
          dest: 'build'
          ext: '.css'
        }]

    uglify:
      build:
        options:
          mangle: false
        files:
          'build/assets/js/game.js': [ 'build/**/*.js' ]

    watch:
      stylesheets:
        files: 'source/**/*.styl'
        tasks: [ 'clean:all:stylesheets', 'stylesheets' ]
        options:
          livereload: true
      scripts:
        files: 'source/**/*.coffee'
        tasks: [ 'clean:all:scripts', 'scripts' ]
        options:
          livereload: true
      jade:
        files: 'source/**/*.jade'
        tasks: [ 'jade' ]
        options:
          livereload: true
      copy:
        files: [ 'source/**', '!source/**/*.styl', '!source/**/*.coffee', '!source/**/*.jade' ]
        tasks: [ 'copy' ]

    phonegap:
      config:
        root: 'www'
        config:
          template: '_myConfig.xml'
          data:
            id: 'com.arisota'
            version: pkg.version
            name: pkg.name
          cordova: '.cordova'
          html : 'index.html' # (Optional) You may change this to any other.html
          path: 'phonegap'
          plugins: []
          platforms: ['android']
          maxBuffer: 200 # You may need to raise this for iOS.
          verbose: false
          releases: 'releases'
          releaseName: ->
            pkg.name + '-' + pkg.version
          debuggable: false

          # Must be set for ios to work.
          #Should return the app name.
          name: ->
            pkg = grunt.file.readJSON('package.json')
            pkg.name

          # Add a key if you plan to use the `release:android` task
          # See http://developer.android.com/tools/publishing/app-signing.html
          key:
            store: 'release.keystore'
            alias: 'release'
            aliasPassword: ->
              #Prompt, read an environment variable, or just embed as a string literal
              ''

            storePassword: ->
              # Prompt, read an environment variable, or just embed as a string literal
              ''

          # Set an app icon at various sizes (optional)
          icons:
            android:
              ldpi: 'icon-36-ldpi.png'
              mdpi: 'icon-48-mdpi.png'
              hdpi: 'icon-72-hdpi.png'
              xhdpi: 'icon-96-xhdpi.png'
    #      wp8: {
    #        app: 'icon-62-tile.png',
    #        tile: 'icon-173-tile.png'
    #      },
    #      ios: {
    #        icon29: 'icon29.png',
    #        icon29x2: 'icon29x2.png',
    #        icon40: 'icon40.png',
    #        icon40x2: 'icon40x2.png',
    #        icon57: 'icon57.png',
    #        icon57x2: 'icon57x2.png',
    #        icon60x2: 'icon60x2.png',
    #        icon72: 'icon72.png',
    #        icon72x2: 'icon72x2.png',
    #        icon76: 'icon76.png',
    #        icon76x2: 'icon76x2.png'
    #      }
    #    },


        # Android-only integer version to increase with each release.
        # See http://developer.android.com/tools/publishing/versioning.html
        versionCode: -> 1

        # Android-only options that will override the defaults set by Phonegap in the
        # generated AndroidManifest.xml
        # See https://developer.android.com/guide/topics/manifest/uses-sdk-element.html
        minSdkVersion: -> 10
        targetSdkVersion: -> 19

        # iOS7-only options that will make the status bar white and transparent
        #iosStatusBar: 'WhiteAndTransparent',

    #    // If you want to use the Phonegap Build service to build one or more
    #    // of the platforms specified above, include these options.
    #    // See https://build.phonegap.com/
    #  remote: {
    #    username: 'your_username',
    #    password: 'your_password',
    #    platforms: ['android', 'blackberry', 'ios', 'symbian', 'webos', 'wp7']
    #  },
    #
    #    // Set an explicit Android permissions list to override the automatic plugin defaults.
    #    // In most cases, you should omit this setting. See 'Android Permissions' in README.md for details.
    #  permissions: ['INTERNET', 'ACCESS_COURSE_LOCATION', '...']
    #    }
    #    }