inhibit_all_warnings!
platform :ios, '13.0'

def generalPods
    pod 'Firebase'
    pod 'GoogleMaps'
    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'Firebase/Firestore'
    pod 'Kingfisher'
end

target 'STPR' do
    use_frameworks!
    generalPods
end

target 'STPRTests' do
    use_frameworks!
    generalPods
end

post_install do | installer |
 require 'fileutils'
 FileUtils.cp_r('Pods/Target Support Files/Pods-STPR/Pods-STPR-acknowledgements.plist', 'STPR/Supporting Files/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
 installer.aggregate_targets.each do |aggregate_target|
 aggregate_target.xcconfigs.each do |config_name, config_file|
 xcconfig_path = aggregate_target.xcconfig_path(config_name)
 config_file.save_as(xcconfig_path)
 end
 end
end
