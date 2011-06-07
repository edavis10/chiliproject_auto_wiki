require File.dirname(__FILE__) + '/../../../../test_helper'

class ChiliprojectAutoWiki::Patches::EnabledModuleTest < ActionController::TestCase

  subject { EnabledModule.new }

  context "#module_enabled with a 'wiki' module" do
    setup do
      @project = Project.generate!.reload
      @project.enabled_modules.select {|m| m.name == 'wiki'}.collect(&:destroy)
      @module = EnabledModule.new(:name => 'wiki', :project => @project)

      @copy_project = Project.generate!.reload
      @copy_project_wiki = @copy_project.wiki
      @wiki_page = @copy_project_wiki.pages.new(:title => 'A Title')
      @wiki_page.content = WikiContent.new(:text => 'Some content')
      assert @wiki_page.save
    end
    
    context "with a configured project and wiki page" do
      context "with 'copy' as the configured auto_action" do
        setup do
          configure_plugin('project_id' => @copy_project.id.to_s, 'wiki_page_name' => 'A Title', 'auto_action' => 'copy')
        end
        
        should "create a new Wiki Page" do
          assert_difference('WikiPage.count',1) do
            assert @module.save
          end
        end

        should "copy the title from the wiki page" do
          assert @module.save

          @project.reload
          assert_equal Wiki.titleize("A Title"), @project.wiki.pages.first.title
        end
        
        should "copy the content from the wiki page" do
          assert @module.save

          @project.reload
          assert_equal "Some content", @project.wiki.find_page("A Title").text
        end

        should "add a comment to the copied wiki page" do
          assert @module.save

          @project.reload
          assert_equal "Created by https://projects.littlestreamsoftware.com/projects/chiliproject_auto_wiki", @project.wiki.find_page("A Title").content.comments
        end
        
        should "not copy the content if the wiki page exists in the new project" do
          @existing_page =  @project.wiki.pages.new(:title => 'A Title')
          @existing_page.content = WikiContent.new(:text => 'Other content')
          assert @existing_page.save

          assert_no_difference('WikiPage.count') do
            assert @module.save
          end

          assert_equal ['A_Title'], @project.reload.wiki.pages.collect(&:title)
          assert_equal ['Other content'], @project.reload.wiki.pages.collect(&:text)
          
        end
        
      end

      context "with 'start' as the configured auto_action" do
        setup do
          configure_plugin('project_id' => @copy_project.id.to_s, 'wiki_page_name' => 'A Title', 'auto_action' => 'start')
        end

        should "create a new Wiki Page" do
          assert_difference('WikiPage.count',1) do
            assert @module.save
          end
        end

        should "copy the content from the wiki page to the start page" do
          assert @module.save

          @project.reload
          assert_equal "Some content", @project.wiki.find_page("").text
        end
      
        should "add a comment to the copied wiki page" do
          assert @module.save

          @project.reload
          assert_equal "Created by https://projects.littlestreamsoftware.com/projects/chiliproject_auto_wiki", @project.wiki.find_page("").content.comments
        end

        should "not copy the content if the wiki page exists in the new project" do
          assert_equal "Wiki", @project.wiki.start_page
          @existing_page =  @project.wiki.pages.new(:title => 'Wiki')
          @existing_page.content = WikiContent.new(:text => 'Other content')
          assert @existing_page.save

          assert_no_difference('WikiPage.count') do
            assert @module.save
          end

          assert_equal ['Wiki'], @project.reload.wiki.pages.collect(&:title)
          assert_equal ['Other content'], @project.reload.wiki.pages.collect(&:text)

        end
        

      end
          
    end

    context "with no configured project" do
      setup do
        configure_plugin('project_id' => '')
      end

      should_not_create_a_wiki_page { assert @module.save }
      
    end

    context "with a configured but invalid project" do
      setup do
        configure_plugin('project_id' => 'invalid', 'wiki_page_name' => '')
      end
      
      should_not_create_a_wiki_page { assert @module.save }
    end

    context "with a configured project but no wiki page configured" do
      setup do
        configure_plugin('project_id' => @copy_project.id.to_s, 'wiki_page_name' => '')
      end
      
      should_not_create_a_wiki_page { assert @module.save }
    end

    context "with a configured project but an unknown wiki page" do
      setup do
        configure_plugin('project_id' => @copy_project.id.to_s, 'wiki_page_name' => 'Unknown')
      end
      
      should_not_create_a_wiki_page { assert @module.save }
    end
    
  end
  
end
