# Deactivate processing while testing
if Rails.env.test?
  CarrierWave.configure do |config|
    config.enable_processing = false
  end
end

# Adding the quality feature to change picture quality while processing images
module CarrierWave
  module MiniMagick
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end
  end
end
