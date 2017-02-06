module.exports = function(grunt) {

    grunt.initConfig({
        connect: {
            server: {
                options: {
                    protocol: 'https', // or 'http2'
                    port: 8080,
                    keepalive: true

                }
            }
        },

        // Grunt Tasks
        less: {
            dist: {
                options: {},
                files: {
                    "dist/css/site.css": "assets/**/*.less"
                }
            }
        },
        copy: {
            angular: {
                src: ['bower_components/angular/angular.js',
                      'bower_components/angular/angular.min.js',
                      'bower_components/bootstrap/dist/**/*',
                      'bower_components/jquery/dist/jquery.min.js',
                      'bower_components/jquery-ui/jquery-ui.min.js'
                      ],
                cwd: '.',
                expand: true,
                dest: 'dist/'
            },
            html: {
                src: ['src/form.html'],
                cwd: '.',
                expand: true,
                dest: 'dist/app/'
            },
            index: {
                src: 'index.html',
                cwd: '.',
                expand: true,
                dest: 'dist/'
            }
        },
        uglify: {
            dist: {
                options: {
                    preserveComments: 'some'
                },
                files: {
                    'dist/js/app.min.js': 'dist/js/app.js'
                }
            }
        },
        ts: {
            dev: {
                tsconfig: true
            }
        },
        cssmin: {
            dist: {
                files: [{
                    expand: true,
                    cwd: 'dist/css/',
                    src: ['*.css', '!*.min.css'],
                    dest: 'dist/css/',
                    ext: '.min.css'
                }]
            }
        },
        clean: ['dist']


    });
    grunt.loadNpmTasks('grunt-contrib-connect');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-cssmin');
    grunt.loadNpmTasks('grunt-contrib-less');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks("grunt-ts");


    // Default task.
    grunt.registerTask('default', ['clean', 'less', 'ts:dev', 'copy', 'uglify','cssmin']);

};