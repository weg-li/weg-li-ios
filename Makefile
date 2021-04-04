default: dependencies

dependencies: brew ruby

brew:
	brew update
	brew install ruby
	brew install swiftlint
	brew install swiftformat
	brew install swiftgen

ruby:
	gem install bundler
	bundle install

format:
	swiftformat .

swiftgen:
	swiftgen


.PHONY: dependencies ruby brew
