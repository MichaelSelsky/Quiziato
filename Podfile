source "https://github.com/CocoaPods/Specs.git"
use_frameworks!

pod 'Moya'
pod 'Locksmith'
pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git', :branch => 'xcode7'

def testing_pods
  pod 'Quick', '~>0.6.0'
  pod 'Nimble', '2.0.0-rc.3'
end

target :NJITQuizAppTests do
  testing_pods
end

target :NJITQuizAppUITests do
  testing_pods
end
