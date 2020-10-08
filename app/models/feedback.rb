class Feedback
  include ActiveModel::Model
  attr_accessor :full_name, :email, :topic, :comment
  validates :topic, :comment, presence: true
  validates :email, presence: true, length: {maximum: 255},
                    format: {with: URI::MailTo::EMAIL_REGEXP, message: "only allows valid emails"}
end
