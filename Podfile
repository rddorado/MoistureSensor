
platform :ios, :deployment_target => "10.3"


def swift_pods
    use_frameworks!
    pod 'SnapKit'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'FirebaseUI/Database'
end

def testing_pods
    use_frameworks!
    pod 'Nimble'
end

target 'msensor' do
    swift_pods
end

target 'msensorTests' do
	swift_pods
    testing_pods
end

target 'msensorUITests' do
    testing_pods
end
