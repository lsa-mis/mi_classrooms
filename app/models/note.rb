class Note < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :user
  belongs_to :noteable, polymorphic: true
  belongs_to :parent, optional: true, class_name: "Note"
  has_many :notes, foreign_key: :parent_id, dependent: :destroy

  has_rich_text :body

  validates :body, presence: true

  scope :alert, -> { where(alert: true).order(updated_at: :desc) }
  scope :notice, -> { where(alert: false).order(updated_at: :desc) }

  after_create_commit do
    if self.alert
      broadcast_prepend_to [noteable, :alerts], target: "#{dom_id(noteable)}_alerts"
    else
      broadcast_prepend_to [noteable, :notes], target: "#{dom_id(noteable)}_notes"
    end
  end
  after_update_commit do
    if self.alert
      broadcast_remove_to self
      broadcast_prepend_to [noteable, :alerts], target: "#{dom_id(noteable)}_alerts"
    else
      broadcast_remove_to self
      broadcast_prepend_to [noteable, :notes], target: "#{dom_id(noteable)}_notes"
    end
  end
  after_destroy_commit do
    broadcast_remove_to self
  end
end
