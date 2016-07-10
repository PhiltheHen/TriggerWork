# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift

source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

def shared_pods
	pod 'Firebase'
	pod 'Firebase/Database'
	pod 'Firebase/Auth'
	pod 'SwiftHEXColors'
	pod 'SVProgressHUD', :git => 'https://github.com/SVProgressHUD/SVProgressHUD.git'
	pod 'CVCalendar', '~> 1.2.9'
	pod 'CorePlot'
	pod 'Fabric'
	pod 'Crashlytics'
	pod 'ReachabilitySwift'
end

target 'TriggerWork' do
	shared_pods
end

target 'TriggerWork-Dev' do
	shared_pods
end

target 'TriggerWorkTests' do

end

target 'TriggerWorkUITests' do

end

