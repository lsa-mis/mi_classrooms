module SearchHelper
  def is_checked?(values)
    if params[:room_characteristics]
      values.each do |value|
        params[:room_characteristics].each_value { |k| k }.flatten(2).include?  (value)
      end
    end
  end
end