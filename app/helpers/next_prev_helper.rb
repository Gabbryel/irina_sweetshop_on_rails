module NextPrevHelper
  def next_prev(arr, el)
    curr_id = arr.index(el)
    next_id = arr[curr_id + 1]
    prev_id = arr[curr_id - 1]
    prev_text = prev_id.name.length <= 13 ? "#{prev_id.name}" : "#{prev_id.name.split('').first(13).join('')...}"

    if next_id
      next_text = next_id.name.length <= 13 ? "#{next_id.name}" : "#{next_id.name.split('').first(10).join('')... }"
    end
    
    return curr_id, next_id, prev_id, prev_text, next_text
  end
end