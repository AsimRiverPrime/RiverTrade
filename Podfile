# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'RiverPrime' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      if target.name == 'BoringSSL-GRPC'
        target.source_build_phase.files.each do |file|
          if file.settings && file.settings['COMPILER_FLAGS']
            flags = file.settings['COMPILER_FLAGS'].split
            flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
            file.settings['COMPILER_FLAGS'] = flags.join(' ')
          end
        end
      end
    end
  end
  
pod 'TPKeyboardAvoiding'
#pod 'LightweightCharts', '~> 3.8.0'
pod 'GoogleSignIn'
pod 'GTMSessionFetcher'
pod 'Firebase/Firestore'
pod 'FirebaseAuth'
pod 'Firebase/Core'
pod 'Firebase/Crashlytics'

pod 'CountryPickerView'
pod 'PhoneNumberKit', '~> 3.7'

pod 'SVProgressHUD'

pod 'Alamofire', '~> 5.6'
pod 'AEXML', '~> 4.2'
pod 'Starscream', '~> 4.0.4'
pod 'SDWebImage', '~> 5.0'
#pod 'SDWebImageSVGKitPlugin'

#pod 'DGCharts'
pod 'FSCalendar'
end
