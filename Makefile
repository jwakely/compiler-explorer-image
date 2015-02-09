.NOTPARALLEL: 
all: docker-images

DOCKER := sudo docker

docker-images: gcc-explorer-image d-explorer-image rust-explorer-image gcc-explorer-image-1204

.s3cfg: config.py
	echo 'from config import *; print "[default]\\naccess_key = {}\\nsecret_key={}\\n" \
		.format(S3_ACCESS_KEY, S3_SECRET_KEY)' | python > $@

config.json: config.py make_json.py
	python make_json.py

packer: config.json
	../packer/packer build -var-file=config.json packer.json 

docker/gcc-explorer/.s3cfg: .s3cfg
	cp $< $@
docker/gcc-explorer-1204/.s3cfg: .s3cfg
	cp $< $@
docker/d-explorer/.s3cfg: .s3cfg
	cp $< $@
docker/rust-explorer/.s3cfg: .s3cfg
	cp $< $@

gcc-explorer-image: docker/gcc-explorer/.s3cfg
	$(DOCKER) build -t "mattgodbolt/gcc-explorer:gcc" docker/gcc-explorer

gcc-explorer-image-1204: docker/gcc-explorer-1204/.s3cfg
	$(DOCKER) build -t "mattgodbolt/gcc-explorer:gcc1204" docker/gcc-explorer-1204

d-explorer-image: docker/d-explorer/.s3cfg
	$(DOCKER) build -t "mattgodbolt/gcc-explorer:d" docker/d-explorer

rust-explorer-image: docker/rust-explorer/.s3cfg
	$(DOCKER) build -t "mattgodbolt/gcc-explorer:rust" docker/rust-explorer

publish: docker-images
	sudo docker push mattgodbolt/gcc-explorer

clean:
	echo nothing to clean yet

.PHONY: all clean docker-images gcc-explorer-image rust-explorer-image source publish