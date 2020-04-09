build:
	gem build chain_of_command.gemspec

install:
	gem install chain_of_command-*.gem

fury:
	git push fury master
