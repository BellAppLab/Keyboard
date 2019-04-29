Pod::Spec.new do |s|

  s.name                = "Keyboard"
  s.version             = "1.1.0"
  s.summary             = "Never implement the UIKeyboardDidShow notification ever again. Ever."
  s.screenshot          = "https://github.com/BellAppLab/Keyboard/raw/master/Images/keyboard.png"

  s.description         = <<-DESC
Never implement `NSNotification.Name.UIKeyboardDidShow` ever again. Ever.

Yeah, seriously. Handling the keyboard on iOS shouldn't be painful. But it is.

So instead of doing a whole lot of calculations, or embedding everything in `UIScrollView`s, `import Keyboard` and **get on with your life**.
                   DESC

  s.homepage            = "https://github.com/BellAppLab/Keyboard"

  s.license             = { :type => "MIT", :file => "LICENSE" }

  s.author              = { "Bell App Lab" => "apps@bellapplab.com" }
  s.social_media_url    = "https://twitter.com/BellAppLab"

  s.ios.deployment_target       = "9.0"

  s.swift_version       = '5.0'

  s.module_name         = 'Keyboard'

  s.source              = { :git => "https://github.com/BellAppLab/Keyboard.git", :tag => "#{s.version}" }

  s.source_files        = "Sources/Keyboard"

  s.frameworks          = "Foundation"
  s.ios.framework       = "UIKit"

end
