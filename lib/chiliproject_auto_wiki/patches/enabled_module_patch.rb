module ChiliprojectAutoWiki
  module Patches
    module EnabledModulePatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          def module_enabled_with_auto_wiki
            module_enabled_without_auto_wiki
            case name
            when 'wiki'
              config = Setting.plugin_chiliproject_auto_wiki
              source_page = wiki_copy_source_page(config)
              copy_wiki_page(source_page) if source_page.present?
            end
            return true
          end
          
          alias_method_chain :module_enabled, :auto_wiki
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def wiki_copy_source_page(config)
          if project.present? &&
              config.present? &&
              config['project_id'].present? &&
              config['wiki_page_name'].present?

            # Valid page?
            source_project = Project.find_by_id(config['project_id'])
            if source_project
              source_page = Wiki.find_page(config['wiki_page_name'], :project => source_project)
            end
          end
        end

        def copy_wiki_page(source_page)
          auto_page = project.reload.wiki.pages.new(:title => source_page.title)
          auto_page.content = WikiContent.new(:text => source_page.text, :author => User.current)
          # Let save fail if there are validation errors: existing page with title, invalid title
          auto_page.save
        end

      end
    end
  end
end
