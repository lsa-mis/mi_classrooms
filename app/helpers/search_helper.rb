module SearchHelper
  def is_checked?(values)
    if params[:room_characteristics]
      values.each do |value|
        params[:room_characteristics].each_value { |k| k }.flatten(2).include?  (value)
      end
    end
  end


  def capacity_slider_minimum
    if params[:query]
      if params[:query][:instructional_seating_count_gteq]
        params[:query][:instructional_seating_count_gteq]
      else
        1
      end
      else
      1
    end
  end
  def capacity_slider_maximum
    if params[:query]
      if params[:query][:instructional_seating_count_lteq]
        params[:query][:instructional_seating_count_lteq]
      else
        600
      end
    else
      600
    end
  end
end