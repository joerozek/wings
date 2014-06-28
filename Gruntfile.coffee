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
  grunt.loadNpmTasks('grunt-cordovacli')

  # Define Tasks
  grunt.registerTask('default', ['dist', 'server'])
  grunt.registerTask('cordova', ['dist', 'clean:www', 'copy:cordova'])
  grunt.registerTask('dist', ['clean:dist', 'copy:dist', 'copy:phaser', 'copy:gyro', 'stylesheets', 'scripts', 'jade'])
  grunt.registerTask('release', ['dist', 'uglify', 'clean:release'])
  grunt.registerTask('scripts', ['coffee', 'concat', 'clean:scripts'])
  grunt.registerTask('server', ['express', 'open', 'watch'])
  grunt.registerTask('stylesheets', ['stylus', 'autoprefixer', 'cssmin', 'clean:stylesheets'])

  pkg = grunt.file.readJSON('package.json')
  # Config
  grunt.config.init
    pkg: grunt.file.readJSON('package.json')

    autoprefixer:
      dist:
        expand: true
        cwd: 'dist'
        src: [ '**/*.css' ]
        dest: 'dist'

    clean:
      all:
        scripts:
          src: [ 'dist/assets/js/**/*' ]
        stylesheets:
          src: [ 'dist/assets/css/**/*' ]
      dist:
        src: ['dist']
      scripts:
        src: [ 'dist/assets/js/**/*', '!dist/assets/js/game.js', '!dist/assets/js/phaser.*', '!dist/assets/js/gyro.js']
      stylesheets:
        src: [ 'dist/assets/css/**/*', '!dist/assets/css/game.css' ]
      cordova:
        src: ['cordovaDist']
      www:
        src: ['cordovaDist/www/**/*']

    coffee:
      dist:
        options:
          bare: false
          join: true
        expand: true
        files:
          'dist/assets/js/game.js': [ 'source/assets/js/**/*.coffee' ]

    concat:
      dist:
        src: [ 'dist/**/*.js', '!dist/assets/js/phaser.*' ]
        dest: 'dist/assets/js/game.js'

    copy:
      dist:
        cwd: 'source'
        src: ['**', '!**/*.styl', '!**/*.coffee', '!**/*.jade']
        dest: 'dist'
        expand: true
      phaser:
        cwd: 'node_modules/Phaser/build'
        src: ['*.js']
        dest: 'dist/assets/js'
        expand: true
      gyro:
        cwd: 'bower_components/gyro.js/js'
        src: ['gyro.js']
        dest: 'dist/assets/js'
        expand: true
      cordova:
        cwd: 'dist'
        src: ['**/*.*']
        dest:'cordovaDist/www'
        expand:true

    cssmin:
      dist:
        files:
          'dist/assets/css/game.css': [ 'dist/**/*.css' ]

    express:
      server:
        options:
          port: 8000
          hostname: "*"
          bases: [ 'dist' ]
          livereload: true

    jade:
      compile:
        options:
          data: {}
        files: [{
          expand: true
          cwd: 'source'
          src: [ '**/*.jade' ]
          dest: 'dist'
          ext: '.html'
        }]

    open:
      dist:
        path: 'http://localhost:<%= express.server.options.port%>'

    stylus:
      dist:
        options:
          linenos: true
          compress: false
        files: [{
          expand: true
          cwd: 'source'
          src: [ '**/*.styl' ]
          dest: 'dist'
          ext: '.css'
        }]

    uglify:
      dist:
        options:
          mangle: false
        files:
          'dist/assets/js/game.js': [ 'dist/**/*.js' ]

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

    cordovacli:
      options:
        path: 'cordovaDist'
      create:
        options:
          command: ['create','platform','plugin']
          platforms: ['android']
          plugins: []
          id: 'com.arisota'
          name: 'Wings'
          description:"Wings - avoid rocks, don't crash"



    phonegap:
      config:
        root: 'dist'
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
          debuggable: true

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