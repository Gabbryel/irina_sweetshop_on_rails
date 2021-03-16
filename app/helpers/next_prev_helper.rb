module NextPrevHelper
  def next_prev(arr, el)
    curr_id = arr.index(el)
    next_id = arr[curr_id + 1]
    prev_id = arr[curr_id - 1]
    prev_text = "◀︎ #{prev_id.name.split('').first(14).join('')}..."

    if next_id
      next_text = "#{next_id.name.split('').first(14).join('')}... ►"
    end
    
    return curr_id, next_id, prev_id, prev_text, next_text
  end
end