module SearchHelper
  def is_checked?(values)
    if params[:room_characteristics]
      values.each do |value|
        params[:room_characteristics].each_value { |k| k }.flatten(2).include?  (value)
      end
    end
  end


  def capacity_slider_minimum
    if params[:min_capacity]
      if params[:min_capacity]
        params[:min_capacity]
      else
        1
      end
      else
      1
    end
  end
  def capacity_slider_maximum
    if params[:query]
      if params[:max_capacity]
        params[:max_capacity]
      else
        600
      end
    else
      600
    end
  end
end