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
	swift format --in-place --recursive \
		./weg-li ./weg-liTests


.PHONY: dependencies ruby brew