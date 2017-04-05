module MembersHelper
  def member_avatar_tag(member, size = :large, img_class = '')
    if member.blank? or member.avatar.blank?
      return image_tag("avatar/#{size}.png", class: img_class)
    end
    
    image_tag(member.avatar.url(size), class: img_class)
    
  end
end