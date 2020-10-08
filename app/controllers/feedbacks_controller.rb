class FeedbacksController < ApplicationController

  def create
   @feedback = Feedback.new feedback_params

   if @feedback.valid?
     FeedbackMailer.send_feedback(@feedback).deliver_now
     redirect_back(fallback_location: root_path, notice: "feedback received, thanks!")
   else
     redirect_back(fallback_location: root_path, notice: "There was an issue with your submission!")
   end
  end

  private

  def feedback_params
   params.require(:feedback).permit(:full_name, :email, :topic, :comment)
  end
end
