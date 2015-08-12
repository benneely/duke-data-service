# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
[
    {
      text_id: "project_admin",
      name: "Project Admin",
      description: "Can update project details, delete project, manage project level permissions and perform all file operations",
      contexts: %w(project),
      permissions: %w(view_project update_project delete_project manage_project_permissions download_file create_file update_file delete_file)
    },
    {
      text_id: "project_viewer",
      name: "Project Viewer",
      description: "Can only view project and file meta-data",
      contexts: %w(project),
      permissions: %w(view_project)
    },
    {
      text_id: "file_downloader",
      name:	"File Downloader",
      description:	"Can download files",
      contexts: %w(project),
      permissions: %w(view_project download_file)
    },
    {
      text_id: "file_editor",
      name: "File Editor",
      description: "Can view download create update and delete files",
      contexts: %w(project),
      permissions: %w(view_project download_file create_file update_file delete_file)
    }
].each do |role|
  AuthRole.create(role) unless AuthRole.where(text_id: role[:text_id]).exists?
end