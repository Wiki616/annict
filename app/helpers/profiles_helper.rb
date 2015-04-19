module ProfilesHelper
  def tombo_profile_background_image_url(profile, mini: false)
    size = if mini
             browser.mobile? ? "w:640,h:320" : "w:500,h:250"
           else
             browser.mobile? ? "w:640,h:650" : "w:500,h:325"
           end

    accessor_name = if profile.tombo_background_image.present?
                      :tombo_background_image
                    else
                      :tombo_avatar
                    end

    tombo_thumb_url(profile, accessor_name, size)
  end
end
