class ProjectSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :name, :description, :is_deleted

  def is_deleted
    object.is_deleted?
  end
end