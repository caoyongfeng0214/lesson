// *************************************************************
// docs: http://gulpjs.com/
// npm install --global gulp-cli
// cd YOUR_PROJECT_DIR
// npm install

// *************************************************************


var gulp = require('gulp');
var less = require('gulp-less');
var mincss = require('gulp-minify-css');
var uglify = require('gulp-uglify');
var htmlmin = require('gulp-htmlmin');
var concat = require('gulp-concat');
var rename = require('gulp-rename');
var chmod = require('gulp-chmod');
var pump = require('pump');
var del = require('del');
var path = require('path');
var exec = require('child_process').exec;
var through = require('through-gulp');
var treeKill = require('tree-kill');



var server_thread = null;


var killServer = function (callbackFun) {
    if (server_thread) {
        //exec('taskkill /pid ' + server_pid + ' /f', function (err, stdout, stderr) {
        //    console.log('END');
        //});

        //exec('taskkill', ['/pid', server_thread.pid, '/f', '/t'], function (err, stdout, stderr) {
        //    console.log('END');
        //});

        //server_thread.stdin.pause();
        //server_thread.kill('SIGQUIT');

        treeKill(server_thread.pid, 'SIGKILL', function () {
            console.log('SERVER KILLED');
            callbackFun();
        });
    } else {
        callbackFun();
    }
};

var startServer = function () {
    server_thread = exec('npls bin/www.npl', function (err, stdout, stderr) {
        
    });
    server_thread.stdout.on('data', function (data) {
        console.log(data.toString());
    });
    console.log('SERVER STARTED');
};

var restartServer = function () {
    killServer(function () {
        startServer();
    });
};



function pretreatment(extname) {
    switch(extname) {
        case '.js':
            return uglify();
        case '.less':
            return less();
        case '.htm':
        case '.html':
            return htmlmin({
                removeComments: true,
                collapseWhitespace: true,
                minifyJS: true,
                minifyCSS: true
            });
        default:
            return null;
    }
};


var get_dest_path = function (src) {
    var str0 = path.resolve('public_dev');
    var str1 = path.relative(str0, src);
    var str2 = path.resolve('public', str1);
    return str2;
};

var copy_to_dest = function (src) {
    var dest_path = get_dest_path(src);
    var extension = path.extname(src);
    
    var pres = pretreatment(extension);
    var ary = [gulp.src(src)];
    if (pres) {
        ary.push(pres);
    }
    //var p = gulp.src(src).pipe(pretreatment(extension));
    switch (extension) {
        case '.less':
            //p = p.pipe(mincss());
            ary.push(mincss());
            break;
    }
    //p.pipe(gulp.dest(path.dirname(dest_path)));
    ary.push(gulp.dest(path.dirname(dest_path)));

    pump(ary, function (err) {
        if (err) {
            console.log('PUMP');
            console.log(arguments);
        }
    });
};


gulp.task('watch', function () {
    restartServer();

    var watcher = gulp.watch('public_dev/**/*.*', gulp.parallel(function (done) {
        done();
    }));

    watcher.on('add', function (src, stats) {
        console.log('add', src);
        console.log(stats);
        copy_to_dest(src, stats);
    });

    watcher.on('change', function (src, stats) {
        if (stats.mode != 33060) {
            console.log('change', src);
            console.log(stats);
            console.log('---------------------------');
            copy_to_dest(src, stats);
        }
    });

    watcher.on('unlink', function (src, stats) {
        console.log('unlink', src);
        console.log(stats);
        var dest_path = get_dest_path(src);
        del.sync(dest_path);
    });

    watcher.on('unlinkDir', function (path) {
        var dest_path = get_dest_path(src);
        del.sync(dest_path);
    });

    watcher.on('error', function () {
        console.log('ERROR');
        console.log(arguments);
    });
});

gulp.task('watch_server_files', function () {
    var watcher = gulp.watch([
        'api/**/*.*',
        'bll/**/*.*',
        'confi/**/*.*',
        'dal/**/*.*',
        'npl_packages/**/*.*',
        'routes/**/*.*',
        'views/**/*.*',
        'app.lua'], gulp.parallel(function (done) {
            restartServer();
            done();
        }));
});





gulp.task('minUIRouter', function (done) {
    gulp.src('public/jslib/angular-ui-router.js', { base: 'public' }).pipe(pretreatment('.js')).pipe(rename({ suffix: '.min' })).pipe(gulp.dest('public'));
    done();
});



gulp.task('init', function (done) {
    //pump([
    //    gulp.src(['public_dev/**/*.less', '!public_dev/css/lib.less'], { base: 'public_dev' }),
    //    pretreatment('.less'),
    //    gulp.dest('public')
    //], function (err) {
    //    if (err) {
    //        console.log('init less error');
    //    }
    //});

    gulp.src(['public_dev/**/*.less', '!public_dev/css/lib.less'], { base: 'public_dev' }).pipe(pretreatment('.less')).pipe(chmod({
        owner: {
            read: true,
            write: true,
            execute: true
        },
        group: {
            read: true,
            write: true,
            execute: true
        },
        others: {
            read: true,
            write: true,
            execute: true
        }
    })).pipe(gulp.dest('public'));

    gulp.src('public_dev/**/*.js', { base: 'public_dev' }).pipe(pretreatment('.js')).pipe(chmod({
        owner: {
            read: true,
            write: true,
            execute: true
        },
        group: {
            read: true,
            write: true,
            execute: true
        },
        others: {
            read: true,
            write: true,
            execute: true
        }
    })).pipe(gulp.dest('public'));

    gulp.src('public_dev/**/*.{htm,html}', { base: 'public_dev' }).pipe(pretreatment('.htm')).pipe(chmod({
        owner: {
            read: true,
            write: true,
            execute: true
        },
        group: {
            read: true,
            write: true,
            execute: true
        },
        others: {
            read: true,
            write: true,
            execute: true
        }
    })).pipe(gulp.dest('public'));

    gulp.src('public_dev/**/*.{jpg,png,gif,ico}', { base: 'public_dev' }).pipe(chmod({
        owner: {
            read: true,
            write: true,
            execute: true
        },
        group: {
            read: true,
            write: true,
            execute: true
        },
        others: {
            read: true,
            write: true,
            execute: true
        }
    })).pipe(gulp.dest('public'));

    done();
});





gulp.task('default', gulp.parallel('watch_server_files', 'watch'));
