class AddDepartmentToRoom < ActiveRecord::Migration[6.1]
  def change
    add_reference :rooms, :department, foreign_key: true
  end
end
