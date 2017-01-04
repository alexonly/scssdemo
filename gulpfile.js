var gulp = require('gulp'),
	compass = require('gulp-compass');

gulp.task('compass', function () {
	console.log('execute gulp task compass at ' + Date());
	return gulp.src('src/styles/pcss.sass')
		.pipe(compass({
			sass: 'src/styles',
			image: 'src/images',
			css: 'dist/css',
			generated_images_path: 'dist/img',
			sourcemap: true
		}));
});	

gulp.task('default', function () {
	gulp.watch('src/**/*.sass', ['compass']);
	gulp.watch('src/images/**/*', ['compass']);
})


