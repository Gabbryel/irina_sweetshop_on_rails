module RenderHomepagePhotoHelper
  def random_photo
    photo = ''
    rand_number = rand().round()
    if rand_number == 0 
      photo = '0074_336x240.png'
    elsif rand_number == 1
      photo = '0075_336x240.png'
    end
    return photo
  end
end