platform :ios, '13.0'

target 'Wegli' do
  use_frameworks!
  pod 'OpenALPRSwift', :git => 'https://github.com/eugenpirogoff/openalpr-swift.git', :tag => 'v1.0.0'
end

pre_install do |installer|
    Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end
