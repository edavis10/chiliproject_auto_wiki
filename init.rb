require 'redmine'

Redmine::Plugin.register :chiliproject_auto_wiki do
  name 'Auto Wiki'
  author 'Eric Davis of Little Stream Software'
  description 'A plugin to create the starting wiki page for a project based on another wiki page'
  url 'https://projects.littlestreamsoftware.com/projects/chiliproject_auto_wiki'
  author_url 'http://www.littlestreamsoftware.com'

  version '0.1.0'

  settings(:partial => 'settings/auto_wiki',
           :default => {
             :project_id => '',
             :wiki_page_name => '',
             :auto_action => 'copy'
           })
end
require 'dispatcher'
Dispatcher.to_prepare :chiliproject_auto_wiki do

  require_dependency 'enabled_module'
  unless EnabledModule.included_modules.include? ChiliprojectAutoWiki::Patches::EnabledModulePatch
    EnabledModule.send(:include, ChiliprojectAutoWiki::Patches::EnabledModulePatch)
  end
end
