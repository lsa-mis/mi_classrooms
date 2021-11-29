class Note < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :user
  belongs_to :noteable, polymorphic: true
  belongs_to :parent, optional: true, class_name: "Note"
  has_many :notes, foreign_key: :parent_id, dependent: :destroy

  has_rich_text :body

  validates :body, presence: true
end
