module ChoosePhotoHelper
  def choose_photo
    photo = ''
    rand_number = rand(5).round()
    if rand_number == 0 
      photo = 'cake1_ahspha.png'
    elsif rand_number == 1
      photo = 'cake2_nn5oyb.png'
    elsif rand_number == 2
      photo = 'cake3_j2nzm7.png'
    elsif rand_number == 3
      photo = 'cake4_qimuzk.png'
    elsif rand_number == 4
      photo = 'cake5_ia6jgz.png'
    elsif rand_number == 5
      photo = 'cake6_bwjvb2.png'
    end
    return photo
  end
end
