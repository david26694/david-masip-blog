build_rmd: _posts/2020-05-09-feature-selection-part-1.md _posts/2020-05-16-feature-selection-part-2.md _posts/2020-05-30-slider.md _posts/2020-07-24-sample-size.md _posts/2020-12-10-multivariate-normal.md

_posts/2020-05-09-feature-selection-part-1.md: experiments/lasso/lasso_vs_corr.Rmd
	Rscript experiments/generate_mds.R experiments/lasso/lasso_vs_corr.Rmd
	cp experiments/lasso/lasso_vs_corr.md _posts/2020-05-09-feature-selection-part-1.md
	rm -rf experiments/lasso/lasso_vs_corr.md
	
_posts/2020-05-16-feature-selection-part-2.md: experiments/feature_importance/rf_importance.Rmd
	Rscript experiments/generate_mds.R experiments/feature_importance/rf_importance.Rmd
	sed 's/\!\[\](/\!\[\](https\:\/\/raw.githubusercontent.com\/david26694\/david-masip-blog\/master\/experiments\/feature_importance\//g' experiments/feature_importance/rf_importance.md > _posts/2020-05-16-feature-selection-part-2.md 
	rm -rf _posts/rf_importance_files
	rm -rf rf_importance_files
	rm -rf experiments/feature_importance/rf_importance.md
	
_posts/2020-05-30-slider.md: experiments/slider/slider.Rmd
	Rscript experiments/generate_mds.R experiments/slider/slider.Rmd
	cp experiments/slider/slider.md _posts/2020-05-30-slider.md
	rm -rf experiments/slider/slider.md

_posts/2020-07-24-sample-size.md: experiments/sample_size/sample-size.Rmd
	Rscript experiments/generate_mds.R experiments/sample_size/sample-size.Rmd
	sed 's/\!\[\](/\!\[\](https\:\/\/raw.githubusercontent.com\/david26694\/david-masip-blog\/master\/experiments\/sample_size\//g' experiments/sample_size/sample-size.md > _posts/2020-07-24-sample-size.md
	rm -rf _posts/sample-size_files
	rm -rf sample-size_files
	rm -rf experiments/sample_size/sample-size.md

_posts/2020-12-10-multivariate-normal.md: experiments/multi_normal_distance/multi_normal_distance.Rmd
	Rscript experiments/generate_mds.R experiments/multi_normal_distance/multi_normal_distance.Rmd
	sed 's/\!\[\](/\!\[\](https\:\/\/raw.githubusercontent.com\/david26694\/david-masip-blog\/master\/experiments\/multi_normal_distance\//g' experiments/multi_normal_distance/multi_normal_distance.md > _posts/2020-12-10-multivariate-normal.md
	rm -rf _posts/multi_normal_distance_files
	rm -rf multi_normal_distance_files
	rm -rf experiments/multi_normal_distance/multi_normal_distance.md


help:
	cat Makefile

# start (or restart) the services
server: .FORCE
	docker-compose down --remove-orphans || true;
	docker-compose up

# start (or restart) the services in detached mode
server-detached: .FORCE
	docker-compose down || true;
	docker-compose up -d

# build or rebuild the services WITHOUT cache
build: .FORCE
	chmod 777 Gemfile.lock
	docker-compose stop || true; docker-compose rm || true;
	docker build --no-cache -t hamelsmu/fastpages-nbdev -f _action_files/fastpages-nbdev.Dockerfile .
	docker build --no-cache -t hamelsmu/fastpages-jekyll -f _action_files/fastpages-jekyll.Dockerfile .
	docker-compose build --force-rm --no-cache

# rebuild the services WITH cache
quick-build: .FORCE
	docker-compose stop || true;
	docker build -t hamelsmu/fastpages-nbdev -f _action_files/fastpages-nbdev.Dockerfile .
	docker build -t hamelsmu/fastpages-jekyll -f _action_files/fastpages-jekyll.Dockerfile .
	docker-compose build 

# convert word & nb without Jekyll services
convert: .FORCE
	docker-compose up converter

# stop all containers
stop: .FORCE
	docker-compose stop
	docker ps | grep fastpages | awk '{print $1}' | xargs docker stop

# remove all containers
remove: .FORCE
	docker-compose stop  || true; docker-compose rm || true;

# get shell inside the notebook converter service (Must already be running)
bash-nb: .FORCE
	docker-compose exec watcher /bin/bash

# get shell inside jekyll service (Must already be running)
bash-jekyll: .FORCE
	docker-compose exec jekyll /bin/bash

# restart just the Jekyll server
restart-jekyll: .FORCE
	docker-compose restart jekyll

.FORCE:
