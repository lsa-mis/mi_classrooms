class Note < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :user
  belongs_to :noteable, polymorphic: true
  belongs_to :parent, optional: true, class_name: "Note"
  has_many :notes, foreign_key: :parent_id, dependent: :destroy

  has_rich_text :body

  validates :body, presence: true

  scope :alert, -> { where(alert: true) }
  scope :notice, -> { where(alert: false) }

  after_create_commit do
    if self.alert
      broadcast_append_to [noteable, :alerts], target: "#{dom_id(noteable)}_alerts"
    else
      broadcast_append_to [noteable, :notes], target: "#{dom_id(noteable)}_notes"
    end
  end
  after_update_commit do
    if self.previous_changes.has_key?('alert')
      if self.alert
        broadcast_remove_to self
        broadcast_append_to [noteable, :alerts], target: "#{dom_id(noteable)}_alerts"
      else
        broadcast_remove_to self
        broadcast_append_to [noteable, :notes], target: "#{dom_id(noteable)}_notes"
      end
    else
      broadcast_replace_to self
    end
  end
  after_destroy_commit do
    broadcast_remove_to self
  end
end
