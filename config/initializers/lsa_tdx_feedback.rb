Rails.application.reloader.to_prepare do
  LsaTdxFeedback::FeedbackController.class_eval do
    before_action -> { authorize :feedback }, only: :create
  end
end
