# platform :ios, '9.0'

target 'CoreDataToDoey' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CoreDataToDoey

pod 'RealmSwift'
pod 'SwipeCellKit'
pod 'ChameleonFramework/Swift', :git => 'https://github.com/wowansm/Chameleon.git', :branch => 'swift5'
pod 'GoogleAnalytics'
pod 'Firebase/Analytics'

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end

  target 'CoreDataToDoeyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'CoreDataToDoeyUITests' do
    # Pods for testing
  end

end
