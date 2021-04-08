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

licenses:
	./tools/license-plist --output-path Settings.bundle --force --suppress-opening-directory --add-version-numbers --package-path weg-li.xcodeproj/project.xcworkspace/swiftpm/Package.resolved



.PHONY: dependencies ruby brew
