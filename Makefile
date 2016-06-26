all: clean build install

clean:
	rm -f *.gem

build:
	gem build hasm.gemspec

install:
	echo $(PASSWORD) | sudo -S gem install `find . -type f -name "*.gem"`