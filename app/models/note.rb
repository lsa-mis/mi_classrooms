class Note < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :user
  belongs_to :noteable, polymorphic: true
  belongs_to :parent, optional: true, class_name: "Note"
  has_many :notes, foreign_key: :parent_id, dependent: :destroy

  has_rich_text :body

  validates :body, presence: true

  after_create_commit do
    broadcast_append_to [noteable, :notes], target: "#{dom_id(noteable)}_notes"
  end
  after_update_commit do
    broadcast_replace_to self
  end
  after_destroy_commit do
    broadcast_remove_to self
  end
end
