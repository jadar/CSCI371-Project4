var gulp = require('gulp'),
    sass = require('gulp-sass'),
    rename = require('gulp-rename'),
    autoprefixer = require('gulp-autoprefixer'),
    pckg = require('./package.json');

gulp.task('styles', function () {
    return gulp.src('Resources/scss/bundle.scss', { base: '.' })
        .pipe(sass({
            precision: 8,
            outputStyle: 'expanded',
            includePaths: ['node_modules']
        }).on('error', sass.logError))
        .pipe(autoprefixer({
            browsers: pckg.browserslist,
            cascade: false
        }))
        .pipe(rename('app.css'))
        .pipe(gulp.dest('Public/css/'))
});

gulp.task('build', ['styles']);

gulp.task('default', ['build']);
