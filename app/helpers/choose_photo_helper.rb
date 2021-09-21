module ChoosePhotoHelper
  def choose_photo
    photo = ''
    rand_number = rand(3).round()
    if rand_number == 0 
      photo = 'Pngtree_cartoon_birthday_cake_vector_2932706_hyuazx.png'
    elsif rand_number == 1
      photo = 'Pngtree_birthday_cake_vector_png_6047355_iks0q3.png'
    elsif rand_number == 2
      photo = '4792t30n2v5ovn35m550ffa45a24.png'
    end
    return photo
  end
end