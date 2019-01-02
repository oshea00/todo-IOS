# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'Todoey' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod "RealmSwift"
  # Pods for Todoey
  pod 'SwipeCellKit', :git => 'https://github.com/SwipeCellKit/SwipeCellKit.git', :branch => 'develop'
  pod 'ChameleonFramework'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
        end
    end
end

