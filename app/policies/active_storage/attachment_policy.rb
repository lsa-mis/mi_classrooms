module ActiveStorage
  class AttachmentPolicy < ApplicationPolicy

    def delete_file_attachment?
      user.admin 
    end
  end
end
